package db

import (
	"fmt"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func GetAnnouncementsFromDB(c *gin.Context, limit int, offset int) ([]schema.Announcement, error) {

	query := `SELECT (id,title, description, createdat, createdby, tags) FROM announcements ORDER BY id LIMIT $1 OFFSET $2`
	rows, err := config.DB.Query(c, query, limit, offset)

	if err != nil {
		fmt.Printf("ERROR: Querying Announcement Tables")
		return nil, err
	}
	var announcements []schema.Announcement

	for rows.Next() {
		var announcement schema.Announcement
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

func PostAnnouncementToDB(c *gin.Context, announcement *schema.RequestAnnouncement) error {
	query := `INSERT INTO announcements (title, description, createdat, createdby, tags) VALUES ($1, $2, $3, $4, $5)`
	_, err := config.DB.Exec(c, query, announcement.Title, announcement.Description, announcement.CreatedAt, announcement.CreatedBy, announcement.Tags)
	if err != nil {
		fmt.Printf("ERROR: Adding Announcement to DB\n")
		return err
	}
	return nil
}
