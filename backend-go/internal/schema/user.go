package schema

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
