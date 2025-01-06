from fastapi import APIRouter, HTTPException
import json
import os
from pydantic import BaseModel
from datetime import datetime
from utils import conn
from Routes.Auth.cookie import get_user_id

from queries.transport import log_transaction_to_db, scan_qr, get_last_transaction

router = APIRouter(prefix="/transport", tags=["transport_schedule"])
dir = os.path.dirname(os.path.realpath(__file__))


# Request body model
class TransactionRequest(BaseModel):
    transactionId: str


# Response model
class TransactionResponse(BaseModel):
    transactionId: str
    paymentTime: str  # hh:mm dd/mm/yy
    travelDate: str  # dd/mm/yy
    busTiming: str  # hh:mm
    isUsed: bool

class ScanQRModel(BaseModel):
    isScanned: bool

@router.post("/qr", response_model=TransactionResponse)
async def process_transaction(request: TransactionRequest):
    # Sample data generation for the response
    user_id = get_user_id(request)

    payment_time = datetime.now().strftime("%H:%M %d/%m/%y")
    travel_date = datetime.now().strftime("%d/%m/%y")
    bus_timing = "14:30"  # Example bus timing; replace with actual data logic if needed

    # Prepare the response
    response = TransactionResponse(
        transactionId=request.transactionId,
        paymentTime=payment_time,
        travelDate=travel_date,
        busTiming=bus_timing,
        isUsed=False
    )

    # Log the transaction in the database
    transaction_data = {
        "transaction_id": response.transactionId,
        "payment_time": datetime.now(),
        "travel_date": datetime.now(),
        "bus_timing": response.busTiming,
        "isUsed": False
    }
    result = log_transaction_to_db(transaction_data, user_id)

    if not result:
        query = """
        SELECT payment_time, travel_date, bus_timing, isUsed
        FROM transactions
        WHERE transaction_id = %s;
        """

        try:
            with conn.cursor() as cur:
                cur.execute(query, (request.transactionId,))
                result = cur.fetchone()
                if not result:
                    return {"error": "Transaction not found"}, 404

                payment_time, travel_date, bus_timing, is_used = result

            # Prepare the response
            response = TransactionResponse(
                transactionId=request.transactionId,
                paymentTime=payment_time.strftime("%H:%M %d/%m/%y"),
                travelDate=travel_date.strftime("%d/%m/%y"),
                busTiming=bus_timing.strftime("%H:%M"),
                isUsed=is_used
            )

            return response

        except Exception as e:
            print(f"Error fetching transaction: {e}")
            return {"error": "Internal server error"}, 500

    return response

@router.post("/qr/scan", response_model= ScanQRModel)
async def scan_qr_code(request: TransactionRequest):
    # Sample QR code scanning logic

    transaction_data = {
        "transaction_id": request.transactionId,
    }

    result = scan_qr(transaction_data)

    return ScanQRModel(isScanned=result)

@router.get("/qr/recent", response_model= ScanQRModel)
async def get_recent_transaction(request: TransactionRequest):
    user_id = get_user_id(request)
    
    transaction_data = get_last_transaction(user_id=user_id)
    
    if transaction_data is None:
        raise HTTPException(status_code=404, detail="No recent transaction found.")

    return ScanQRModel(**transaction_data)