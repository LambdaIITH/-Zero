package controller

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"net/http"
	"os"
	"strconv"

	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func GetAnnouncements(c *gin.Context) {
	limit, err := strconv.Atoi(c.Query("limit"))
	if err != nil {
		c.Status(http.StatusBadRequest)
		return
	}

	offset, err := strconv.Atoi(c.Query("offset"))
	if err != nil {
		c.Status(http.StatusBadRequest)
		return
	}
	if limit == 0 {
		c.Status(http.StatusBadRequest)
		return
	}
	announcements, _ := db.GetAnnouncementsFromDB(c, limit, offset)
	c.JSON(http.StatusOK, announcements)
}

func PostAnnouncement(c *gin.Context) {
	var announcement schema.RequestAnnouncement
	if c.Bind(&announcement) != nil {
		fmt.Println("ERROR: Post Announcement Data could not bind")
		return
	}

	imgData, err := base64.StdEncoding.DecodeString(announcement.Base64Image)
	if err != nil {
		fmt.Println("ERROR: Invalid Base64 Format")
		c.Status(http.StatusBadRequest)
		return
	}
	_, format, err := image.DecodeConfig(bytes.NewReader(imgData))
	if err != nil {
		fmt.Println("ERROR: Corrupt Image Data")
		c.Status(http.StatusBadRequest)
		return
	}

	id, err := db.PostAnnouncementToDB(c, &announcement)
	if err != nil {
		fmt.Println("ERROR: PostAnnouncement Call to DB")
		c.Status(http.StatusBadRequest)
		return
	}

	fileName := strconv.Itoa(id) + "." + format
	err = os.WriteFile("announcementImages/"+fileName, imgData, 0644)
	if err != nil {
		fmt.Println("Error: Saving File to Disk")
		c.Status(http.StatusBadRequest)
		return
	}

	c.Status(http.StatusOK)
}
