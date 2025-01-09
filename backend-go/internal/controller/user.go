package controller

import (
	"net/http"

	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	"github.com/gin-gonic/gin"
)

type UserStruct struct {
	ID          int    `json:"id"`
	Email       string `json:"email"`
	Name        string `json:"name"`
	Cr          string `json:"cr"`
	PhoneNumber string `json:"phone_number"`
}

type UserUpdate struct {
	PhoneNumber string `json:"phone_number"`
}

type FCMTokensUpdate struct {
	Token      string `json:"token"`
	DeviceType string `json:"device_type"`
}

func User(c *gin.Context) {
	userId, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
	}

	userDetails := helpers.GetUser(userId)
	c.JSON(http.StatusOK, userDetails)

}

func UpdateUser(c *gin.Context) {
	userId, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
	}

	var userUpdate UserUpdate
	if err := c.ShouldBindJSON(&userUpdate); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userDetails := helpers.UpdatePhone(userId, userUpdate.PhoneNumber)
	c.JSON(http.StatusOK, userDetails)
}

func UpdateUserFCMToken(c *gin.Context) {
	userId, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
	}

	var fcmTokenUpdate FCMTokensUpdate
	if err := c.ShouldBindJSON(&fcmTokenUpdate); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if helpers.UpsertFCMToken(userId, fcmTokenUpdate.Token, fcmTokenUpdate.DeviceType) {
		c.JSON(http.StatusOK, gin.H{"message": "FCM Token updated successfully"})
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update FCM Token"})
	}
}
