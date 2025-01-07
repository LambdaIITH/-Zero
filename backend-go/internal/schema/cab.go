package schema

import "time"

type Location struct {
	ID    int64  `db:"id"`
	Place string `db:"place"`
}

type User struct {
	ID          int64  `json:"id"`
	Email       string `json:"email"`
	Name        string `json:"name"`
	Cr          bool   `json:"cr"`
	PhoneNumber string `json:"phone_number"`
}

type CabBooking struct {
	ID           int64
	StartTime    time.Time
	EndTime      time.Time
	Capacity     int
	FromLoc      int
	ToLoc        int
	FromLocation string
	ToLocation   string
	OwnerEmail   string
	Name         string
	PhoneNumber  string
	Comments     string
}

type Traveller struct {
	Email       string
	Name        string
	PhoneNumber string
	CabID       int
	Comments    string
}

type RequestStatus string

const (
	Pending   RequestStatus = "pending"
	Accepted  RequestStatus = "accepted"
	Rejected  RequestStatus = "rejected"
	Cancelled RequestStatus = "cancelled"
)

type Request struct {
	Status       RequestStatus
	BookingID    int
	RequestEmail string
	Comments     *string
}
