package helpers

import (
	"context"
	"fmt"
	"net/smtp"
	"os"
	"strings"
	"text/template"
	"time"

	"github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/jordan-wright/email"
)

// SendEmail sends an email with booking details, formatted using templates.
func SendEmail(receiver, mailType string, bookingID int, additionalData map[string]interface{}) error {
	bookingDetails, err := db.GetCabBooking(context.Background(), bookingID)
	if err != nil {
		return err
	}

	startTime := bookingDetails.StartTime.Format("2006-01-02 15:04")
	endTime := bookingDetails.EndTime.Format("2006-01-02 15:04")
	date := bookingDetails.StartTime.Format("02 Jan 2006")

	ownerEmail, err := db.GetOwnerEmail(context.Background(), bookingID)
	if err != nil {
		return err
	}
	ownerPhone, err := db.GetPhoneNumber(context.Background(), ownerEmail)
	if err != nil {
		return err
	}
	ownerName, err := db.GetName(context.Background(), ownerEmail)
	if err != nil {
		return err
	}

	bookingInfo := map[string]interface{}{
		"id":          bookingID,
		"start_time":  startTime,
		"end_time":    endTime,
		"date":        date,
		"capacity":    bookingDetails.Capacity,
		"from_loc":    bookingDetails.FromLoc,
		"to_loc":      bookingDetails.ToLoc,
		"owner_email": ownerEmail,
		"owner_phone": ownerPhone,
		"owner_name":  ownerName,
	}

	for key, val := range additionalData {
		bookingInfo[key] = val
	}

	subject, err := ParseTemplate(fmt.Sprintf("internal/templates/%s/subject.txt", mailType), bookingInfo)
	if err != nil {
		return err
	}

	body, err := ParseTemplate(fmt.Sprintf("internal/templates/%s/body.html", mailType), bookingInfo)
	if err != nil {
		return err
	}

	// Load email and password from environment variables
	emailAddress := os.Getenv("EMAIL")
	emailPassword := os.Getenv("EMAIL_PASSWORD")

	e := email.NewEmail()
	e.From = emailAddress
	e.To = []string{receiver}
	e.Subject = subject
	e.HTML = []byte(body)

	err = e.Send("smtp.gmail.com:587", smtp.PlainAuth("", emailAddress, emailPassword, "smtp.gmail.com"))
	if err != nil {
		return err
	}
	return nil
}

// ParseTemplate parses a template file with the provided data and returns the formatted string.
func ParseTemplate(filePath string, data map[string]interface{}) (string, error) {
	tmpl, err := template.ParseFiles(filePath)
	if err != nil {
		return "", err
	}

	var builder strings.Builder
	err = tmpl.Execute(&builder, data)
	if err != nil {
		return "", err
	}
	return builder.String(), nil
}

func GetBookings(c context.Context, res []map[string]interface{}) ([]map[string]interface{}, error) {
	var bookings []map[string]interface{}

	for _, booking := range res {
		travellers, err := db.GetTravellersWithDetails(c, booking["id"].(int))
		if err != nil {
			return nil, err
		}
		ownerEmail := booking["owner_email"].(string)

		var travellersList []map[string]interface{}
		for _, traveller := range travellers {
			if ownerEmail == traveller["email"].(string) {
				travellersList = append([]map[string]interface{}{traveller}, travellersList...)
			} else {
				travellersList = append(travellersList, traveller)
			}
		}

		// Convert time from UTC to IST
		loc, _ := time.LoadLocation("Asia/Kolkata")
		startTime := booking["start_time"].(time.Time).In(loc).Format("2006-01-02 15:04:05")
		endTime := booking["end_time"].(time.Time).In(loc).Format("2006-01-02 15:04:05")

		bookingMap := map[string]interface{}{
			"id":          booking["id"],
			"start_time":  startTime,
			"end_time":    endTime,
			"capacity":    booking["capacity"],
			"from_":       booking["from_loc"],
			"to":          booking["to_loc"],
			"owner_email": ownerEmail,
			"travellers":  travellersList,
			"comments":    booking["comments"],
		}

		requests, err := db.ShowRequests(c, booking["id"].(int))
		if err != nil {
			return nil, err
		}
		bookingMap["requests"] = requests

		bookings = append(bookings, bookingMap)
	}

	return bookings, nil
}
