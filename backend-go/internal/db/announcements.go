package db

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func GetAnnouncementsFromDB(c *gin.Context, limit int, offset int) ([]schema.AnnouncementWithImages, error) {

	imgFilesEntry, err := os.ReadDir("announcementImages/")
	var imgFileNames [][]string

	for _, val := range imgFilesEntry {
		imgFileNames = append(imgFileNames, strings.Split(val.Name(), "."))
	}
	if err != nil {
		fmt.Println("ERROR: Could not get image filenames")
		return nil, err
	}

	query := `SELECT (id ,title, description, createdat, createdby, tags) FROM announcements ORDER BY createdat DESC LIMIT $1 OFFSET $2`
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

		hasImg := false
		for _, val := range imgFileNames {
			if val[0] == strconv.Itoa(announcement.ID) {
				hasImg = true
				announcement.ImageUrl = `/announcements/images/` + val[0] + "." + val[1]
				break
			}
		}
		if hasImg {
			announcements = append(announcements, announcement)
		} else {
			fmt.Println("ERROR: Announcement does not have any corresponding image")
		}
	}

	if rows.Err() != nil {
		fmt.Printf("Error: Getting Rows from announcements\n")
		return nil, rows.Err()
	}

	return announcements, nil
}

func PostAnnouncementToDB(c *gin.Context, announcement *schema.RequestAnnouncement) (int, error) {
	query := `INSERT INTO announcements (title, description, createdat, createdby, tags) VALUES ($1, $2, $3, $4, $5)`
	_, err := config.DB.Exec(c, query, announcement.Title, announcement.Description, announcement.CreatedAt, announcement.CreatedBy, announcement.Tags)
	if err != nil {
		fmt.Printf("ERROR: Adding Announcement to DB\n")
		return 0, err
	}

	query = `SELECT id FROM announcements WHERE createdat=$1 AND createdby=$2`
	rows := config.DB.QueryRow(c, query, announcement.CreatedAt, announcement.CreatedBy)
	var id int
	if rows.Scan(&id) != nil {
		fmt.Println("ERROR: Getting ID of added Annoucment by POST")
	}

	return id, nil
}
