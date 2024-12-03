package controller

import (
	"fmt"
	"net/http"

	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
)

func GetAnnouncements(c *gin.Context) {
	announcements, _ := db.GetAllAnnouncements(c)
	c.JSON(http.StatusOK, announcements)
}

func PostAnnouncement(c *gin.Context) {
	var announcement schema.Announcement
	if c.BindJSON(&announcement) != nil {
		fmt.Printf("ERROR: Post Announcement Data could not bind\n")
	}
	db.PostAnnouncementToDB(c, &announcement)
	c.Status(http.StatusOK)
}
