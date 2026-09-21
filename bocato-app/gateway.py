import os
import httpx
from fastapi import FastAPI, Request, HTTPException

app = FastAPI(title="Bocato API Gateway")

# El mismo secreto que pusimos en main.py (Idealmente viene de Vault)
INTERNAL_GATEWAY_SECRET = os.getenv("BACKEND_SHARED_SECRET", "gateway-api-secret-456")
BACKEND_URL = "http://localhost:9000"  # Puerto donde correrá tu main.py

@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def gateway_proxy(request: Request, path: str):
    url = f"{BACKEND_URL}/{path}"
    
    # Preparamos los headers e inyectamos el secreto
    headers = dict(request.headers)
    headers.pop("host", None)
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
