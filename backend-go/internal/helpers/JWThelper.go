package helpers

import (
	"fmt"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

var jwtsecret = os.Getenv("JWT_SECRET")

func VerifyJWTToken(tokenString string) (jwt.MapClaims, error) {
	secretKey := []byte(jwtsecret)

	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return secretKey, nil
	})

	if err != nil {
		return nil, err
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if ok && token.Valid {
		return claims, nil
	}

	return nil, fmt.Errorf("invalid token")
}

func GenerateToken(id int, name string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"id":        id,
		"user_name": name,
		"exp":       time.Now().Add(time.Hour * 24 * 10).Unix(),
		"iat":       time.Now().Unix(),
		"iss":       "dashboard",
	})

	accesstoken, err := token.SignedString([]byte(jwtsecret))
	if err != nil {
		return "", err
	}

	return accesstoken, nil
}
