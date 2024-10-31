from typing import Dict, Union
import datetime
from datetime import datetime as DateTime
from typing import Dict, List, Union
import re
from fastapi import APIRouter, HTTPException, Request
from utils import conn
from models import Timetable
from queries import timetable as timetable_queries
from psycopg2.errors import ForeignKeyViolation, InFailedSqlTransaction
from typing import List, Dict
from constants import default_slots
from Routes.Auth.cookie import get_user_id
import regex as re
import uuid
router = APIRouter(prefix="/schedule", tags=["schedule"])


def validate_course_schedule(data: Dict) -> Union[str, bool]:
    """
    Validates the course schedule data structure.

    Parameters:
    - data (Dict): The course schedule data containing 'courses' and 'slots'.

    Returns:
    - Union[str, bool]: Returns True if the data is valid, otherwise returns a string error message.
    """
    try:
        # Validate 'courses' section
        courses = data['courses']
        if not isinstance(courses, dict):
            return "Invalid 'courses' format. Expected a dictionary."

        for course_code, course_info in courses.items():
            if not isinstance(course_info, dict):
                return f"Invalid course info for {course_code}. Expected a dictionary."
            if "title" not in course_info or not isinstance(course_info["title"], str):
                return f"Missing or invalid 'title' for course {course_code}."

        # Validate 'slots' section
        slots = data['slots']
        if not isinstance(slots, list):
            return "Invalid 'slots' format. Expected a list."

        valid_weekdays = ['Monday', 'Tuesday', 'Wednesday',
                          'Thursday', 'Friday', 'Saturday', 'Sunday']

        # Regex pattern to match time formats like "9:00 AM" or "10:30 PM"
        time_pattern = re.compile(
            r"^(1[0-2]|0?[1-9]):([0-5]\d)\s?(AM|PM)$", re.IGNORECASE)

        for slot in slots:
            if not isinstance(slot, dict):
                return "Each slot should be a dictionary."

            # Check required fields
            required_fields = ["course_code", "day", "start_time", "end_time"]
            for field in required_fields:
                if field not in slot:
                    return f"Missing field '{field}' in slot: {slot}"

            # Validate course_code
            course_code = slot["course_code"]
            if course_code not in courses:
                return f"Invalid 'course_code' {course_code} in slot: {slot}"

            # Validate day
            day = slot["day"]
            if day not in valid_weekdays:
                return f"Invalid 'day' {day} in slot: {slot}"

            # Validate time formats
            start_time_str = slot["start_time"]
            end_time_str = slot["end_time"]

            if not time_pattern.match(start_time_str):
                return f"Invalid 'start_time' format: {start_time_str} in slot: {slot}"
            if not time_pattern.match(end_time_str):
                return f"Invalid 'end_time' format: {end_time_str} in slot: {slot}"

            # Parse times to compare
            time_format = "%I:%M %p"
            start_time = DateTime.strptime(start_time_str.upper(), time_format)
            end_time = DateTime.strptime(end_time_str.upper(), time_format)

            if start_time >= end_time:
                return f"'start_time' {start_time_str} is not earlier than 'end_time' {end_time_str} in slot: {slot}"

        # If all validations pass
        return True

    except Exception as e:
        return f"An error occurred during validation: {e}"


@router.get("/courses")
def get_timetable(request: Request) -> Timetable:
    user_id = get_user_id(request)
    try:
        query = timetable_queries.get_timetable(user_id)
        with conn.cursor() as cur:
            cur.execute(query)
            courses = cur.fetchone()
            return Timetable.from_row(courses[0])
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error : {e}")


@router.post("/courses")
def post_edit_timetable(request: Request, timetable: Timetable):
    user_id = get_user_id(request)
    # sanity check
    course_codes = list(timetable.courses.keys())
    # check if custom_slot_codes are not same as default slots

    validation_result = validate_course_schedule(timetable)
    if not isinstance(validation_result, bool):
        raise HTTPException(status_code=400, detail=validation_result)

    try:
        query = timetable_queries.post_timetable(user_id, timetable)
        with conn.cursor() as cur:
            cur.execute(query)
            conn.commit()
        return {"message": "Timetable Updated Successfully"}
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error : {e}")


@router.get('/share/{code}')
def get_shared_timetable(code: str):
    try:
        query = timetable_queries.get_shared_timetable(code)
        with conn.cursor() as cur:
            cur.execute(query)
            timetable = cur.fetchone()
            if timetable is None:
                raise HTTPException(status_code=404, detail="Code Not Found")

            # convert a sql returned time string to DateTime Object\
            expiry = timetable[3]
            if expiry < DateTime.now():
                conn.commit()
                delete_query = timetable_queries.delete_shared_timetable(code)
                cur.execute(delete_query)
                conn.commit()
                raise HTTPException(
                    status_code=404, detail="Timetable has expired")

            return timetable[2]

    except HTTPException as e:
        raise e
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error : {e}")


def generate_random_code() -> str:
    return str(uuid.uuid4().hex[:6])


@router.post('/share')
def post_share_timetable(request: Request):
    """
    Generate a unique code for the timetable, store it in db and return it
    """

    user_id = get_user_id(request)
    code = ''
    try:
        query = timetable_queries.get_timetable(user_id)
        with conn.cursor() as cur:
            cur.execute(query)
            timetable = cur.fetchone()[0]

            cur_date = DateTime.now()
            expiry_days = 120
            expiry = cur_date + datetime.timedelta(days=expiry_days)
            while True:
                code = generate_random_code()
                insert_query = timetable_queries.post_shared_timetable(
                    code, user_id, timetable, expiry)

                try:
                    cur.execute(insert_query)
                    conn.commit()
                    return {"code": code}

                except Exception as e:
                    conn.rollback()
                    continue
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error : {e}")


@router.delete('/share/{code}')
def delete_shared_timetable(request: Request, code: str):
    user_id = get_user_id(request)
    # Check if user is the owner of this code
    try:
        query = timetable_queries.get_shared_timetable(code)
        with conn.cursor() as cur:
            cur.execute(query)
            timetable = cur.fetchone()
            if timetable is None:
                raise HTTPException(
                    status_code=404, detail="Timetable not found")

            if timetable[1] != user_id:
                raise HTTPException(
                    status_code=403, detail="You are not the owner of this timetable")

            query = timetable_queries.delete_shared_timetable(code)
            cur.execute(query)
            conn.commit()
            return {"message": "Timetable Deleted Successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error : {e}")
