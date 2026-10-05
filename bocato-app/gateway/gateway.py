import os
import httpx
import hvac
import secrets
from fastapi import FastAPI, Request, HTTPException, status, Response
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Bocato API Gateway")

# --- 1. SOPORTE DE CORS COMPLETO ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 2. CONEXIÓN A VAULT ---
VAULT_ADDR = os.getenv("VAULT_ADDR", "http://127.0.0.1:8200")
VAULT_TOKEN = os.getenv("VAULT_TOKEN", "root")

CLIENT_TOKEN = "student-token-123" 
INTERNAL_GATEWAY_SECRET = "gateway-api-secret-456"

try:
    vault_client = hvac.Client(url=VAULT_ADDR, token=VAULT_TOKEN)
    if vault_client.is_authenticated():
        response = vault_client.secrets.kv.v2.read_secret_version(path='gateway')
        vault_secrets = response['data']['data']
        
        CLIENT_TOKEN = vault_secrets.get("client_token", CLIENT_TOKEN)
        INTERNAL_GATEWAY_SECRET = vault_secrets.get("backend_shared_secret", INTERNAL_GATEWAY_SECRET)
        print("✅ Secretos cargados exitosamente desde Hashicorp Vault")
except Exception as e:
    print(f"⚠️ No se pudo conectar a Vault (usando valores de respaldo). Error: {e}")

BACKEND_URL = "http://localhost:9000"

# --- 3. MANEJO EXPLÍCITO DE OPTIONS (CORS PREFLIGHT) ---
@app.options("/{path:path}")
async def options_handler(path: str):
    return Response(status_code=200)

# --- 4. PROXY Y ENRUTAMIENTO HACIA EL BACKEND ---
@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def gateway_proxy(request: Request, path: str):
    # Validar Bearer Token del cliente
    auth_header = request.headers.get("authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No autorizado: Token requerido",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    token = auth_header.split(" ")[1]
    if not secrets.compare_digest(token, CLIENT_TOKEN):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No autorizado: Token inválido o expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )

    url = f"{BACKEND_URL}/{path}"
    
    headers = dict(request.headers)
    headers.pop("host", None)
    headers.pop("authorization", None)
    
    # Inyectar credencial interna para el Backend
    headers["X-Gateway-Secret"] = INTERNAL_GATEWAY_SECRET

    async with httpx.AsyncClient() as client:
        try:
            upstream = await client.request(
                method=request.method,
                url=url,
                headers=headers,
                content=await request.body()
            )
            # Reenviar el contenido y estado exacto recibido del Backend
            return Response(
                content=upstream.content,
                status_code=upstream.status_code,
                media_type=upstream.headers.get("content-type")
            )
        except httpx.RequestError as exc:
            raise HTTPException(status_code=502, detail=f"Error conectando al backend: {exc}")
