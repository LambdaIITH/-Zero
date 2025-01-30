package db

import (
	"context"
	"time"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/schema"
)

// CreateBooking inserts a new cab booking and returns the inserted booking ID.
func CreateBooking(c context.Context, startTime, endTime time.Time, capacity int, fromLoc, toLoc *int, ownerEmail, comments string) (int, error) {
	// Use config.DB for the database connection
	query := `
        INSERT INTO cab_booking (start_time, end_time, capacity, from_loc, to_loc, owner_email, comments)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id;
    `
	var bookingID int
	err := config.DB.QueryRow(c, query, startTime.Format("2006-01-02 15:04:05"), endTime.Format("2006-01-02 15:04:05"), capacity, fromLoc, toLoc, ownerEmail, comments).Scan(&bookingID)
	if err != nil {
		return 0, err
	}
	return bookingID, nil
}

// UpdateBooking updates the start and end time of a cab booking.
func UpdateBooking(c context.Context, cabID int, startTime, endTime time.Time) error {
	// Use config.DB for the database connection
	query := `
        UPDATE cab_booking
        SET start_time = $1, end_time = $2
        WHERE id = $3;
    `
	_, err := config.DB.Exec(c, query, startTime.Format("2006-01-02 15:04:05"), endTime, cabID)
	return err
}

// AddTraveller adds a traveller to a cab booking.
func AddTraveller(c context.Context, email string, cabID int, comments string) error {
	// Use config.DB for the database connection
	query := `
        INSERT INTO traveller (email, cab_id, comments)
        VALUES ($1, $2, $3);
    `
	_, err := config.DB.Exec(c, query, email, cabID, comments)
	return err
}

// GetOwnerEmail retrieves the owner email of a cab booking.
func GetOwnerEmail(c context.Context, cabID int) (string, error) {
	// Use config.DB for the database connection
	query := `
        SELECT owner_email
        FROM cab_booking
        WHERE id = $1;
    `
	var ownerEmail string
	err := config.DB.QueryRow(c, query, cabID).Scan(&ownerEmail)
	if err != nil {
		return "", err
	}
	return ownerEmail, nil
}

// DeleteBooking deletes a cab booking based on the provided cab ID.
func DeleteBooking(c context.Context, cabID int) error {
	// Use config.DB for the database connection
	query := `
        DELETE FROM cab_booking
        WHERE id = $1;
    `
	_, err := config.DB.Exec(c, query, cabID)
	return err
}

// DeleteParticularTraveller deletes a traveller from a particular cab booking,
// but only if the provided owner email matches the owner of the booking.
func DeleteParticularTraveller(c context.Context, cabID int, email, ownerEmail string) error {
	// Use config.DB for the database connection
	query := `
        DELETE FROM traveller
        WHERE cab_id = $1 AND email = $2
        AND $3 IN (SELECT owner_email FROM cab_booking WHERE id = $1);
    `
	_, err := config.DB.Exec(c, query, cabID, email, ownerEmail)
	return err
}

// GetUserPastBookings retrieves all past bookings for a user.
func GetUserPastBookings(c context.Context, email string) ([]schema.CabBooking, error) {
	query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.comments
        FROM cab_booking c
        INNER JOIN traveller t ON c.id = t.cab_id
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        WHERE t.email = $1
        AND c.end_time < (SELECT CURRENT_TIMESTAMP);
    `
	rows, err := config.DB.Query(c, query, email)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bookings []schema.CabBooking
	for rows.Next() {
		var b schema.CabBooking
		err := rows.Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromLoc, &b.ToLoc, &b.Comments)
		if err != nil {
			return nil, err
		}
		bookings = append(bookings, b)
	}

	return bookings, nil
}

// GetUserFutureBookings retrieves all future bookings for a user.
func GetUserFutureBookings(c context.Context, email string) ([]schema.CabBooking, error) {
	query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.comments
        FROM cab_booking c
        INNER JOIN traveller t ON c.id = t.cab_id
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        WHERE t.email = $1
        AND c.end_time > (SELECT CURRENT_TIMESTAMP);
    `
	rows, err := config.DB.Query(c, query, email)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bookings []schema.CabBooking
	for rows.Next() {
		var b schema.CabBooking
		err := rows.Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromLoc, &b.ToLoc, &b.Comments)
		if err != nil {
			return nil, err
		}
		bookings = append(bookings, b)
	}

	return bookings, nil
}

// FilterTimes retrieves bookings that overlap with the specified time range.
func FilterTimes(c context.Context, startTime, endTime time.Time) ([]schema.CabBooking, error) {
	query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.comments
        FROM cab_booking c
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        WHERE c.end_time > (SELECT CURRENT_TIMESTAMP)
        AND ((c.start_time <= $1 AND c.end_time >= $1)
          OR (c.end_time >= $2 AND c.start_time <= $2)
          OR ($1 <= c.start_time AND $2 >= c.end_time))
        ORDER BY c.start_time, c.end_time ASC;
    `
	rows, err := config.DB.Query(c, query, startTime, endTime)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bookings []schema.CabBooking
	for rows.Next() {
		var b schema.CabBooking
		err := rows.Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromLoc, &b.ToLoc, &b.Comments)
		if err != nil {
			return nil, err
		}
		bookings = append(bookings, b)
	}

	return bookings, nil
}

// FilterAll retrieves bookings based on location and time overlap.
func FilterAll(c context.Context, fromLoc, toLoc int, startTime, endTime time.Time) ([]schema.CabBooking, error) {
	query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.comments
        FROM cab_booking c
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        WHERE c.end_time > (SELECT CURRENT_TIMESTAMP)
        AND fl.id = $1 AND tl.id = $2
        AND ((c.start_time <= $3 AND c.end_time >= $3)
          OR (c.end_time >= $4 AND c.start_time <= $4)
          OR ($3 <= c.start_time AND $4 >= c.end_time))
        ORDER BY c.start_time, c.end_time ASC;
    `
	rows, err := config.DB.Query(c, query, fromLoc, toLoc, startTime, endTime)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bookings []schema.CabBooking
	for rows.Next() {
		var b schema.CabBooking
		err := rows.Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromLoc, &b.ToLoc, &b.Comments)
		if err != nil {
			return nil, err
		}
		bookings = append(bookings, b)
	}

	return bookings, nil
}

// GetTravellers retrieves all travellers for a specific cab booking.
func GetTravellers(c context.Context, cabID int) ([]schema.Traveller, error) {
	query := `
        SELECT t.email, t.cab_id, t.comments
        FROM traveller t
        INNER JOIN users u ON t.email = u.email
        WHERE t.cab_id = $1;
    `
	rows, err := config.DB.Query(c, query, cabID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var travellers []schema.Traveller
	for rows.Next() {
		var t schema.Traveller
		err := rows.Scan(&t.Email, &t.CabID, &t.Comments)
		if err != nil {
			return nil, err
		}
		travellers = append(travellers, t)
	}

	return travellers, nil
}

func GetLocationID(c context.Context, place string) (int, error) {
	query := `
		SELECT id
		FROM locations
		WHERE locations.place = $1;
	`
	var locID int
	err := config.DB.QueryRow(c, query, place).Scan(&locID)
	if err != nil {
		return 0, err
	}
	return locID, nil
}

// IsCabFull checks if a cab is full based on its capacity and the number of travellers.
func IsCabFull(c context.Context, cabID int) (bool, error) {
	query := `
        SELECT COUNT(*) >= (SELECT capacity FROM cab_booking WHERE id = $1)
        FROM traveller
        WHERE cab_id = $1;
    `
	var isFull bool
	err := config.DB.QueryRow(c, query, cabID).Scan(&isFull)
	if err != nil {
		return false, err
	}
	return isFull, nil
}

// Getschema.CabBooking retrieves the details of a specific cab booking by its ID.
func GetCabBooking(c context.Context, cabID int) (schema.CabBooking, error) {
	query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.comments
        FROM cab_booking c
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        WHERE c.id = $1;
    `
	var b schema.CabBooking
	err := config.DB.QueryRow(c, query, cabID).Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromLoc, &b.ToLoc, &b.Comments)
	if err != nil {
		return b, err
	}
	return b, nil
}

// CreateRequest inserts a new request into the database with a status of 'pending'.
func CreateRequest(c context.Context, bookingID int, email, comments string) error {
	query := `
        INSERT INTO request (status, booking_id, request_email, comments) 
        VALUES ('pending', $1, $2, $3)
        ON CONFLICT DO NOTHING;
    `
	_, err := config.DB.Exec(c, query, bookingID, email, comments)
	return err
}

// GetRequestStatus retrieves the status of a request.
func GetRequestStatus(c context.Context, bookingID int, email string) (string, error) {
	query := `
        SELECT status
        FROM request
        WHERE booking_id = $1 AND request_email = $2;
    `
	var status string
	err := config.DB.QueryRow(c, query, bookingID, email).Scan(&status)
	if err != nil {
		return "", err
	}
	return status, nil
}

// DeleteRequest cancels a pending request.
func DeleteRequest(c context.Context, bookingID int, email string) error {
	query := `
        UPDATE request
        SET status = 'cancelled'
        WHERE booking_id = $1 AND request_email = $2 AND status = 'pending';
    `
	_, err := config.DB.Exec(c, query, bookingID, email)
	return err
}

// GetUserPendingRequests retrieves the user's pending requests for future bookings.
func GetUserPendingRequests(c context.Context, email string) ([]schema.CabBooking, error) {
	query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.comments
        FROM cab_booking c
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        INNER JOIN request r ON r.booking_id = c.id
        WHERE r.request_email = $1
        AND r.status = 'pending'
        AND c.end_time > CURRENT_TIMESTAMP;
    `
	rows, err := config.DB.Query(c, query, email)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bookings []schema.CabBooking
	for rows.Next() {
		var booking schema.CabBooking
		if err := rows.Scan(&booking.ID, &booking.StartTime, &booking.EndTime, &booking.Capacity, &booking.FromLoc, &booking.ToLoc, &booking.Comments); err != nil {
			return nil, err
		}
		bookings = append(bookings, booking)
	}

	return bookings, nil
}

// UpdateRequest updates the status of a request and returns the comments.
func UpdateRequest(c context.Context, bookingID int, requestEmail string, status string) (string, error) {
	query := `
        UPDATE request
        SET status = $1
        WHERE booking_id = $2 AND request_email = $3 AND status = 'pending'
        RETURNING comments;
    `
	var comments string
	err := config.DB.QueryRow(c, query, status, bookingID, requestEmail).Scan(&comments)
	if err != nil {
		return "", err
	}
	return comments, nil
}

// GetName retrieves the name of a user based on the email.
func GetName(c context.Context, email string) (string, error) {
	query := `
        SELECT name
        FROM users 
        WHERE email = $1;
    `
	var userName string
	err := config.DB.QueryRow(c, query, email).Scan(&userName)
	if err != nil {
		return "", err
	}
	return userName, nil
}
