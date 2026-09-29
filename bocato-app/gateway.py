import os
import httpx
import hvac
import secrets
from fastapi import FastAPI, Request, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

app = FastAPI(title="Bocato API Gateway")

# --- 1. CONEXIÓN A VAULT (Gestión de Secretos) ---
# Usamos las variables de entorno que configuraste en tu terminal, o valores por defecto
VAULT_ADDR = os.getenv("VAULT_ADDR", "http://127.0.0.1:8200")
VAULT_TOKEN = os.getenv("VAULT_TOKEN", "root") # 'root' o el token que te dio 'vault server -dev'

# Variables donde guardaremos los secretos reales
CLIENT_TOKEN = "student-token-123" 
INTERNAL_GATEWAY_SECRET = "gateway-api-secret-456"

try:
    # Conectamos con el cliente hvac
    vault_client = hvac.Client(url=VAULT_ADDR, token=VAULT_TOKEN)
    if vault_client.is_authenticated():
        # Leemos los secretos que guardaste con 'vault kv put secret/gateway...'
        response = vault_client.secrets.kv.v2.read_secret_version(path='gateway')
        vault_secrets = response['data']['data']
        
        # Asignamos los valores dinámicos
        CLIENT_TOKEN = vault_secrets.get("client_token", CLIENT_TOKEN)
        INTERNAL_GATEWAY_SECRET = vault_secrets.get("backend_shared_secret", INTERNAL_GATEWAY_SECRET)
        print("✅ Secretos cargados exitosamente desde Hashicorp Vault")
except Exception as e:
    print(f"⚠️ No se pudo conectar a Vault (usando valores de respaldo). Error: {e}")


# --- 2. VALIDACIÓN DEL BEARER TOKEN (Autenticación del Cliente) ---
security = HTTPBearer()

def verify_client_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    # Comparamos el token que envía el usuario (credentials.credentials) con el de Vault
    if not secrets.compare_digest(credentials.credentials, CLIENT_TOKEN):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No autorizado: Token inválido o expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )


# --- 3. PROXY Y ENRUTAMIENTO HACIA EL BACKEND ---
BACKEND_URL = "http://localhost:9000"

# Al agregar dependencies=[Depends(verify_client_token)], exigimos el Token a nivel de ruta
@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"], dependencies=[Depends(verify_client_token)])
async def gateway_proxy(request: Request, path: str):
    url = f"{BACKEND_URL}/{path}"
    
    headers = dict(request.headers)
    headers.pop("host", None)
    
    # Eliminamos el Bearer token del usuario para no pasarlo innecesariamente al backend
    headers.pop("authorization", None)
    
    # Inyectamos el secreto interno (aislamiento del backend)
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
            raise HTTPException(status_code=502, detail=f"Error conectando al backend: {exc}")
