// TODO: HAVE TO UPDATE QUERIES AFTER CHANGING THE SCHEMA OF LOST AND FOUND TABLES
package db

import (
	"context"
	"fmt"
	"strings"

	_ "github.com/lib/pq"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
)

func InsertInLostTable(ctx context.Context, form_data map[string]interface{}, user_ID int) (int, error) {
	// Query to insert the lost item in the database
	query := `
        INSERT INTO lost (item_name, item_description, user_id) 
        VALUES ($1, $2, $3) 
        RETURNING id
    `

	// Execute the query and retrieve the inserted ID
	var lostId int
	err := config.DB.QueryRow(ctx, query, form_data["item_name"], form_data["item_description"], user_ID).Scan(&lostId)
	if err != nil {
		return 0, err
	}

	return lostId, nil
}


func InsertLostImages(ctx context.Context, image_paths []string, post_id int) error {
	// Query to insert the lost item images in the database

	query := `INSERT INTO lost_images (image_url, item_id) 
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

func GetAllLostItems(ctx context.Context) ([]schema.LostItem, error) {
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
            lost f
        LEFT JOIN
            lost_images fi ON f.id = fi.item_id
        GROUP BY
            f.id, f.item_name, f.item_description, f.user_id, f.created_at
        ORDER BY
            f.created_at DESC;
	`

	rows, err := config.DB.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var lostItems []schema.LostItem

	for rows.Next() {
		var item schema.LostItem
		var images []string

		if err := rows.Scan(
			&item.ID,
			&item.ItemName,
			&item.ItemDescription,
			&item.UserID,
			&images,
			&item.CreatedAt,
		); err != nil {
			return nil, err
		}

		item.Images = images
		lostItems = append(lostItems, item)
	}

	if rows.Err() != nil {
		return nil, rows.Err()
	}

	return lostItems, nil
}

func UpdateInLostTable(ctx context.Context, itemID int, formData map[string]interface{}) (schema.LostItem, error) {
	// Query to update the lost item in the database
	query := `
		UPDATE lost SET
	`

	// List to hold the SET clause of the query
	setParts := []string{}

	// Arguments to pass to the query
	args := []interface{}{}
	argID := 1

	// Loop to build the SET clause and arguments dynamically
	for key, value := range formData {
		if key == "item_name" || key == "item_description" {
			setParts = append(setParts, fmt.Sprintf("%s = $%d", key, argID))
			args = append(args, value)
			argID++
		}
	}

	// Join the parts of the SET clause
	query += strings.Join(setParts, ", ")

	// Add the WHERE clause to filter by item ID
	query += fmt.Sprintf(" WHERE id = $%d", argID)
	args = append(args, itemID)

	// Add RETURNING * to get the updated row
	query += " RETURNING *"

	var updatedItem schema.LostItem

	// Execute the query and scan the result into updatedItem
	err := config.DB.QueryRow(ctx, query, args...).Scan(
		&updatedItem.ID,
		&updatedItem.ItemName,
		&updatedItem.ItemDescription,
		&updatedItem.UserID,
		&updatedItem.Images,
		&updatedItem.CreatedAt,
	)
	if err != nil {
		return updatedItem, err
	}

	return updatedItem, nil
}

func GetParticularLostItem(ctx context.Context, itemID int) (schema.LostItemWithUser, error) {
	// Query to get the particular lost item from the database
	query := `
		SELECT 
			f.id,
			f.item_name,
			f.item_description,
			f.user_id,
			u.username,
			f.created_at
		FROM
			lost f
		JOIN
			users u ON f.user_id = u.id
		WHERE
			f.id = $1
	`

	// Execute the query and scan the result into lostItem
	var lostItem schema.LostItemWithUser
	err := config.DB.QueryRow(ctx, query, itemID).Scan(
		&lostItem.ID,
		&lostItem.ItemName,
		&lostItem.ItemDescription,
		&lostItem.UserID,
		&lostItem.UserName,
		&lostItem.CreatedAt,
	)
	if err != nil {
		return lostItem, err
	}

	return lostItem, nil
}

func DeleteItemImagesFromLost(ctx context.Context, itemID int) (string, error) {
	// Query to delete the particular lost item images from the database
	query := `
		DELETE FROM lost_images
		WHERE item_id = $1
	`

	// Execute the query, passing the itemID as a parameter
	result, err := config.DB.Exec(ctx, query, itemID)
	if err != nil {
		return "", err
	}

	// Get the number of rows affected (i.e., number of images deleted)
	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		return "No images deleted", nil
	}

	// Prepare a message with the number of images deleted
	resultMessage := fmt.Sprintf("%d images deleted", rowsAffected)
	return resultMessage, nil
}

func DeleteAllImageUrisLost(ctx context.Context, itemId int) ([]string, error) {
	// Query to delete the particular lost item from the database
	query := `
    SELECT image_url FROM lost_images WHERE item_id = $1 
  `

	var imageUrls []string
	rows, err := config.DB.Query(ctx, query, itemId)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	// Retrieve image URLs from the result set
	for rows.Next() {
		var imageUrl string
		if err := rows.Scan(&imageUrl); err != nil {
			return nil, err
		}
		imageUrls = append(imageUrls, imageUrl)
	}

	return imageUrls, nil
}

func SearchLostItemsLost(ctx context.Context, search_query string) ([]schema.LostItem, error) {
	max_results := 10
	// Query to search for lost items
	query := `
	  SELECT *
	  FROM lost
	  WHERE item_name ILIKE $1
	  ORDER BY created_at DESC
	  LIMIT $2
	`

	// Execute the query
	var lostItems []schema.LostItem
	rows, err := config.DB.Query(ctx, query, "%"+search_query+"%", max_results)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	// Retrieve image URLs from the result set
	for rows.Next() {
		var lostItem schema.LostItem
		if err := rows.Scan(&lostItem.ID, &lostItem.ItemName, &lostItem.ItemDescription, &lostItem.UserID, &lostItem.Images, &lostItem.CreatedAt); err != nil {
			return nil, err
		}
		lostItems = append(lostItems, lostItem)
	}

	return lostItems, nil
}

func GetSomeImgUrisLost(ctx context.Context, itemIDs []int) ([]schema.ImageURI, error) {
	placeholders := make([]string, len(itemIDs))
	args := make([]interface{}, len(itemIDs))

	for i, id := range itemIDs {
		placeholders[i] = fmt.Sprintf("$%d", i+1)
		args[i] = id
	}

	query := fmt.Sprintf(`
		SELECT item_id, image_url
		FROM lost_images
		WHERE item_id IN (%s)
	`, strings.Join(placeholders, ", "))

	var imageURIs []schema.ImageURI

	rows, err := config.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var imageURI schema.ImageURI
		if err := rows.Scan(&imageURI.ItemID, &imageURI.ImageURL); err != nil {
			return nil, err
		}
		imageURIs = append(imageURIs, imageURI)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return imageURIs, nil
}
