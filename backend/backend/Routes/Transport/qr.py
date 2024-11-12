from fastapi import APIRouter, HTTPException
import json
import os
from pydantic import BaseModel
from datetime import datetime

router = APIRouter(prefix="/transport", tags=["transport_schedule"])
dir = os.path.dirname(os.path.realpath(__file__))


# Request body model
class TransactionRequest(BaseModel):
    transactionId: str


# Response model
class TransactionResponse(BaseModel):
    transactionId: str
    payment_time: str  # hh:mm dd/mm/yy
    busTiming: str  # hh:mm


@router.post("/qr", response_model=TransactionResponse)
async def process_transaction(request: TransactionRequest):
    # Sample data generation for the response
    payment_time = datetime.now().strftime("%H:%M %d/%m/%y")
    bus_timing = "14:30"  # Example bus timing; replace with actual data logic if needed

    return TransactionResponse(
        transactionId=request.transactionId,
        payment_time=payment_time,
        busTiming=bus_timing
    )
