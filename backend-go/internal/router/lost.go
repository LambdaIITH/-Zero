package router

import (
	"context"
	"encoding/json"
	"net/http"
	"os"
	"strconv"
	"time"

	lost "github.com/LambdaIITH/Dashboard/backend/internal/db"
	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	schema "github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

type LfResponse struct {
	ID              int      `json:"id"`
	ItemName        string   `json:"item_name"`
	ItemDescription string   `json:"item_description"`
	UserID          int      `json:"user_id"`
	Images          []string `json:"images"`
	CreatedAt       string   `json:"created_at"`
	username        string
	user_email      string
}

var db *pgxpool.Pool

/*
The function verifies if a user has the permission to edit or delete an item.
*/
func authorizeEditDeleteItem(c *gin.Context, itemID int, currUserID int) error {
	row := db.QueryRow(context.Background(), "SELECT user_id FROM lost WHERE id = $1", itemID)

	var userID int
	err := row.Scan(&userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return err
	}

	if userID != currUserID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
		return nil
	}

	return nil
}

/*
AddItemHandler handles the addition of a new lost item.
It uploads the images to S3 and saves the image URLs in the database.
*/
func AddItemHandler(c *gin.Context) {
	// Step 1: Parse the form data
	formData := c.PostForm("form_data")
	var formDataDict map[string]interface{}
	if err := json.Unmarshal([]byte(formData), &formDataDict); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid form data"})
		return
	}

	// Step 2: Get the user ID
	userId, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	// Step 3: Insert the form data into the lost table
	var result map[string]interface{}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	result, err = lost.InsertInLostTable(ctx, formDataDict, userId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert data"})
		return
	}

	// Step 4: Get the ID of the inserted item
	currItem := schema.LostItem{}
	currItem.ID = result["id"].(int)

	// Step 5: Upload the images to S3 and save the image URLs in the database
	form, err := c.MultipartForm()
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file data"})
		return
	}
	files := form.File["images"]
	if len(files) > 0 {
		s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))

		imagePaths, err := s3Client.UploadImages(files, currItem.ID, "lost")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload images"})
			return
		}

		err = lost.InsertLostImages(ctx, imagePaths, currItem.ID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save image paths"})
			return
		}
	}

	// Step 6: Return the response
	c.JSON(http.StatusOK, gin.H{"message": "Data inserted successfully"})
}

/*
GetAllItemsHandler fetches all the lost items from the database and returns them as a JSON response.
*/
func GetAllItemsHandler(c *gin.Context) {
	// Step 1: Fetch all the lost items
	items, err := lost.GetAllLostItems(context.Background())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch items"})
		return
	}

	// Step 2: Fetch the image URLs associated with the items
	rows, err := db.Query(context.Background(), "SELECT item_id, image_url FROM lost_images")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch images"})
		return
	}
	defer rows.Close()

	// Step 3: Organize the image URLs by item ID
	imageDict := make(map[int][]string)
	for rows.Next() {
		var img schema.ImageURI
		if err := rows.Scan(&img.ItemID, &img.ImageURL); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to scan images"})
			return
		}
		imageDict[img.ItemID] = append(imageDict[img.ItemID], img.ImageURL)
	}

	// Step 4: Construct the response similar to Python (list of dicts with item_id, name, images)
	var response []map[string]interface{}
	for _, item := range items {
		itemImages := imageDict[item.ID]
		itemData := map[string]interface{}{
			"id":     item.ID,
			"name":   item.ItemName,
			"images": itemImages,
		}
		response = append(response, itemData)
	}

	// Step 5: Return the response
	c.JSON(http.StatusOK, response)
}

/*
GetItemByIdHandler fetches a particular lost item by its ID and returns it as a JSON response.
*/
func GetItemByIdHandler(c *gin.Context) {
	// Step 1: Parse the item ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}

	// Step 2: Fetch the item from the lost table
	item, err := lost.GetParticularLostItem(context.Background(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}

	// Step 3: Fetch the image URLs associated with the item
	var imageURLs []string
	rows, err := db.Query(context.Background(), "SELECT image_url FROM lost_images WHERE item_id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}
	defer rows.Close()

	// Step 4: Construct the response
	for rows.Next() {
		var imageURL string
		if err := rows.Scan(&imageURL); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan image URL"})
			return
		}
		imageURLs = append(imageURLs, imageURL)
	}

	response := LfResponse{
		ID:              item.ID,
		ItemName:        item.ItemName,
		ItemDescription: item.ItemDescription,
		UserID:          item.UserID,
		Images:          imageURLs,
		CreatedAt:       item.CreatedAt,
		username:        item.UserName,
	}

	// Step 5: Return the response
	c.JSON(http.StatusOK, response)
}

func DeleteItemHandler(c *gin.Context) {
	// step 1 : initialize the transaction
	tx, err := db.Begin(context.Background())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer func() {
		if err != nil {
			tx.Rollback(context.Background())
		} else {
			tx.Commit(context.Background())
		}
	}()

	// Step 2: Get the user ID
	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Step 3: Parse the item ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item id"})
		return
	}

	// Step 4: Authorize the user to delete the item
	err = authorizeEditDeleteItem(c, id, userID)
	if err != nil {
		return
	}

	// Step 5: Fetch the image URLs associated with the item
	rows, err := tx.Query(context.Background(), "SELECT image_url FROM lost_images WHERE item_id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}
	defer rows.Close()

	var imageURLs []string
	for rows.Next() {
		var imageURL string
		if err := rows.Scan(&imageURL); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan image URL"})
			return
		}
		imageURLs = append(imageURLs, imageURL)
	}

	// Step 6: Delete the item from the lost table
	_, err = tx.Exec(context.Background(), "DELETE FROM lost WHERE id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete item"})
		return
	}

	// Step 7: Delete the images from the lost_images table
	_, err = lost.DeleteItemImagesFromLost(context.Background(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete images from database"})
		return
	}

	// Step 8: Delete the images from S3 bucket
	s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))
	if err := s3Client.DeleteImages(imageURLs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete images from S3"})
		return
	}

	// Step 9: Return the response
	c.JSON(http.StatusOK, gin.H{"message": "Item deleted successfully"})
}

/*
EditItemHandler handles the editing of a lost item.
It edits the images in S3 and updates the image URLs in the database.
*/
func EditItemHandler(c *gin.Context) {
	// Step 1: Get the user ID
	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Step 2: Parse the item ID
	itemID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item id"})
		return
	}

	// Step 3: Authorize the user to edit the item
	err = authorizeEditDeleteItem(c, itemID, userID)
	if err != nil {
		return
	}

	// Step 4: Parse the form data
	var formData map[string]interface{}
	if err := json.NewDecoder(c.Request.Body).Decode(&formData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid form data"})
		return
	}

	// Step 5: Update the item in the lost table
	if _, err := lost.UpdateInLostTable(context.Background(), itemID, formData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to edit item"})
		return
	}

	// step 6: return the response
	c.JSON(http.StatusOK, gin.H{"message": "Item updated successfully"})
}

/*
SearchItemHandler fetches the lost items matching the query and returns them as a JSON response.
*/
func SearchItemHandler(c *gin.Context) {
	query := c.Query("query")

	// Step 1: Fetch lost items matching the query
	lostItems, err := lost.SearchLostItemsLost(context.Background(), query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch items"})
		return
	}

	var itemIDs []int
	for _, item := range lostItems {
		itemIDs = append(itemIDs, item.ID)
	}

	// Step 2: Fetch image URLs associated with the items
	imageRows, err := lost.GetSomeImgUrisLost(context.Background(), itemIDs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}

	// Step 3: Organize the image URLs by item ID
	imageDict := make(map[int][]string)
	for _, img := range imageRows {
		imageDict[img.ItemID] = append(imageDict[img.ItemID], img.ImageURL)
	}

	// Step 4: Construct the response
	var response []map[string]interface{}
	for _, item := range lostItems {
		response = append(response, map[string]interface{}{
			"id":               item.ID,
			"item_name":        item.ItemName,
			"item_description": item.ItemDescription,
			"user_id":          item.UserID,
			"created_at":       item.CreatedAt,
			"images":           imageDict[item.ID],
		})
	}

	// Step 5: Return the response with item details and images
	c.JSON(http.StatusOK, response)
}
