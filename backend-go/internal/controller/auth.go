package controller

import (
	"context"
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"

	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
)

// User data structure
type UserResponse struct {
	ID    int64  `json:"id"`
	Email string `json:"email"`
}


func LoginHandler(c *gin.Context) {
	var loginRequest schema.LoginRequest
	if err := c.BindJSON(&loginRequest); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request payload"})
		return
	}

	status, token, msg := HandleLogin(c, loginRequest.IDToken)

	if status {
		helpers.SetCookie(c.Writer, "session", token, 15) // Set cookie with 15 days expiry
		c.JSON(http.StatusOK, gin.H{"email": msg["email"], "id": msg["id"]})
	} else {
		c.JSON(http.StatusUnauthorized, gin.H{"error": msg})
	}
}

// Handle login
func HandleLogin(ctx context.Context, idToken string) (bool, string, map[string]interface{}) {
	// Step 1: Verify the ID token
	ok, data := helpers.VerifyIDToken(ctx, idToken)
	if !ok {
		return false, "", map[string]interface{}{"error": "Invalid ID token"}
	}

	// Step 2: Check if the email is valid (must be an IITH email)
	if !helpers.IsValidIITHEmail(data["email"].(string)) {
		return false, "", map[string]interface{}{"error": "Please use an IITH email"}
	}

	// Step 3: Check if the user already exists
	exists, userID, err := db.IsUserExists(ctx, data["email"].(string))
	if err != nil {
		// Handle the error if checking for existing user fails
		log.Fatalf("Error checking if user exists: %v", err)
		return false, "", map[string]interface{}{"error": "Error checking if user exists"}
	}

	if !exists {
		// Step 4: Insert new user if they don't exist
		userID, err = db.InsertUser(ctx, data["email"].(string), data["name"].(string))
		if err != nil {
			// Handle the error if inserting the user fails
			log.Fatalf("Error inserting user: %v", err)
			return false, "", map[string]interface{}{"error": "Error adding user"}
		}
	}

	// Now you can use userID for further steps

	// Step 5: Generate JWT token for the user
	token, err := GenerateToken(fmt.Sprint(userID))
	if err != nil {
		log.Printf("Token generation failed: %v", err)
		return false, "", map[string]interface{}{"error": "Token generation failed"}
	}

	// Return successful login response
	return true, token, map[string]interface{}{
		"id":    userID,
		"email": data["email"].(string),
	}
}


func LogoutHandler(c *gin.Context) {
	helpers.SetCookie(c.Writer, "session", "lambda-iith", 0)
	resp := make(map[string]string)
	resp["message"] = "Logged out"
	c.JSON(http.StatusOK, resp)
}
