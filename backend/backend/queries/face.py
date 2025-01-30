
from pypika import Query, Table, functions as fn, Order
from typing import Dict, Any

face_table, face_images_table = Table('face'), Table('face_images')
users = Table("users")
def insert_in_face_table( form_data: Dict[str, Any], user_id: int ): 
    query = Query.into(face_table).columns('face_name', 'face_description', 'user_id').insert(
        form_data['face_name'], form_data['face_description'], user_id
    )
    
    sql_query = query.get_sql()
    sql_query += " RETURNING *"
    
    return sql_query


def insert_face_images( image_paths: list, post_id: int): 

    query = Query.into(face_images_table).columns('image_url', 'face_id')

    for image_path in image_paths:
        query = query.insert(image_path, post_id)
    
    return query.get_sql()


def get_all_faces():
    query = """
            SELECT
                f.id,
                f.face_name,
                f.face_description,
                f.user_id,
                COALESCE(json_agg(fi.image_url) FILTER (WHERE fi.image_url IS NOT NULL), '[]') AS images,
                f.created_at
            FROM
                face f
            LEFT JOIN
                face_images fi ON f.id = fi.face_id
            GROUP BY
                f.id, f.face_name, f.face_description, f.user_id
            ORDER BY
                f.created_at DESC;
            """
            
    return query


def update_in_face_table( face_id: int, form_data: Dict[str, Any] ):
    query = Query.update(face_table)

    for key, value in form_data.items():
        if key == 'face_name' or key == 'face_description':
            query = query.set(face_table[key], value)

    query = query.where(face_table['id'] == face_id).get_sql()
    query += " RETURNING *"

    return query

def get_particular_face(face_id: int):
    query = (Query.from_(face_table)
             .join(users)
             .on(users['id'] == face_table['user_id'])
             .select('*')
             .where(face_table['id'] == face_id))
    return str(query)

def delete_an_face_images(face_id: int):
    query = Query.from_(face_images_table).delete().where(face_images_table['face_id'] == face_id)
    return str(query)

def get_all_image_uris(face_id : int):
    query = Query.from_(face_images_table).select('image_url').where(face_images_table['face_id'] == face_id)
    return str(query)

def search_faces(search_query: str, max_results: int= 10):
    query = (Query.from_(face_table)
    .select('*')
    .where(face_table['face_name'].ilike(f'%{search_query}%') | face_table['face_description'].ilike(f'%{search_query}%'))
    .orderby(face_table['created_at'], order=Order.desc)
    .limit(max_results)
    )
    return str(query)

def get_some_image_uris(face_ids : list):
    query = Query.from_(face_images_table).select(face_images_table['face_id'], face_images_table['image_url']).where(face_images_table['face_id'].isin(face_ids))
    return str(query)