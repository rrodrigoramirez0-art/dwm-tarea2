from fastapi import FastAPI, HTTPException, status, Header, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import List, Optional
import uuid
import os
import secrets

# configuracion de seguridad (vault/env)
INTERNAL_GATEWAY_SECRET = os.getenv("BACKEND_SHARED_SECRET", "gateway-api-secret-456")

async def verify_gateway(x_gateway_secret: str = Header(None)):
    if not x_gateway_secret or not secrets.compare_digest(x_gateway_secret, INTERNAL_GATEWAY_SECRET):
        raise HTTPException(
            status_code=403, 
            detail="Solicitud no autorizada: Falla de autenticación con el Gateway"
        )

# inicializacion de la app(protegida)
app = FastAPI(
    title="Bocato API - FastAPI & MongoDB (Simulado)",
    dependencies=[Depends(verify_gateway)]
)

# 1. PERMITIR CONEXIONES DESDE EL NAVEGADOR (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Base de datos en memoria (Simula la colección de MongoDB)
sandwiches_db = [
    {
        "id": "651a2b3c4d5e6f7a8b9c0d1e",
        "nombre": "Italiano Tradicional",
        "precio": 5500,
        "descripcion": "Churrasco, tomate, palta y mayonesa casera en pan frica.",
        "disponible": True,
        # URL ESPECÍFICA PARA EL ITALIANO
        "imagen": "https://media.istockphoto.com/id/1336324521/es/foto/corte-en-fr%C3%ADo-casero-italiano-sub-sandwich.jpg?s=612x612&w=0&k=20&c=5XEM00MSO8c_eW3oNTrBBQBjIwi3QU3F9wUxe2J6Y64="
    },
    {
        "id": "651a2b3c4d5e6f7a8b9c0d1f",
        "nombre": "Barros Luco",
        "precio": 5200,
        "descripcion": "Abundante churrasco con queso mantecoso derretido.",
        "disponible": True,
        # URL ESPECÍFICA PARA EL BARROS LUCO
        "imagen": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTy3wg5Ol0LnHu_tHvWf9QtH0-pLpHdeRnealN7S3cMt1Slsk8ocVbZMUI&s=10"
    },
    {
        "id": "651a2b3c4d5e6f7a8b9c0d20",
        "nombre": "Chacarero Bocato",
        "precio": 5800,
        "descripcion": "Churrasco, porotos verdes frescos, tomate y ají verde.",
        "disponible": True,
        # URL ESPECÍFICA PARA EL CHACARERO
        "imagen": "https://tofuu.getjusto.com/orioneat-local/resized2/k49HxECyMRhoTGMgz-2400-x.webp"
    }
]

# Modelos Pydantic (Validación de entradas)
class SandwichModel(BaseModel):
    nombre: str
    precio: int
    descripcion: Optional[str] = None
    disponible: bool = True

class SandwichUpdateModel(BaseModel):
    nombre: Optional[str] = None
    precio: Optional[int] = None
    descripcion: Optional[str] = None
    disponible: Optional[bool] = None


# --- RUTAS DE LA API (5 OPERACIONES CRUD) ---

# 1. CONSULTAR TODOS
@app.get("/sandwiches", response_model=List[dict])
async def consultar_sandwiches():
    return sandwiches_db

# 2. CONSULTAR POR ID
@app.get("/sandwiches/{id}", response_model=dict)
async def consultar_sandwich_por_id(id: str):
    for sandwich in sandwiches_db:
        if sandwich["id"] == id:
            return sandwich
    raise HTTPException(status_code=404, detail="Sánguche no encontrado")

# 3. INSERTAR
@app.post("/sandwiches", status_code=status.HTTP_201_CREATED, response_model=dict)
async def insertar_sandwich(sandwich: SandwichModel):
    datos = sandwich.model_dump() if hasattr(sandwich, 'model_dump') else sandwich.dict()
    datos["id"] = uuid.uuid4().hex[:24]  # Genera un ID compatible con MongoDB
    sandwiches_db.append(datos)
    return datos

# 4. ACTUALIZAR
@app.put("/sandwiches/{id}", response_model=dict)
async def actualizar_sandwich(id: str, datos: SandwichUpdateModel):
    for index, sandwich in enumerate(sandwiches_db):
        if sandwich["id"] == id:
            cambios = {k: v for k, v in datos.dict().items() if v is not None}
            sandwiches_db[index].update(cambios)
            return sandwiches_db[index]
    raise HTTPException(status_code=404, detail="Sánguche no encontrado")

# 5. ELIMINAR EN MONGODB
@app.delete("/sandwiches/{id}")
async def eliminar_sandwich(id: str):
    global sandwiches_db
    for index, sandwich in enumerate(sandwiches_db):
        if sandwich["id"] == id:
            sandwiches_db.pop(index)
            return {"mensaje": f"Sánguche con ID {id} eliminado correctamente"}
    raise HTTPException(status_code=404, detail="Sánguche no encontrado")


# --- CONFIGURACIÓN PARA SERVIR EL FRONTEND WEB ---

# Montar carpeta pública si existe
if os.path.exists("public"):
    app.mount("/static", StaticFiles(directory="public"), name="static")

# Servir el HTML directamente en http://127.0.0.1:8000
@app.get("/", include_in_schema=False)
async def serve_index():
    if os.path.exists("public/index.html"):
        return FileResponse("public/index.html")
    return {"mensaje": "Backend FastAPI activo. Abre /docs para probar Swagger UI."}
