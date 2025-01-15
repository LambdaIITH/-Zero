import json
import os
from datetime import datetime
import requests
from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel
from queries.transport import (get_last_transaction, log_transaction_to_db,
                               scan_qr)
from Routes.Auth.cookie import get_user_id
from Routes.User.user import get_user
from utils import conn

router = APIRouter(prefix="/transport", tags=["transport_schedule"])
dir = os.path.dirname(os.path.realpath(__file__))


# Request body model
class TransactionRequest(BaseModel):
    transactionId: str
    amount: str
    start: str
    destination: str


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
async def process_transaction(request: Request, transaction: TransactionRequest):
    user_id = get_user_id(request)

    payment_time = datetime.now().strftime("%H:%M %d/%m/%y")
    travel_date = datetime.now().strftime("%d/%m/%y")
    bus_timing = "14:30"

    response = TransactionResponse(
        transactionId=transaction.transactionId,
        paymentTime=payment_time,
        travelDate=travel_date,
        busTiming=bus_timing,
        isUsed=False,
        start=transaction.start,
        destination=transaction.destination,
        amount=transaction.amount
    )

    transaction_data = {
        "transaction_id": response.transactionId,
        "payment_time": datetime.now(),
        "travel_date": datetime.now(),
        "bus_timing": response.busTiming,
        "isUsed": False,
        "start": response.start,
        "destination": response.destination,
        "amount": response.amount
    }
    
    if user_id:
        user_details = get_user(user_id=user_id)
    
    google_sheets_data = {
        "transaction_id": response.transactionId,
        "name": user_details['name'],
        "email": user_details['email'],
        "amount": response.amount,
        "from": response.start,
        "to": response.destination,
        "travel_date": travel_date,
        "bus_timing": response.busTiming,
    }
    
    try:
        sheets_response = requests.post(os.getenv("GOOGLE_SHEET_APP_SCRIPT_URL"), json=google_sheets_data)
        sheets_response.raise_for_status()
    except Exception as e:
        print(f"Error logging to Google Sheets: {e}")
    
    result = log_transaction_to_db(transaction_data, user_id)

    if not result:
        query = """
        SELECT payment_time, travel_date, bus_timing, isUsed
        FROM transactions
        WHERE transaction_id = %s;
        """

        try:
            with conn.cursor() as cur:
                cur.execute(query, (transaction.transactionId,))
                result = cur.fetchone()
                if not result:
                    raise HTTPException(status_code=404, detail="Transaction not found")

                payment_time, travel_date, bus_timing, is_used = result

            # Prepare the response
            response = TransactionResponse(
                transactionId=transaction.transactionId,
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