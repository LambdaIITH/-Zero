package schema

import "time"

// UserDetails represents the details of a user
type UserDetails struct {
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	Name        string `json:"name"`
	Comments    string `json:"comments"`
}

// MAX_CAPACITY defines the maximum capacity for a booking
const MAX_CAPACITY = 25

// Booking represents the details of a booking
type Booking struct {
	ID         int           `json:"id"`
	StartTime  time.Time     `json:"start_time"`
	EndTime    time.Time     `json:"end_time"`
	Capacity   int           `json:"capacity" validate:"lte=MAX_CAPACITY"`
	FromLoc    string        `json:"from_loc"`
	ToLoc      string        `json:"to_loc"`
	OwnerEmail string        `json:"owner_email"`
	Travellers []UserDetails `json:"travellers"`
	Requests   []JoinBooking `json:"requests,omitempty"`
}

type JoinBookingStatus string

const (
	StatusPending   JoinBookingStatus = "pending"
	StatusAccepted  JoinBookingStatus = "accepted"
	StatusRejected  JoinBookingStatus = "rejected"
	StatusCancelled JoinBookingStatus = "cancelled"
)

// JoinBooking represents a request to join a booking
type JoinBooking struct {
	Status   JoinBookingStatus `json:"status"`
	Email    string            `json:"email"`
	Comments string            `json:"comments"`
}

// RequestResponse represents the requester's email
type RequestResponse struct {
	RequesterEmail string `json:"requester_email"`
}
