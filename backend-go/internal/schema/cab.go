package schema

import "time"

type CabBooking struct {
	ID        int       `json:"id"`
	StartTime time.Time `json:"start_time"`
	EndTime   time.Time `json:"end_time"`
	Capacity  int       `json:"capacity"`
	FromLoc   string    `json:"from_loc"`
	ToLoc     string    `json:"to_loc"`
	Comments  string    `json:"comments"`
}

type Traveller struct {
	Email    string
	CabID    int
	Comments string
}

type RequestResponse struct {
	RequesterEmail string `json:"requester_email"`
}
