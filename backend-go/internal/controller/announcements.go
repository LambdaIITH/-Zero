package controller

import (
	"fmt"
	"net/http"
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
	if c.BindJSON(&announcement) != nil {
		fmt.Printf("ERROR: Post Announcement Data could not bind\n")
		return
	}
	db.PostAnnouncementToDB(c, &announcement)
	c.Status(http.StatusOK)
}
