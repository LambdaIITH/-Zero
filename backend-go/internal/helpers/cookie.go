package helpers

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

// setCookie sets a cookie with the given parameters
func SetCookie(w http.ResponseWriter, key string, value string, daysExpire int) {
	expiration := time.Now().Add(time.Duration(daysExpire) * 24 * time.Hour)
	http.SetCookie(w, &http.Cookie{
		Name:     key,
		Value:    value,
		Expires:  expiration,
		HttpOnly: true,
		Secure:   true,
		SameSite: http.SameSiteNoneMode,
		Path:     "/",
		MaxAge:   daysExpire * 24 * 60 * 60, // seconds
	})
}

// GetUserID retrieves the user ID from the request context
func GetUserID(c *gin.Context) (int, error) {
	return 1, nil
	userIDStr := c.Query("user_id")
	userID, error := strconv.Atoi(userIDStr)

	if error != nil {
		return 0, fmt.Errorf("error: User ID not found")
	}

	return userID, nil
}
