from pypika import Query, Table, functions as fn, Order
from typing import Dict, Any
from backend.backend.utils import conn

def log_transaction_to_db(transaction_data: Dict[str, Any]) -> bool:
    """
    Function to log transaction data into PostgreSQL.
    """
    query = """
    INSERT INTO transactions (transaction_id, payment_time, travel_date, bus_timing, isUsed)
    VALUES (%s, %s, %s, %s, %s);
    """
    values = (
        transaction_data["transaction_id"],
        transaction_data["payment_time"],
        transaction_data["travel_date"],
        transaction_data["bus_timing"],
        transaction_data["isUsed"]
    )

    try:
        with conn.cursor() as cur:
            cur.execute(query, values)
            conn.commit()
            return True
    except Exception as e:
        conn.rollback()
        print(f"Error logging transaction: {e}")
        return False

def scan_qr(transaction_data: Dict[str, Any]) -> bool:
    """
    Function to log transaction data into PostgreSQL.
    """
    query = """
        UPDATE transactions
        SET isUsed = TRUE
        WHERE transaction_id = %s;
"""
    values = (
        transaction_data["transaction_id"],
    )

    try:
        with conn.cursor() as cur:
            cur.execute(query, values)
            conn.commit()
            return True
    except Exception as e:
        conn.rollback()
        print(f"Error logging transaction: {e}")
        return False