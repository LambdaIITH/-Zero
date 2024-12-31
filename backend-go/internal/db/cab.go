import (
    "database/sql"
    "context"
    "time"
    "github.com/LambdaIITH/Dashboard/backend-go/config"  
    schema "github.com/LambdaIITH/Dashboard/backend-go/internal/schema"
)

// CreateBooking inserts a new cab booking and returns the inserted booking ID.
func CreateBooking(c *gin.context, startTime, endTime time.Time, capacity int, fromLoc, toLoc *int, ownerEmail, comments string) (int64, error) {
    // Use config.DB for the database connection
    query := `
        INSERT INTO cab_booking (start_time, end_time, capacity, from_loc, to_loc, owner_email, comments)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id;
    `
    var bookingID int64
    err := config.DB.QueryRow(query, startTime, endTime, capacity, fromLoc, toLoc, ownerEmail, comments).Scan(&bookingID)
    if err != nil {
        return 0, err
    }
    return bookingID, nil
}

// UpdateBooking updates the start and end time of a cab booking.
func UpdateBooking(c *gin.context, cabID int64, startTime, endTime time.Time) error {
    // Use config.DB for the database connection
    query := `
        UPDATE cab_booking
        SET start_time = $1, end_time = $2
        WHERE id = $3;
    `
    _, err := config.DB.Exec(query, startTime, endTime, cabID)
    return err
}

// AddTraveller adds a traveller to a cab booking.
func AddTraveller(c *gin.context, email string, cabID int, comments string) error {
    // Use config.DB for the database connection
    query := `
        INSERT INTO traveller (email, cab_id, comments)
        VALUES ($1, $2, $3);
    `
    _, err := config.DB.Exec(query, email, cabID, comments)
    return err
}

// GetOwnerEmail retrieves the owner email of a cab booking.
func GetOwnerEmail(c *gin.context, cabID int64) (string, error) {
    // Use config.DB for the database connection
    query := `
        SELECT owner_email
        FROM cab_booking
        WHERE id = $1;
    `
    var ownerEmail string
    err := config.DB.QueryRow(query, cabID).Scan(&ownerEmail)
    if err != nil {
        return "", err
    }
    return ownerEmail, nil
}

// DeleteBooking deletes a cab booking based on the provided cab ID.
func DeleteBooking(c *gin.context, cabID int64) error {
    // Use config.DB for the database connection
    query := `
        DELETE FROM cab_booking
        WHERE id = $1;
    `
    _, err := config.DB.Exec(query, cabID)
    return err
}

// DeleteParticularTraveller deletes a traveller from a particular cab booking, 
// but only if the provided owner email matches the owner of the booking.
func DeleteParticularTraveller(c *gin.context, cabID int64, email, ownerEmail string) error {
    // Use config.DB for the database connection
    query := `
        DELETE FROM traveller
        WHERE cab_id = $1 AND email = $2
        AND $3 IN (SELECT owner_email FROM cab_booking WHERE id = $1);
    `
    _, err := config.DB.Exec(query, cabID, email, ownerEmail)
    return err
}

// GetUserPastBookings retrieves all past bookings for a user.
func GetUserPastBookings(c *gin.context, email string) ([]BookingDetails, error) {
    query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.owner_email, u.name, u.phone_number
        FROM cab_booking c
        INNER JOIN traveller t ON c.id = t.cab_id
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        WHERE t.email = $1
        AND c.end_time < (SELECT CURRENT_TIMESTAMP);
    `
    rows, err := config.DB.Query(query, email)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var bookings []BookingDetails
    for rows.Next() {
        var b BookingDetails
        err := rows.Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromPlace, &b.ToPlace, &b.OwnerEmail, &b.Name, &b.PhoneNumber)
        if err != nil {
            return nil, err
        }
        bookings = append(bookings, b)
    }

    return bookings, nil
}

// GetUserFutureBookings retrieves all future bookings for a user.
func GetUserFutureBookings(c *gin.context, email string) ([]BookingDetails, error) {
    query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.owner_email, u.name, u.phone_number
        FROM cab_booking c
        INNER JOIN traveller t ON c.id = t.cab_id
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        WHERE t.email = $1
        AND c.end_time > (SELECT CURRENT_TIMESTAMP);
    `
    rows, err := config.DB.Query(query, email)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var bookings []BookingDetails
    for rows.Next() {
        var b BookingDetails
        err := rows.Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromPlace, &b.ToPlace, &b.OwnerEmail, &b.Name, &b.PhoneNumber)
        if err != nil {
            return nil, err
        }
        bookings = append(bookings, b)
    }

    return bookings, nil
}

// GetAllActiveBookings retrieves all active bookings that haven't ended yet.
func GetAllActiveBookings(c *gin.context) ([]BookingDetails, error) {
    query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.owner_email, u.name, u.phone_number
        FROM cab_booking c
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        WHERE c.end_time > (SELECT CURRENT_TIMESTAMP);
    `
    rows, err := config.DB.Query(query)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var bookings []BookingDetails
    for rows.Next() {
        var b BookingDetails
        err := rows.Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromPlace, &b.ToPlace, &b.OwnerEmail, &b.Name, &b.PhoneNumber)
        if err != nil {
            return nil, err
        }
        bookings = append(bookings, b)
    }

    return bookings, nil
}

// FilterTimes retrieves bookings that overlap with the specified time range.
func FilterTimes(c *gin.context, startTime, endTime time.Time) ([]BookingDetails, error) {
    query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.owner_email, u.name, u.phone_number
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
    rows, err := config.DB.Query(query, startTime, endTime)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var bookings []BookingDetails
    for rows.Next() {
        var b BookingDetails
        err := rows.Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromPlace, &b.ToPlace, &b.OwnerEmail, &b.Name, &b.PhoneNumber)
        if err != nil {
            return nil, err
        }
        bookings = append(bookings, b)
    }

    return bookings, nil
}

// FilterAll retrieves bookings based on location and time overlap.
func FilterAll(c *gin.context, fromLoc, toLoc int, startTime, endTime time.Time) ([]BookingDetails, error) {
    query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.owner_email, u.name, u.phone_number
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
    rows, err := config.DB.Query(query, fromLoc, toLoc, startTime, endTime)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var bookings []BookingDetails
    for rows.Next() {
        var b BookingDetails
        err := rows.Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromPlace, &b.ToPlace, &b.OwnerEmail, &b.Name, &b.PhoneNumber)
        if err != nil {
            return nil, err
        }
        bookings = append(bookings, b)
    }

    return bookings, nil
}

// GetTravellers retrieves all travellers for a specific cab booking.
func GetTravellers(c *gin.context, cabID int64) ([]TravellerDetails, error) {
    query := `
        SELECT t.email, t.comments, u.name, u.phone_number
        FROM traveller t
        INNER JOIN users u ON t.email = u.email
        WHERE t.cab_id = $1;
    `
    rows, err := config.DB.Query(query, cabID)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var travellers []TravellerDetails
    for rows.Next() {
        var t TravellerDetails
        err := rows.Scan(&t.Email, &t.Comments, &t.Name, &t.PhoneNumber)
        if err != nil {
            return nil, err
        }
        travellers = append(travellers, t)
    }

    return travellers, nil
}

// IsCabFull checks if a cab is full based on its capacity and the number of travellers.
func IsCabFull(c *gin.context, cabID int64) (bool, error) {
    query := `
        SELECT COUNT(*) >= (SELECT capacity FROM cab_booking WHERE id = $1)
        FROM traveller
        WHERE cab_id = $1;
    `
    var isFull bool
    err := config.DB.QueryRow(query, cabID).Scan(&isFull)
    if err != nil {
        return false, err
    }
    return isFull, nil
}

// GetBookingDetails retrieves the details of a specific cab booking by its ID.
func GetBookingDetails(c *gin.context, cabID int64) (BookingDetails, error) {
    query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.owner_email, u.name, u.phone_number
        FROM cab_booking c
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        WHERE c.id = $1;
    `
    var b BookingDetails
    err := config.DB.QueryRow(query, cabID).Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromPlace, &b.ToPlace, &b.OwnerEmail, &b.Name, &b.PhoneNumber)
    if err != nil {
        return b, err
    }
    return b, nil
}

// CreateRequest inserts a new request into the database with a status of 'pending'.
func CreateRequest(c *gin.context, bookingID int, email, comments string) error {
    query := `
        INSERT INTO request (status, booking_id, request_email, comments) 
        VALUES ('pending', $1, $2, $3)
        ON CONFLICT DO NOTHING;
    `
    _, err := config.DB.Exec(query, bookingID, email, comments)
    return err
}

// GetRequestStatus retrieves the status of a request.
func GetRequestStatus(c *gin.context, bookingID int, email string) (RequestStatus, error) {
    query := `
        SELECT status
        FROM request
        WHERE booking_id = $1 AND request_email = $2;
    `
    var status RequestStatus
    err := config.DB.QueryRow(query, bookingID, email).Scan(&status)
    if err != nil {
        return "", err
    }
    return status, nil
}

// DeleteRequest cancels a pending request.
func DeleteRequest(c *gin.context, bookingID int, email string) error {
    query := `
        UPDATE request
        SET status = 'cancelled'
        WHERE booking_id = $1 AND request_email = $2 AND status = 'pending';
    `
    _, err := config.DB.Exec(query, bookingID, email)
    return err
}

// ShowRequests retrieves all pending requests for a booking.
func ShowRequests(c *gin.context, cabID int) ([]Request, error) {
    query := `
        SELECT r.request_email, r.comments, u.name, u.phone_number
        FROM request r
        INNER JOIN users u ON u.email = r.request_email
        WHERE r.status = 'pending' AND r.booking_id = $1;
    `
    rows, err := config.DB.Query(query, cabID)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var requests []Request
    for rows.Next() {
        var req Request
        var name, phoneNumber string
        if err := rows.Scan(&req.RequestEmail, &req.Comments, &name, &phoneNumber); err != nil {
            return nil, err
        }
        requests = append(requests, req)
    }

    return requests, nil
}

// GetUserPendingRequests retrieves the user's pending requests for future bookings.
func GetUserPendingRequests(c *gin.context, email string) ([]CabBooking, error) {
    query := `
        SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.owner_email, u.name, u.phone_number
        FROM cab_booking c
        INNER JOIN locations fl ON fl.id = c.from_loc
        INNER JOIN locations tl ON tl.id = c.to_loc
        INNER JOIN users u ON u.email = c.owner_email
        INNER JOIN request r ON r.booking_id = c.id
        WHERE r.request_email = $1
        AND r.status = 'pending'
        AND c.end_time > CURRENT_TIMESTAMP;
    `
    rows, err := config.DB.Query(query, email)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var bookings []CabBooking
    for rows.Next() {
        var booking CabBooking
        var fromPlace, toPlace, ownerEmail, name, phoneNumber string
        if err := rows.Scan(&booking.ID, &booking.StartTime, &booking.EndTime, &booking.Capacity, &fromPlace, &toPlace, &ownerEmail, &name, &phoneNumber); err != nil {
            return nil, err
        }
        bookings = append(bookings, booking)
    }

    return bookings, nil
}

// UpdateRequest updates the status of a request and returns the comments.
func UpdateRequest(c *gin.context, bookingID int, requestEmail string, status RequestStatus) (string, error) {
    query := `
        UPDATE request
        SET status = $1
        WHERE booking_id = $2 AND request_email = $3 AND status = 'pending'
        RETURNING comments;
    `
    var comments string
    err := config.DB.QueryRow(query, status, bookingID, requestEmail).Scan(&comments)
    if err != nil {
        return "", err
    }
    return comments, nil
}

// GetName retrieves the name of a user based on the email.
func GetName(c *gin.Context, email string) (string, error) {
    query := `
        SELECT name
        FROM users 
        WHERE email = $1;
    `
    var userName string
    err := config.DB.QueryRow(query, email).Scan(&userName)
    if err != nil {
        return "", err
    }
    return userName, nil
}