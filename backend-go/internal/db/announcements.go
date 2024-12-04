package db

import (
	"fmt"
	"os"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func GetAnnouncementsFromDB(c *gin.Context, limit int, offset int) ([]schema.AnnouncementWithImages, error) {

	query := `SELECT (id ,title, description, createdat, createdby, tags) FROM announcements ORDER BY createdat LIMIT $1 OFFSET $2`
	rows, err := config.DB.Query(c, query, limit, offset)
	defer rows.Close()

	if err != nil {
		fmt.Printf("ERROR: Querying Announcement Tables")
		return nil, err
	}
	var announcements []schema.AnnouncementWithImages

	for rows.Next() {
		var announcement schema.AnnouncementWithImages
		if err := rows.Scan(&announcement.Announcement); err != nil {
			fmt.Printf("Error: Scanning Rows for Announcements\n")
			return nil, err
		}
		//announcement.ImageUrl = os.Getenv("WEB_URL") + `\announcements\images\` + strconv.Itoa(announcement.ID)
		announcement.ImageUrl = os.Getenv("WEB_URL") + `\announcements\images\1.jpg`
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
