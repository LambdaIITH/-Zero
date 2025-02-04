package controller

import (
	"encoding/json"
	"net/http"
	"os"
	"strconv"

	"github.com/LambdaIITH/Dashboard/backend/config"
	lost "github.com/LambdaIITH/Dashboard/backend/internal/db"
	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	schema "github.com/LambdaIITH/Dashboard/backend/internal/schema"

	"github.com/gin-gonic/gin"
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
	result, err := lost.InsertInLostTable(c, formDataDict, userId)
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

		err = lost.InsertLostImages(c, imagePaths, currItem.ID)
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
	items, err := lost.GetAllLostItems(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch items"})
		return
	}

	// Step 2: Fetch the image URLs associated with the items
	rows, err := config.DB.Query(c, "SELECT item_id, image_url FROM lost_images")
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
	// Step 1: Fetch the item by its ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}
	item, err := lost.GetParticularLostItem(c, id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}

	// Step 2: Fetch the image URLs associated with the item
	var imageURLs []string
	rows, err := config.DB.Query(c, "SELECT image_url FROM lost_images WHERE item_id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}
	defer rows.Close()

	// Step 3: Construct the response
	for rows.Next() {
		var imageURL string
		if err := rows.Scan(&imageURL); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan image URL"})
			return
		}
		imageURLs = append(imageURLs, imageURL)
	}

	// Step 4: Return the response
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
	// Step 1: Get the user ID
	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Step 2: Get item ID from the request
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item id"})
		return
	}

	// Step 3: Check if the user is authorized to delete the item
	res, err := lost.AuthorizeEditDeleteItem(c, id, userID)
	if err != nil || !res {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Step 4: Delete images associated with the item
	// Get the image URLs associated with the item
	imageURLs, err := lost.DeleteAllImageUrisLost(c, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch images"})
		return
	}

	// Step 5: Delete the item from the lost table
	_, err = config.DB.Exec(c, "DELETE FROM lost WHERE id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete item"})
		return
	}

	// Step 6: Delete the images from the database
	// This step deletes the item images from the 'lost_images' table in the database
	_, err = lost.DeleteItemImagesFromLost(c, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete images from database"})
		return
	}

	// Step 7: Delete images from S3 storage
	s3Client := helpers.NewS3Client(os.Getenv("BUCKET_NAME"), os.Getenv("REGION"), os.Getenv("RESOURCE_URI"))
	if err := s3Client.DeleteImages(imageURLs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete images from S3"})
		return
	}

	// Step 8: Send a success response
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
	// Step 2: Check if the user is authorized to edit the item
	itemID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item id"})
		return
	}

	res, err := lost.AuthorizeEditDeleteItem(c, itemID, userID)
	if err != nil {
		return
	}

	if !res {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Step 3: Parse the form data
	var formData map[string]interface{}
	if err := json.NewDecoder(c.Request.Body).Decode(&formData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid form data"})
		return
	}

	if _, err := lost.UpdateInLostTable(c, itemID, formData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to edit item"})
		return
	}

	// Step 4: Upload the images to S3 and save the image URLs in the database
	c.JSON(http.StatusOK, gin.H{"message": "Item updated successfully"})
}

/*
SearchItemHandler fetches the lost items matching the query and returns them as a JSON response.
*/
func SearchItemHandler(c *gin.Context) {
	query := c.Query("query")

	// Step 1: Fetch lost items matching the query
	lostItems, err := lost.SearchLostItemsLost(c, query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch items"})
		return
	}

	var itemIDs []int
	for _, item := range lostItems {
		itemIDs = append(itemIDs, item.ID)
	}

	// Step 2: Fetch image URLs associated with the items
	imageRows, err := lost.GetSomeImgUrisLost(c, itemIDs)
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
			"images":           imageDict[item.ID], // Add the images for this item
		})
	}

	// Step 5: Return the response with item details and images
	c.JSON(http.StatusOK, response)
}
