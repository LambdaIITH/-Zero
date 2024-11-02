from fastapi import APIRouter, HTTPException, Depends, Request
import json
import os
import dotenv
from pydantic import BaseModel
from Routes.Auth.cookie import get_user_id
from Routes.User.user import get_user
from Routes.Auth.tokens import verify_token

router = APIRouter(prefix="/mess_menu", tags=["mess_menu"])
password = os.getenv("ADMIN_PASS")
allowed_numbers = [0,1,2,3]

admins = ["ms22btech11010@iith.ac.in", "lambda@iith.ac.in", "ma22btech11003@iith.ac.in", "cs22btech11017@iith.ac.in", "cs22btech11028@iith.ac.in"]


class MenuWeekChangeRequest(BaseModel):
    password: str
    number: int

@router.get("/")
async def get_mess_menu():
    try:    
        dir = os.path.dirname(os.path.realpath(__file__))
        with open(dir + "/config.json") as file:
            week = json.load(file)["week"]
            
        
        file = open(dir + f"/{week}.json")
        menu = json.load(file)
        file.close()
        return menu
    except FileNotFoundError:
        raise HTTPException(
            status_code=500, detail="Mess menu file does not exist. Please make one."
        )
        

@router.post("/")
async def post_mess_menu(admin: MenuWeekChangeRequest, request: Request):
    isAdmin = False
    user_id = None
        
    try:
        token = request.cookies.get("session")
        if token:
            status, data = verify_token(token)
            if status:
                user_id = data["sub"] 
        
        if user_id:
            user_details = get_user(user_id=user_id)
        if user_details['email'] in admins:
            isAdmin = True
    except HTTPException:
        isAdmin = False 
            
    if not isAdmin and admin.password != password:
        raise HTTPException(status_code=401, detail="Incorrect password")
    
    if admin.number not in allowed_numbers:
        raise HTTPException(status_code=400, detail="Invalid week number")
    
    
    dir = os.path.dirname(os.path.realpath(__file__))
    with open(dir + "/config.json", "w") as file:
        json.dump({"week": admin.number}, file, indent=1)

    return {"message": "Week number updated successfully"}


@router.get("/week")
async def get_current_week_number(request: Request):
    isAdmin = False
    user_id = None
    
    try:
        user_id = get_user_id(request)
        print(user_id)
        user_details = get_user(user_id=user_id)
        if user_details['email'] in admins:
            isAdmin = True
    except HTTPException:
        isAdmin = False 
    
    if not isAdmin :
        return {"message" :"unauthorized"} 
    try:    
        dir = os.path.dirname(os.path.realpath(__file__))
        with open(dir + "/config.json") as file:
            week = json.load(file)["week"]
            
        return {"week": week}
    except FileNotFoundError:
        raise HTTPException(
            status_code=500, detail="Mess menu file does not exist. Please make one."
        )
        