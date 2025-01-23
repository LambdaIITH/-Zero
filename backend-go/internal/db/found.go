// TODO: HAVE TO UPDATE QUERIES AFTER CHANGING THE SCHEMA OF LOST AND FOUND TABLES
package db

import (
	"context"
	"fmt"
	"strconv"
	"strings"

	"github.com/jackc/pgx/v5"
	_ "github.com/lib/pq"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
)

func InsertInFoundTable(ctx context.Context, form_data map[string]interface{}, user_ID int) (map[string]interface{}, error) {
	// Query to insert the lost item in the database
	query := `
        INSERT INTO found (item_name, item_description, user_id) 
        VALUES ($1, $2, $3) 
        RETURNING *
    `

	// Execute the query
	var result map[string]interface{}
	_, err := config.DB.Exec(ctx, query, form_data["item_name"], form_data["item_description"], user_ID)
	if err != nil {
		return nil, err
	}
	return result, nil
}

func InsertFoundImages(ctx context.Context, image_paths []string, post_id int) error {
	// Query to insert the lost item images in the database

	query := `INSERT INTO found_images (image_url, item_id) 
        VALUES ($1, $2)`

	// 	Execute the query
	for _, image_paths := range image_paths {
		_, err := config.DB.Exec(ctx, query, image_paths, post_id)
		if err != nil {
			return err
		}
	}

	return nil
}

func GetAllFoundItems(ctx context.Context) ([]schema.FoundItem, error) {
	// Query to get all the lost items from the database
	query := `
        SELECT
            f.id,
            f.item_name,
            f.item_description,
            f.user_id,
            COALESCE(json_agg(fi.image_url) FILTER (WHERE fi.image_url IS NOT NULL), '[]') AS images,
            f.created_at
        FROM
            found f
        LEFT JOIN
            found_images fi ON f.id = fi.item_id
        GROUP BY
            f.id, f.item_name, f.item_description, f.user_id
        ORDER BY
            f.created_at DESC;
	`
	// Execute the query
	var foundItems []schema.FoundItem

	rows, err := config.DB.Query(ctx, query)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var item schema.FoundItem
		if err := rows.Scan(&item.ID, &item.ItemName, &item.ItemDescription, &item.UserID, &item.Images, &item.CreatedAt); err != nil {
			return nil, err
		}
		foundItems = append(foundItems, item)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}
	return foundItems, nil
}
func UpdateInFoundTable(ctx context.Context, itemID int, formData map[string]interface{}) (schema.FoundItem, error) {
	validKeys := map[string]bool{
		"item_name":        true,
		"item_description": true,
	}

	// Prepare the SET clause and arguments
	setParts := []string{}
	args := []interface{}{}
	argID := 1

	for key, value := range formData {
		if validKeys[key] {
			setParts = append(setParts, key+" = $"+strconv.Itoa(argID))
			args = append(args, value)
			argID++
		}
	}

	if len(setParts) == 0 {
		return schema.FoundItem{}, pgx.ErrNoRows
	}

	query := "UPDATE found SET " + strings.Join(setParts, ", ")
	query += " WHERE id = $" + strconv.Itoa(argID) + " RETURNING *"
	args = append(args, itemID)

	var updatedItem schema.FoundItem

	row := config.DB.QueryRow(ctx, query, args...)
	err := row.Scan(
		&updatedItem.ID,
		&updatedItem.ItemName,
		&updatedItem.ItemDescription,
	)

	if err != nil {
		return updatedItem, err
	}

	return updatedItem, nil
}

func GetParticularFoundItem(ctx context.Context, item_id int) (schema.FoundItemWithUser, error) {
	// Query to get the particular lost item from the database
	query := `
  SELECT 
	  f.id,
	  f.item_name,
	  f.item_description,
	  f.user_id,
	  u.name,
	  f.created_at
  FROM
	 found f
  JOIN
	  users u ON f.user_id = u.id
  WHERE
	  f.id = $1
 `

	var foundItem schema.FoundItemWithUser
	err := config.DB.QueryRow(ctx, query, item_id).Scan(&foundItem)
	if err != nil {
		return foundItem, err
	}
	return foundItem, nil
}

func DeleteAnItemImagesFromFound(ctx context.Context, item_id int) (string, error) {
	// Query to delete the particular lost item from the database
	query := `
	DELETE FROM found_images
	WHERE item_id = $1
    `

	// Execute the query, passing the itemID as a parameter
	result_1, err := config.DB.Exec(ctx, query, item_id)
	if err != nil {
		return "0", err
	}

	// Get the number of rows affected (i.e., number of images deleted)
	rowsAffected := result_1.RowsAffected()
	result := strings.Join([]string{fmt.Sprintf("%d", rowsAffected), " images deleted"}, "")

	return result, nil
}

func DeleteAllImageURIsFromFound(ctx context.Context, itemID int) ([]string, error) {
	query := `
		SELECT image_url FROM found_images WHERE item_id = $1
	`

	var imageURLs []string
	rows, err := config.DB.Query(ctx, query, itemID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var imageURL string
		if err := rows.Scan(&imageURL); err != nil {
			return nil, err
		}
		imageURLs = append(imageURLs, imageURL)
	}

	if rows.Err() != nil {
		return nil, rows.Err()
	}

	return imageURLs, nil
}

func SearchLostItemsFromFound(ctx context.Context, searchQuery string) ([]schema.FoundItem, error) {
	maxResults := 10

	// Query to search for lost items
	query := `
	  SELECT *
	  FROM found
	  WHERE item_name ILIKE $1
	  ORDER BY created_at DESC
	  LIMIT $2
	`

	rows, err := config.DB.Query(ctx, query, "%"+searchQuery+"%", maxResults)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var foundItems []schema.FoundItem

	for rows.Next() {
		var item schema.FoundItem
		if err := rows.Scan(
			&item.ID,
			&item.ItemName,
			&item.ItemDescription,
			&item.CreatedAt,
		); err != nil {
			return nil, err
		}
		foundItems = append(foundItems, item)
	}

	if rows.Err() != nil {
		return nil, rows.Err()
	}

	return foundItems, nil
}

func GetSomeImgUrisFromFound(ctx context.Context, itemIDs []int) ([]schema.ImageURI, error) {
	if len(itemIDs) == 0 {
		return nil, nil
	}

	placeholders := make([]string, len(itemIDs))
	args := make([]interface{}, len(itemIDs))
	for i, id := range itemIDs {
		placeholders[i] = "$" + strconv.Itoa(i+1)
		args[i] = id
	}

	query := `
		SELECT item_id, image_url
		FROM found_images
		WHERE item_id IN (` + strings.Join(placeholders, ", ") + `)
	`

	rows, err := config.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var imageURIs []schema.ImageURI

	for rows.Next() {
		var imageURI schema.ImageURI
		if err := rows.Scan(&imageURI.ItemID, &imageURI.ImageURL); err != nil {
			return nil, err
		}
		imageURIs = append(imageURIs, imageURI)
	}

	if rows.Err() != nil {
		return nil, rows.Err()
	}

	return imageURIs, nil
}
