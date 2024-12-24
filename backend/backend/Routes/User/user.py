# queries/user.py

from typing import Optional, Dict
from pypika import Table, Query
from utils import conn 

users = Table("users")

def get_user(user_id: int) -> Optional[Dict[str, str]]:
    query = (Query.from_(users)
             .select('*')
             .where(users.id == user_id))

    with conn.cursor() as cursor:
        cursor.execute(query.get_sql(), (user_id,))
        user = cursor.fetchone()
    if user:
        return {
            "id": user[0],
            "email": user[1],
            "name": user[2],
            "cr": user[3],
            "phone_number": user[4]
        }
    return None

def update_phone(user_id: int, phone: str) -> Optional[Dict[str, str]]:
    query = """
    UPDATE users
    SET phone_number = %s
    WHERE id = %s
    RETURNING id, email, name, cr, phone_number
    """
    with conn.cursor() as cursor:
        cursor.execute(query, (phone, user_id))
        user = cursor.fetchone()
        conn.commit()
    if user:
        return {
            "id": user[0],
            "email": user[1],
            "name": user[2],
            "cr": user[3],
            "phone_number": user[4]
        }
    return None

def upsert_fcm_token(user_id: int, token: str, device_type: str) -> bool:
    """
    Insert or update (upsert) an FCM token record for the given user. 

    :param user_id:     The ID of the user for whom the token is being stored.
    :param token:       The FCM token to be inserted or updated.
    :param device_type: A string indicating the device type, 
                        e.g. "web", "android", "ios", etc.
                        
    :return:            True if the operation succeeded (insert or update), 
                        otherwise False.
    """
    
    query = """
        INSERT INTO fcm_tokens (user_id, token, device_type)
        VALUES (%s, %s, %s)
        ON CONFLICT (user_id, token)
        DO UPDATE
            SET device_type = EXCLUDED.device_type,
                token = EXCLUDED.token,
        RETURNING 1;
    """
    try:
        with conn.cursor() as cur:
            cur.execute(query, (user_id, token, device_type))
            row = cur.fetchone()

        conn.commit()

        # row will be None if no row was returned, otherwise it will contain (1, ).
        return bool(row)

    except Exception as e:
        conn.rollback()
        print(f"Error upserting FCM token for user_id={user_id}: {e}")
        return False
