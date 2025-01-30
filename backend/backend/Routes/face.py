import os, shutil
import json
from fastapi import APIRouter, HTTPException, Request, status, UploadFile, File, Form
from typing import Dict, Any, List, Tuple
from Routes.Auth.cookie import get_user_id
from utils import *
from models import LfItem, LfResponse
from queries.face import *
from utils import S3Client
from .funcs import get_image_dict, authorize_edit_delete

router = APIRouter(prefix="/face", tags=["face"])

# add face item 
@router.post("/add_face")
async def add_item( request: Request,
                    form_data: str = Form(...),
                    images: List[UploadFile]  = File(default = None)
                    )  -> Dict[str, Any]:
    
    try:
        print("form_data", form_data)
        if images:
            print(f"Number of images received: {len(images)}")
            for image in images:
                print(f"Image filename: {image.filename}, Content Type: {image.content_type}")

        form_data_dict = json.loads(form_data)
        user_id = get_user_id(request)
        print("user_id", user_id)
        print("form_data_dict", form_data_dict)
        with conn.cursor() as cur:
            cur.execute( insert_in_face_table( form_data_dict, user_id ) )
            face = LfItem.from_row(cur.fetchone())
        
        # update in elasticsearch
        
        if images is not None:
            image_paths = S3Client.uploadToCloud(images, face.id, "face")

            with conn.cursor() as cur:
                cur.execute(insert_face_images(image_paths, face.id))
        conn.commit()
                
        return {"message": "Data inserted successfully"}


    except Exception as e: 
        conn.rollback()
        error_message = f"An error occurred: {e}"
        print(error_message)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_message)


# show all face names 
@router.get("/all")
async def get_all_face_names() -> List[Dict[str, Any]]:
    try:   
        with conn.cursor() as cur: 
            cur.execute("SELECT id,item_name FROM face ORDER BY created_at DESC")
            rows = cur.fetchall()
            
            cur.execute("SELECT face_id, image_url from face_images")
            images = cur.fetchall()
            image_dict = get_image_dict(images)
                
            rows = list(map(lambda x: {"id": x[0], "name": x[1], "images": image_dict.get(x[0], [])}, rows))
            return rows        
       
    except Exception as e: 
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="failed to fetch faces")
         

# show face with images 
@router.get("/face/{id}")
def show_faces(id: int) -> LfResponse:
    try:   
        with conn.cursor() as cur: 
            print('hello')
            cur.execute(get_particular_face(id))
            face = cur.fetchall()
            
            if face == []:
                raise HTTPException(status_code=404, detail="Face not found")
            face = face[0]
            cur.execute(get_all_image_uris(id))
            face_images = cur.fetchall()
            image_urls = list(map(lambda x: x[0], face_images))
            res = LfResponse.from_row(face, image_urls)
            return res
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch face: {e}")


# delete a face
@router.delete( "/delete_face" )
def delete_face( request: Request, face_id: int = Form(...)) -> Dict[str, str]: 
    user_id = get_user_id(request)
    try: 
        authorize_edit_delete("face", face_id, user_id, conn)
    except Exception as e: 
        raise HTTPException( status_code=500, detail= f"Error: {e}" )
    
    try: 
        with conn.cursor() as cur: 
            query = f"DELETE from face WHERE face.id = {face_id}"
            cur.execute( query )        
        S3Client.deleteFromCloud( face_id, "face" )
        conn.commit()
        return {"message": "Face deleted successfully!"}
               
    except Exception as e: 
        conn.rollback()
        raise HTTPException(status_code=500, detail="Failed to fetch face")         

@router.get("/search") 
def search(query : str, max_results: int = 100) -> List[Dict[str, Any]]:
    try: 
        with conn.cursor() as cur: 
            cur.execute( search_faces( query, max_results ) )
            res = cur.fetchall()
            if len(res) == 0:
                return []
            cur.execute(get_some_image_uris([x[0] for x in res]))
            images = cur.fetchall()
            
            image_dict = get_image_dict(images)
            res = list( map( lambda x: {"id": x[0], "name": x[1], "images": image_dict.get(x[0], [])}, res ) )
    
            
        return res
    except Exception as e: 
        raise HTTPException(status_code=500, detail=f"Error: {e}")
