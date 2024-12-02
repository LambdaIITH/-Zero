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

func PostAnnouncementToDB(c *gin.Context, announcement *schema.Announcement) error {
	query := `INSERT INTO announcements (title, description, createdat, createdby, tags) VALUES ($1, $2, $3, $4, $5)`
	_, err := config.DB.Exec(c, query, announcement.Title, announcement.Description, announcement.CreatedAt, announcement.CreatedBy, announcement.Tags)
	if err != nil {
		fmt.Printf("ERROR: Adding Announcement to DB\n")
		return err
	}
	return nil
}
