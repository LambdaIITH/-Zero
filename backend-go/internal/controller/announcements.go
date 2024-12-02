package controller

import (
	"fmt"
	"net/http"

	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/gin-gonic/gin"
)

func GetAnnouncements(c *gin.Context) {
	announcements, _ := db.GetAllAnnouncements(c)
	fmt.Printf("%+v", announcements)
	c.JSON(http.StatusOK, announcements)
}
