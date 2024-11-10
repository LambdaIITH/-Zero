package middlewares

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/LambdaIITH/Dashboard/backend/internal/helpers"
)

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		token, err := c.Cookie("session")

		if err != nil || token == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or missing authentication token"})
			c.Abort()
			return
		}

		claims, err := helpers.VerifyJWTToken(token)
		if err != nil {
			fmt.Println("Token verification failed:", err)
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
		} else {
			// not suggested to store email in cookie
			// here we retrieve email stored in cookie and pass it via context
			c.Set("id", claims["id"])
		}
		c.Next()
	}
}
