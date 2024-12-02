package db

import (
	"fmt"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func GetAllAnnouncements(c *gin.Context) ([]schema.Announcement, error) {

	query := `SELECT (title, description, createdat, createdby, tags) FROM announcements`
	rows, err := config.DB.Query(c, query)

	if err != nil {
		fmt.Printf("ERROR: Querying Announcement Tables")
		return nil, err
	}

	var announcements []schema.Announcement

	for rows.Next() {
		var announcement schema.Announcement
		val, _ := rows.Values()
		fmt.Printf("%+v\n", val)
		if err := rows.Scan(&announcement); err != nil {
			fmt.Printf("Error: Scanning Rows for Announcements\n")
			return nil, err
		}
		announcements = append(announcements, announcement)
	}

	if rows.Err() != nil {
		fmt.Printf("Error: Getting Rows from announcements\n")
		return nil, rows.Err()
	}

	return announcements, nil
}
