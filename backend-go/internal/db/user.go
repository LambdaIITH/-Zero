package db

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"

	"github.com/LambdaIITH/Dashboard/backend/config"
)

// GetUserEmail retrieves the email of a user based on the ID.
func GetUserEmail(c context.Context, id int) (string, error) {
	query := `
        SELECT email
        FROM users
        WHERE id = $1;
    `
	var userEmail string
	err := config.DB.QueryRow(c, query, id).Scan(&userEmail)
	if err != nil {
		return "", err
	}
	return userEmail, nil
}

// GetPhoneNumber retrieves the phone number of a user based on the email.
func GetPhoneNumber(c context.Context, email string) (string, error) {
	query := `
        SELECT phone_number 
        FROM users 
        WHERE email = $1;
    `
	var phoneNumber string
	err := config.DB.QueryRow(c, query, email).Scan(&phoneNumber)
	if err != nil {
		return "", err
	}
	return phoneNumber, nil
}


func IsUserExists(ctx context.Context, email string) (bool, int, error) {
	var userID int
	query := `SELECT id FROM users WHERE email = $1`

	err := config.DB.QueryRow(ctx, query, email).Scan(&userID)
	if err != nil {
		if err == pgx.ErrNoRows {
			return false, 0, nil
		}
		return false, 0, fmt.Errorf("failed to check if user exists: %v", err)
	}

	return true, userID, nil
}

// InsertUser inserts a user and returns their ID, or an error if something goes wrong
func InsertUser(ctx context.Context, email string, name string) (int, error) {
	insertQuery := `INSERT INTO users (email, name) VALUES ($1, $2)`
	_, err := config.DB.Exec(ctx, insertQuery, email, name)
	if err != nil {
		return 0, fmt.Errorf("failed to insert user: %v", err)
	}

	// Retrieve the user ID
	selectQuery := `SELECT id FROM users WHERE email = $1`
	var userID int
	err = config.DB.QueryRow(ctx, selectQuery, email).Scan(&userID)
	if err != nil {
		return 0, fmt.Errorf("failed to retrieve user ID: %v", err)
	}

	return userID, nil
}

func AuthorizeEditDeleteItem(ctx context.Context, itemID int, userID int) (bool, error) {
	query := `SELECT user_id FROM lost WHERE id = $1`
	var ownerID int
	err := config.DB.QueryRow(ctx, query, itemID).Scan(&ownerID)
	if err != nil {
		return false, fmt.Errorf("failed to authorize edit/delete item: %v", err)
	}

	if ownerID != userID {
		return false, nil
	}

	return true, nil
}
