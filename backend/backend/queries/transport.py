from pypika import Query, Table, functions as fn, Order
from typing import Dict, Any, Optional
from utils import conn

def log_transaction_to_db(transaction_data: Dict[str, Any], user_id: int) -> bool:
    """
    Function to log transaction data into PostgreSQL.
    """
    query = """
    INSERT INTO transactions (transaction_id, payment_time, user_id, travel_date, bus_timing, isUsed, start, destination, amount)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
    """
    values = (
        transaction_data["transaction_id"],
        transaction_data["payment_time"],
        user_id,
        transaction_data["travel_date"],
        transaction_data["bus_timing"],
        transaction_data["isUsed"],
        transaction_data["start"],
        transaction_data["destination"],
        transaction_data["amount"] 
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


def get_last_transaction(user_id: int) -> Optional[Dict[str, Any]]:
    """
    Function to retrieve the most recent transaction data within the last 2 hours for a user from PostgreSQL.
    """
    query = """
    SELECT transaction_id, payment_time, travel_date, bus_timing, isUsed
    FROM transactions
    WHERE user_id = %s AND payment_time >= NOW() - INTERVAL '2 hours'
    ORDER BY payment_time DESC
    LIMIT 1
    """
    values = (user_id,)

    try:
        with conn.cursor() as cur:
            cur.execute(query, values)
            result = cur.fetchone()
            if result:
                columns = [desc[0] for desc in cur.description]
                transaction = dict(zip(columns, result))
                return transaction
            return None
    except Exception as e:
        conn.rollback()
        print(f"Error fetching transaction data: {e}")
        return None
