# app/models/receipt.py
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

class ReceiptModel(BaseModel):
    """Modelo para los comprobantes de pago"""
    banco: str = "Banco del Barrio | Banco Guayaquil"
    fecha: str
    hora: str
    tipo: str = "Pago de Servicio"
    nroTransaccion: str = Field(..., alias="nro_transaccion")
    nroControl: str = Field(..., alias="nro_control")
    local: str
    fechaAlternativa: str = Field("", alias="fecha_alternativa")
    corresponsal: str
    tipoCuenta: str = Field("", alias="tipo_cuenta")
    valorTotal: float = Field(..., alias="valor_total")
    fullText: str = Field("", alias="full_text")
    created_at: datetime = Field(default_factory=datetime.now)

    class Config:
        allow_population_by_field_name = True
        schema_extra = {
            "example": {
                "banco": "Banco del Barrio | Banco Guayaquil",
                "fecha": "25/04/2025",
                "hora": "10:30:45",
                "tipo": "Pago de Servicio",
                "nro_transaccion": "123456789",
                "nro_control": "987654321",
                "local": "Comercial XYZ",
                "fecha_alternativa": "",
                "corresponsal": "12345",
                "tipo_cuenta": "AHORROS",
                "valor_total": 45.99,
                "full_text": "Texto completo del comprobante...",
                "created_at": "2025-04-23T10:30:45.123Z"
            }
        }