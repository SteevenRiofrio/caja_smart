# app/routes/receipts.py
from typing import List
from fastapi import APIRouter, HTTPException, Depends
from app.models.receipt import ReceiptModel
from app.services.receipt_service import ReceiptService

router = APIRouter()
receipt_service = ReceiptService()

# Get all receipts
@router.get("/", response_description="List all receipts")
async def get_receipts():
    receipts = await receipt_service.get_all_receipts()
    return {"data": receipts, "count": len(receipts)}

# Get receipts by date
@router.get("/date/{date}", response_description="Get receipts by date")
async def get_receipts_by_date(date: str):
    receipts = await receipt_service.get_receipts_by_date(date)
    return {"data": receipts, "count": len(receipts)}

# Create a new receipt
@router.post("/", response_description="Create a new receipt")
async def create_receipt(receipt: ReceiptModel):
    try:
        # Verificar si ya existe un comprobante con el mismo número de transacción
        existing = await receipt_service.get_receipt_by_transaction(receipt.nroTransaccion)
        if existing:
            raise HTTPException(status_code=400, detail="Ya existe un comprobante con este número de transacción")
        
        created_receipt = await receipt_service.create_receipt(receipt)
        return {"success": True, "data": created_receipt}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Delete a receipt
@router.delete("/{transaction_number}", response_description="Delete a receipt")
async def delete_receipt(transaction_number: str):
    # Verificar si existe el comprobante
    existing = await receipt_service.get_receipt_by_transaction(transaction_number)
    if not existing:
        raise HTTPException(status_code=404, detail=f"Comprobante con número de transacción {transaction_number} no encontrado")
    
    deleted = await receipt_service.delete_receipt(transaction_number)
    if deleted:
        return {"success": True, "message": "Comprobante eliminado correctamente"}
    
    raise HTTPException(status_code=500, detail="Error al eliminar el comprobante")

# Get closing report
@router.get("/report/{date}", response_description="Generate closing report")
async def get_closing_report(date: str):
    report = await receipt_service.generate_closing_report(date)
    return report