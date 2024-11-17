from fastapi import APIRouter, HTTPException
import json
import os

router = APIRouter(prefix="/transport", tags=["transport_schedule"])
dir = os.path.dirname(os.path.realpath(__file__))


@router.get("/")
async def get_bus_schedule():
    try:
        file = open(dir + "/transport.json")
        menu = json.load(file)
        file.close()
        return menu
    except FileNotFoundError:
        raise HTTPException(
            status_code=500, detail="Transport Schedule file does not exist. Please make one."
        )


@router.get("/cityBus")
async def get_city_bus_schedule():
    try:
        file = open(dir + "/cityBus.json")
        menu = json.load(file)
        file.close()
        return menu
    except FileNotFoundError:
        raise HTTPException(
            status_code=500, detail="City Bus Schedule file does not exist. Please make one."
        )
