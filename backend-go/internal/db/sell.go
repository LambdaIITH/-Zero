package db

import (
	"context"
	"fmt"
	"strconv"
	"strings"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/jackc/pgx/v5"
)

/*
this is heavily simillar to found.go
as here user owns the object
*/

func InsertInSellTable(ctx context.Context, form_data map[string]interface{}, user_ID int) (map[string]interface{}, error) {
	query := `
	 	INSERT INTO sell (item_name,item_description,user_id)
		VALUES ($1,$2,$3)
		RETURNING *
	 `

	var result map[string]interface{}
	_, err := config.DB.Exec(ctx, query, form_data["item_name"], form_data["item_description"], user_ID)
	if err != nil {
		return nil, err
	}
	return result, nil
}

func InsertSellImages(ctx context.Context, image_paths []string, post_id int) error {
	query := `INSERT INTO sell_images (image_path, post_id) VALUES ($1,$2)`

	for _, image_paths := range image_paths {
		_, err := config.DB.Exec(ctx, query, image_paths, post_id)
		if err != nil {
			return err
		}
	}
	return nil
}

func GetAllSellItems(ctx context.Context) ([]schema.SellItem, error) {
	query := `
 					SELECT
            f.id,
            f.item_name,
            f.item_description,
            f.user_id,
            COALESCE(json_agg(fi.image_url) FILTER (WHERE fi.image_url IS NOT NULL), '[]') AS images,
            f.created_at
        FROM
            sell f
        LEFT JOIN
            sell_images fi ON f.id = fi.item_id
        GROUP BY
            f.id, f.item_name, f.item_description, f.user_id
        ORDER BY
            f.created_at DESC;
						`
	// execute query

	var sellItems []schema.SellItem

	rows, err := config.DB.Query(ctx, query)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var item schema.SellItem
		var images []string
		err := rows.Scan(&item.ID, &item.ItemName, &item.ItemDescription, &item.UserID, &images, &item.CreatedAt)
		if err != nil {
			return nil, err
		}
		item.Images = images
		sellItems = append(sellItems, item)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	return sellItems, nil

}

func UpdateInSellTable(ctx context.Context, itemID int, formData map[string]interface{}) (schema.SellItem, error) {
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
		return schema.SellItem{}, pgx.ErrNoRows
	}

	query := "UPDATE sell SET " + strings.Join(setParts, ", ")
	query += " WHERE id = $" + strconv.Itoa(argID) + " RETURNING *"
	args = append(args, itemID)

	var updatedItem schema.SellItem

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

func GetParticularSellItem(ctx context.Context, item_id int) (schema.SellItemWithUser, error) {
	query := `
  SELECT 
	  f.id,
	  f.item_name,
	  f.item_description,
	  f.user_id,
	  u.name,
	  f.created_at
  FROM
	 sell f
  JOIN
	  users u ON f.user_id = u.id
  WHERE
	  f.id = $1
 `

	var sellItem schema.SellItemWithUser
	err := config.DB.QueryRow(ctx, query, item_id).Scan(&sellItem)
	if err != nil {
		return sellItem, err
	}
	return sellItem, nil
}

func DeleteAnItemImagesFromSell(ctx context.Context, item_id int) (string, error) {
	query := `
	DELETE FROM sell_images WHERE item_id = $1`

	result_1, err := config.DB.Exec(ctx, query, item_id)
	if err != nil {
		return "0", err
	}

	rowsAffected := result_1.RowsAffected()
	result := strings.Join([]string{fmt.Sprintf("%d", rowsAffected), " images deleted"}, "")
	return result, err
}

func DeleteAllImageURIsFromSell(ctx context.Context, itemID int) ([]string, error) {

	query := `
		SELECT image_url FROM sell_images WHERE item_id = $1
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

func SearchBuyItemsFromSell(ctx context.Context, searchQuery string) ([]schema.SellItem, error) {
	maxResults := 10

	// Query to search for sell items
	query := `
	  SELECT *
	  FROM sell
	  WHERE item_name ILIKE $1
	  ORDER BY created_at DESC
	  LIMIT $2
	`

	rows, err := config.DB.Query(ctx, query, "%"+searchQuery+"%", maxResults)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sellItems []schema.SellItem

	for rows.Next() {
		var item schema.SellItem
		if err := rows.Scan(
			&item.ID,
			&item.ItemName,
			&item.ItemDescription,
			&item.CreatedAt,
		); err != nil {
			return nil, err
		}
		sellItems = append(sellItems, item)
	}

	if rows.Err() != nil {
		return nil, rows.Err()
	}

	return sellItems, nil
}

func GetSomeImgUrisFromSell(ctx context.Context, itemIDs []int) ([]schema.ImageURI, error) {

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
		FROM sell_images
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
