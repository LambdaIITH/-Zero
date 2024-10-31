from fastapi import APIRouter, HTTPException
import json
import os
import dotenv
from pydantic import BaseModel

router = APIRouter(prefix="/mess_menu", tags=["mess_menu"])
password = os.getenv("ADMIN_PASS")
allowed_numbers = [0,1,2,3]


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
async def post_mess_menu(admin: MenuWeekChangeRequest):
    if admin.password != password:
        raise HTTPException(status_code=403, detail="Incorrect password")
    
    if admin.number not in allowed_numbers:
        raise HTTPException(status_code=400, detail="Invalid week number")
    
    
    dir = os.path.dirname(os.path.realpath(__file__))
    with open(dir + "/config.json", "w") as file:
        json.dump({"week": admin.number}, file, indent=1)

    
    return {"message": "Week number updated successfully"}