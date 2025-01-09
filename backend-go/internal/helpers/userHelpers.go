package helpers

import (
	"context"

	"github.com/LambdaIITH/Dashboard/backend/config"
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

func GetUser(id int) UserStruct {
	query := "SELECT * FROM users WHERE id = ?"
	rows, err := config.DB.Query(context.Background(), query, id)
	if err != nil {
		return UserStruct{}
	}

	if rows.Next() {
		var user UserStruct
		err = rows.Scan(&user.ID, &user.Email, &user.Name, &user.Cr, &user.PhoneNumber)
		if err != nil {
			return UserStruct{}
		}
	} else {
		return UserStruct{}
	}
	return UserStruct{}
}

func UpdatePhone(id int, phone string) UserStruct {
	query := "UPDATE users SET phoneNumber = ? WHERE id = ? RETURNING id, email, name , cr, phone_number"

	rows, err := config.DB.Query(context.Background(), query, phone, id)
	if err != nil {
		return UserStruct{}
	}

	if rows.Next() {
		var user UserStruct
		err = rows.Scan(&user.ID, &user.Email, &user.Name, &user.Cr, &user.PhoneNumber)
		if err != nil {

			return UserStruct{}
		}

	} else {
		return UserStruct{}
	}
	return UserStruct{}
}

func UpsertFCMToken(id int, token string, deviceType string) bool {
	query := "INSERT INTO fcm_tokens (user_id, token, device_type) VALUES ($1, $2, $3) ON CONFLICT (user_id, token) DO UPDATE SET device_type = EXCLUDED.device_type, token = EXCLUDED.token,RETURNING 1; "

	rows, err := config.DB.Query(context.Background(), query, id, token, deviceType)

	if err != nil {
		return false
	}

	if rows.Next() {
		return true
	} else {
		return false
	}
}
