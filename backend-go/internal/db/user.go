package db

import (
	"context"
	"fmt"

	"github.com/LambdaIITH/Dashboard/backend/config"
)

func IsUserExists(ctx context.Context, email string) (bool, int, error) {
	var userID int
	query := `SELECT id FROM users WHERE email = $1`

	err := config.DB.QueryRow(ctx, query, email).Scan(&userID)
	if err != nil {
		if err.Error() == "sql: no rows in result set" {
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
