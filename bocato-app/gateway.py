import os
import httpx
import hvac
import secrets
from fastapi import FastAPI, Request, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

app = FastAPI(title="Bocato API Gateway")

VAULT_ADDR = os.getenv("VAULT_ADDR", "http://127.0.0.1:8200")
VAULT_TOKEN = os.getenv("VAULT_TOKEN", "root")

CLIENT_TOKEN = "student-token-123" 
INTERNAL_GATEWAY_SECRET = "gateway-api-secret-456"

# Intentar cargar secretos desde Vault
try:
    vault_client = hvac.Client(url=VAULT_ADDR, token=VAULT_TOKEN)
    if vault_client.is_authenticated():
        response = vault_client.secrets.kv.v2.read_secret_version(path='gateway')
        vault_secrets = response['data']['data']
        CLIENT_TOKEN = vault_secrets.get("client_token", CLIENT_TOKEN)
        INTERNAL_GATEWAY_SECRET = vault_secrets.get("backend_shared_secret", INTERNAL_GATEWAY_SECRET)
        print("✅ Secretos cargados exitosamente desde Hashicorp Vault")
except Exception as e:
    print(f"⚠️ No se pudo conectar a Vault (usando valores por defecto). Error: {e}")

security = HTTPBearer()

def verify_client_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    if not secrets.compare_digest(credentials.credentials, CLIENT_TOKEN):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No autorizado: Token inválido o expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )

BACKEND_URL = "http://localhost:9000"

@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"], dependencies=[Depends(verify_client_token)])
async def gateway_proxy(request: Request, path: str):
    url = f"{BACKEND_URL}/{path}"
    
    headers = dict(request.headers)
    headers.pop("host", None)
    headers.pop("authorization", None)
    
    # Inyección del secreto de servicio recuperado desde Vault
    headers["X-Gateway-Secret"] = INTERNAL_GATEWAY_SECRET

    async with httpx.AsyncClient() as client:
        try:
            response = await client.request(
                method=request.method,
                url=url,
                headers=headers,
                content=await request.body()
            )
            return response.json()
        except httpx.RequestError as exc:
            # Requisito de la guía: Manejo de falla 502 cuando el backend está caído
            raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=f"Backend no disponible: {exc}")