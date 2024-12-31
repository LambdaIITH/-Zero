package main

import (
	"database/sql"
	"log"
	"net/http"
	"context"
	"encoding/json"
	"net/http"
	"os"
	"strconv"
	"time"

	
	"github.com/LambdaIITH/Dashboard/backend/config"
	queries "github.com/LambdaIITH/Dashboard/backend/internal/db"
	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	schema "github.com/LambdaIITH/Dashboard/backend/internal/schema"
	
	"github.com/gin-gonic/gin"
)


// func initDB() {
// 	var err error
// 	db, err = sql.Open("postgres", "user=youruser dbname=yourdb sslmode=disable")
// 	if err != nil {
// 		log.Fatalf("Failed to connect to database: %v", err)
// 	}
// }

// Middleware to extract user ID from cookie



// Handlers
func checkAuth(c *gin.Context) {

	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	email, err := helpers.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	phoneNumber, err := helpers.GetPhoneNumber(c, email)
	if err != nil {
		log.Printf("Error fetching phone number: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch phone number"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"phone_number": phoneNumber,
	})
}

func CreateBooking(c *gin.Context) {
	var booking schema.Booking

	// Bind the request body to the Booking struct
	if err := c.ShouldBindJSON(&booking); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking data"})
		return
	}

	// Get user ID from the context
	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch user email
	email, err := helpers.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	// Get location IDs
	fromID := helpers.GetLocationID(c, booking.FromLoc)
	toID := helpers.GetLocationID(c, booking.ToLoc)
	if fromID == 0 || toID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid location"})
		return
	}

	// Prepare booking data
	bookingData := map[string]interface{}{
		"startTime":  booking.StartTime,
		"endTime":    booking.EndTime,
		"capacity":   booking.Capacity,
		"fromLoc":    fromID,
		"toLoc":      toID,
		"ownerEmail": email,
		"comments":   booking.Comments,
	}

	// Create booking
	bookingID, err := queries.CreateBooking(c, bookingData)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create booking"})
		return
	}

	// Add traveller
	err = queries.AddTraveller(c, bookingID, email, booking.Comments)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add traveller"})
		return
	}

	// Send email notification
	err = helpers.SendEmail(email, "create", booking, map[string]string{"booking_id": strconv.Itoa(bookingID)})
	if err != nil {
		log.Printf("Error sending email notification: %v", err)
	}

	// Respond with booking ID
	c.JSON(http.StatusCreated, gin.H{"booking_id": bookingID})
}

func UpdateBooking(c *gin.Context) {
	// Extract the booking ID from the path parameter
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	// Parse the BookingUpdate object from the request body
	var patch schema.BookingUpdate
	if err := c.ShouldBindJSON(&patch); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking update data"})
		return
	}

	// Get user ID from the context
	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch user email
	email, err := helpers.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	helpers.VerifyExists(email)

	ownerEmail, err := queries.GetOwnerEmail(c, bookingID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	if ownerEmail != email {
		c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
		return
	}

	// Update booking
	err = queries.UpdateBooking(c, patch.StartTime, patch.EndTime, bookingID)
	if err != nil {
		log.Printf("Error updating booking: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update booking"})
		return
	}

	// Commit transaction if applicable
	c.JSON(http.StatusOK, gin.H{"message": "Booking updated successfully"})
}

func UserBookings(c *gin.Context) {
	// Get user ID from the context
	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch user email
	email, err := helpers.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	// Fetch past and future bookings
	pastBookings, err := queries.GetUserPastBookings(c, email)
	if err != nil {
		log.Printf("Error fetching past bookings: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch past bookings"})
		return
	}

	futureBookings, err := queries.GetUserFutureBookings(c, email)
	if err != nil {
		log.Printf("Error fetching future bookings: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch future bookings"})
		return
	}

	// Construct response
	response := gin.H{
		"past_bookings":   pastBookings,
		"future_bookings": futureBookings,
	}
	c.JSON(http.StatusOK, response)
}

func SearchBookings(c *gin.Context) {
	// Extract query parameters
	fromLoc := c.Query("from_loc")
	toLoc := c.Query("to_loc")
	startTimeStr := c.Query("start_time")
	endTimeStr := c.Query("end_time")

	// Default values for start_time and end_time
	const layout = time.RFC3339
	startTime, err := time.Parse(layout, startTimeStr)
	if err != nil {
		startTime = time.Date(1970, 1, 1, 0, 0, 0, 0, time.FixedZone("IST", 5*3600+30*60))
	}
	endTime, err := time.Parse(layout, endTimeStr)
	if err != nil {
		endTime = time.Date(2100, 1, 1, 0, 0, 0, 0, time.FixedZone("IST", 5*3600+30*60))
	}

	// XOR condition: either fromLoc or toLoc is null, but not both
	if (fromLoc == "" && toLoc != "") || (fromLoc != "" && toLoc == "") {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot search with only one location"})
		return
	}

	var res []schema.Booking
	if fromLoc == "" && toLoc == "" {
		// Filter bookings by time range
		res, err = queries.FilterTimes(c, startTime, endTime)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to filter bookings by time"})
			return
		}
	} else {
		// Get location IDs
		fromID, err := queries.GetLocID(c, fromLoc)
		if err != nil || fromID == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid from location"})
			return
		}
		toID, err := queries.GetLocID(c, toLoc)
		if err != nil || toID == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid to location"})
			return
		}

		// Filter bookings by locations and time range
		res, err = queries.FilterAll(c, fromID, toID, startTime, endTime)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to filter bookings by location and time"})
			return
		}
	}

	// Convert bookings to response format
	bookings := res

	c.JSON(http.StatusOK, bookings)
}

func RequestToJoinBooking(c *gin.Context) {
	// Extract booking ID from path parameter
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	// Parse JoinBooking struct from request body
	var joinBooking schema.JoinBooking
	if err := c.ShouldBindJSON(&joinBooking); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid join booking data"})
		return
	}

	// Get user ID from context
	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch user email
	email, err := helpers.GetUserEmail(c, userID)
	if err != nil {
		log.Printf("Error fetching user email: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user email"})
		return
	}

	// Check if the booking exists and is not owned by the requester
	ownerEmail, err := queries.GetOwnerEmail(c, bookingID)
	if err != nil || ownerEmail == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ride ID"})
		return
	}
	if ownerEmail == email {
		c.JSON(http.StatusBadRequest, gin.H{"error": "You cannot join your own ride"})
		return
	}

	helpers.VerifyExists(email)

	// Check if the cab is full
	if queries.IsCabFull(c, bookingID) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Ride is full"})
		return
	}

	// Check if a request already exists
	requestStatus, err := queries.GetRequestStatus(c, bookingID, email)
	if err == nil {
		var detail string
		switch requestStatus {
		case "pending":
			detail = "Request already sent"
		case "accepted":
			detail = "You are already a traveller"
		case "cancelled":
			detail = "Request already cancelled"
		case "rejected":
			detail = "Request already rejected"
		default:
			detail = "Unknown request status"
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": detail})
		return
	}

	// Create a new request
	err = queries.CreateRequest(c, bookingID, email, joinBooking.Comments)
	if err != nil {
		log.Printf("Error creating request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request"})
		return
	}

	// Send email to owner
	ownerPhone, _ := queries.GetPhoneNumber(c, ownerEmail)
	requesterName, _ := queries.GetName(c, email)
	err = helpers.SendEmail(
		ownerEmail,
		"request",
		bookingID,
		map[string]string{
			"x_requester_name":  requesterName,
			"x_requester_phone": ownerPhone,
			"x_requester_email": email,
		},
	)
	if err != nil {
		log.Printf("Error sending email: %v", err)
	}

	c.JSON(http.StatusOK, gin.H{"message": "Request sent successfully"})
}

// DELETE /bookings/:booking_id/request
func DeleteRequest(c *gin.Context) {
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	email, err := helpers.GetUserEmail(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Check if there is a pending request
	requestStatus := queries.GetRequestStatus(c, bookingID, email)
	if requestStatus != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No pending request found"})
		return
	}

	// Try to delete the request
	err = queries.DeleteRequest(c, bookingID, email)
	if err != nil {
		log.Printf("Error deleting request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete request"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Request deleted successfully"})
}

// POST /bookings/:booking_id/accept
func AcceptRequest(c *gin.Context) {
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var response schema.RequestResponse
	if err := c.ShouldBindJSON(&response); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	email, err := helpers.GetUserEmail(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	ownerEmail := queries.GetOwnerEmail(c, bookingID)
	if ownerEmail == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking does not exist"})
		return
	} else if ownerEmail != email {
		c.JSON(http.StatusForbidden, gin.H{"error": "You are not the owner of this booking"})
		return
	}

	if queries.IsCabFull(c, bookingID) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cab is already full"})
		return
	}

	status := queries.GetRequestStatus(c, bookingID, response.RequesterEmail)
	if status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No pending request found"})
		return
	}

	// Accept request and add traveller
	comments, err := queries.UpdateRequest(c, bookingID, response.RequesterEmail, "accepted")
	if err != nil {
		log.Printf("Error updating request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to accept request"})
		return
	}
	if comments == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No pending request to accept"})
		return
	}

	err = queries.AddTraveller(c, bookingID, response.RequesterEmail, comments)
	if err != nil {
		log.Printf("Error adding traveller: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add traveller"})
		return
	}

	// Send acceptance email
	err = helpers.SendEmail(response.RequesterEmail, "accept", bookingID)
	if err != nil {
		log.Printf("Error sending email: %v", err)
	}

	// Notify other travellers
	name := queries.GetName(c, response.RequesterEmail)
	phone := queries.GetPhoneNumber(c, response.RequesterEmail)

	travellers := queries.GetTravellers(c, bookingID)
	for _, traveller := range travellers {
		travellerEmail := traveller.Email
		if travellerEmail == response.RequesterEmail {
			continue
		}

		err = helpers.SendEmail(travellerEmail, "accept_notif", bookingID, map[string]string{
			"x_accepted_email": response.RequesterEmail,
			"x_accepted_name":  name,
			"x_accepted_phone": phone,
		})
		if err != nil {
			log.Printf("Error sending notification email: %v", err)
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Request accepted successfully"})
}

// POST /bookings/:booking_id/reject
func RejectRequest(c *gin.Context) {
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	var response schema.RequestResponse
	if err := c.ShouldBindJSON(&response); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	email, err := helpers.GetUserEmail(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	ownerEmail := queries.GetOwnerEmail(c, bookingID)
	if ownerEmail == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Ride does not exist"})
		return
	} else if ownerEmail != email {
		c.JSON(http.StatusForbidden, gin.H{"error": "You are not the owner of this booking"})
		return
	}

	// Reject the request
	err = queries.UpdateRequest(c, bookingID, response.RequesterEmail, "rejected")
	if err != nil {
		log.Printf("Error rejecting request: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to reject request"})
		return
	}

	// Send rejection email
	err = helpers.SendEmail(response.RequesterEmail, "reject", bookingID)
	if err != nil {
		log.Printf("Error sending rejection email: %v", err)
	}

	c.JSON(http.StatusOK, gin.H{"message": "Request rejected successfully"})
}

// DELETE /bookings/:booking_id
func DeleteExistingBooking(c *gin.Context) {
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	email, err := helpers.GetUserEmail(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	ownerEmail := queries.GetOwnerEmail(c, bookingID)
	if ownerEmail == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Booking does not exist"})
		return
	} else if ownerEmail != email {
		c.JSON(http.StatusForbidden, gin.H{"error": "You are not the owner of this booking"})
		return
	}

	// Notify travellers and delete the booking
	travellers := queries.GetTravellers(c, bookingID)
	for _, traveller := range travellers {
		err = helpers.SendEmail(traveller.Email, "delete_notif", bookingID)
		if err != nil {
			log.Printf("Error sending notification email to traveller: %v", err)
		}
	}

	err = queries.DeleteBooking(c, bookingID)
	if err != nil {
		log.Printf("Error deleting booking: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete booking"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Booking deleted successfully"})
}

// DELETE /bookings/:booking_id/self
func ExitBooking(c *gin.Context) {
	bookingID, err := strconv.Atoi(c.Param("booking_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	email, err := helpers.GetUserEmail(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	ownerEmail := queries.GetOwnerEmail(c, bookingID)
	if ownerEmail == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Ride does not exist"})
		return
	} else if ownerEmail == email {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Owner cannot exit a ride, but you can delete it"})
		return
	}

	// Remove traveller from booking
	err = queries.DeleteParticularTraveller(c, bookingID, email, ownerEmail)
	if err != nil {
		log.Printf("Error exiting booking: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to exit booking"})
		return
	}

	// Send confirmation email to exiting user
	err = helpers.SendEmail(email, "exit", bookingID)
	if err != nil {
		log.Printf("Error sending exit confirmation email: %v", err)
	}

	// Notify remaining travellers
	name := queries.GetName(c, email)
	travellers := queries.GetTravellers(c, bookingID)
	for _, traveller := range travellers {
		err = helpers.SendEmail(traveller.Email, "exit_notif", bookingID, map[string]string{
			"x_exited_email": email,
			"x_exited_name":  name,
		})
		if err != nil {
			log.Printf("Error sending exit notification email: %v", err)
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "Exited booking successfully"})
}
