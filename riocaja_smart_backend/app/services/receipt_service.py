# app/services/receipt_service.py
from datetime import datetime
from typing import List, Optional
from bson import ObjectId
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from app.config import MONGO_URI, DATABASE_NAME
from app.models.receipt import ReceiptModel

class ReceiptService:
    """Servicio para manejar comprobantes en MongoDB"""
    
    def __init__(self):
        self.client = AsyncIOMotorClient(MONGO_URI)
        self.db: AsyncIOMotorDatabase = self.client[DATABASE_NAME]
        self.receipts = self.db["receipts"]
    
    async def get_all_receipts(self) -> List[dict]:
        """Obtener todos los comprobantes"""
        receipts = []
        cursor = self.receipts.find().sort("created_at", -1)
        async for document in cursor:
            document["_id"] = str(document["_id"])
            receipts.append(document)
        return receipts
    
    async def get_receipts_by_date(self, date_str: str) -> List[dict]:
        """Obtener comprobantes por fecha (formato: dd/MM/yyyy)"""
        receipts = []
        cursor = self.receipts.find({"fecha": date_str}).sort("created_at", -1)
        async for document in cursor:
            document["_id"] = str(document["_id"])
            receipts.append(document)
        return receipts
    
    async def create_receipt(self, receipt: ReceiptModel) -> dict:
        """Crear un nuevo comprobante"""
        receipt_dict = receipt.dict(by_alias=True)
        receipt_dict["created_at"] = datetime.now()
        
        result = await self.receipts.insert_one(receipt_dict)
        created_receipt = await self.receipts.find_one({"_id": result.inserted_id})
        created_receipt["_id"] = str(created_receipt["_id"])
        return created_receipt
    
    async def get_receipt_by_transaction(self, transaction_number: str) -> Optional[dict]:
        """Obtener un comprobante por su número de transacción"""
        receipt = await self.receipts.find_one({"nroTransaccion": transaction_number})
        if receipt:
            receipt["_id"] = str(receipt["_id"])
        return receipt
    
    async def delete_receipt(self, transaction_number: str) -> bool:
        """Eliminar un comprobante por su número de transacción"""
        result = await self.receipts.delete_one({"nroTransaccion": transaction_number})
        return result.deleted_count > 0
    
    async def generate_closing_report(self, date_str: str) -> dict:
        """Generar informe de cierre para una fecha específica"""
        receipts = await self.get_receipts_by_date(date_str)
        
        if not receipts:
            return {
                "summary": {},
                "total": 0.0,
                "date": date_str,
                "count": 0,
            }
        
        # Calcular total
        total = sum(receipt["valorTotal"] for receipt in receipts)
        
        # Agrupar por tipo de transacción
        summary = {}
        for receipt in receipts:
            tipo = receipt["tipo"]
            if tipo in summary:
                summary[tipo] += receipt["valorTotal"]
            else:
                summary[tipo] = receipt["valorTotal"]
        
        return {
            "summary": summary,
            "total": total,
            "date": date_str,
            "count": len(receipts),
        }