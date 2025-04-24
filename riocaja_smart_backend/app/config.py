# app/config.py
import os
from dotenv import load_dotenv

# Cargar variables de entorno desde .env
load_dotenv()

# Configuración de MongoDB
MONGO_URI = os.getenv("MONGO_URI", "mongodb+srv://username:password@cluster.mongodb.net/riocaja_smart?retryWrites=true&w=majority")
DATABASE_NAME = os.getenv("DATABASE_NAME", "riocaja_smart")

# Configuración de la API
API_PREFIX = "/api/v1"