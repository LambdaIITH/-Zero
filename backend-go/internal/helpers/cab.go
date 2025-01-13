package helpers

import (
	"context"
	"fmt"
	"net/smtp"
	"strings"
	"text/template"

	"github.com/jordan-wright/email"

	"github.com/LambdaIITH/Dashboard/backend/internal/db"
)

// // getBookings retrieves booking details, including travellers and requests.
// func GetBookings(ownerEmail string) ([]map[string]interface{}, error) {
// 	bookings := []map[string]interface{}{}
// 	result, err := db.GetBookingsFromDB()
// 	if err != nil {
// 		return nil, err
// 	}

// 	for _, tup := range result {
// 		travellers, err := queries.GetTravellers(tup[0])
// 		if err != nil {
// 			return nil, err
// 		}

// 		travellersList := []map[string]interface{}{}
// 		for _, traveller := range travellers {
// 			travellerMap := map[string]interface{}{
// 				"email":        traveller.Email,
// 				"comments":     traveller.Comments,
// 				"name":         traveller.Name,
// 				"phone_number": traveller.PhoneNumber,
// 			}
// 			if ownerEmail == traveller.Email {
// 				travellersList = append([]map[string]interface{}{travellerMap}, travellersList...)
// 			} else {
// 				travellersList = append(travellersList, travellerMap)
// 			}
// 		}

// 		// Convert from UTC to IST
// 		startTime := tup[1].In(time.FixedZone("Asia/Kolkata", 5*60*60+30*60))
// 		endTime := tup[2].In(time.FixedZone("Asia/Kolkata", 5*60*60+30*60))

// 		booking := map[string]interface{}{
// 			"id":          tup[0],
// 			"start_time":  startTime.Format("2006-01-02 15:04:05"),
// 			"end_time":    endTime.Format("2006-01-02 15:04:05"),
// 			"capacity":    tup[3],
// 			"from":        tup[4],
// 			"to":          tup[5],
// 			"owner_email": ownerEmail,
// 			"travellers":  travellersList,
// 		}

// 		if ownerEmail == tup[6] {
// 			requests, err := queries.ShowRequests(tup[0])
// 			if err != nil {
// 				return nil, err
// 			}

// 			requestsList := []map[string]interface{}{}
// 			for _, req := range requests {
// 				requestsList = append(requestsList, map[string]interface{}{
// 					"email":        req.Email,
// 					"comments":     req.Comments,
// 					"name":         req.Name,
// 					"phone_number": req.PhoneNumber,
// 				})
// 			}
// 			booking["requests"] = requestsList
// 		}

// 		bookings = append(bookings, booking)
// 	}
// 	return bookings, nil
// }

// sendEmail sends an email with booking details, formatted using templates.
func SendEmail(receiver, mailType string, bookingID int, additionalData map[string]interface{}) error {
	bookingDetails, err := db.GetCabBooking(context.Background(), bookingID)
	if err != nil {
		return err
	}

	startTime := bookingDetails.StartTime.Format("2006-01-02 15:04")
	endTime := bookingDetails.EndTime.Format("2006-01-02 15:04")
	date := bookingDetails.StartTime.Format("02 Jan 2006")

	bookingInfo := map[string]interface{}{
		"id":  bookingID,
		"start_time":  startTime,
		"end_time":    endTime,
		"date":        date,
		"capacity":    bookingDetails.Capacity,
		"from_loc":    bookingDetails.FromLoc,
		"to_loc":      bookingDetails.ToLoc,
	}

	for key, val := range additionalData {
		bookingInfo[key] = val
	}

	subject, err := ParseTemplate(fmt.Sprintf("github.com/LambdaIITH/Dashboard/backend-go/internal/templates/%s/subject.txt", mailType), bookingInfo)
	if err != nil {
		return err
	}

	body, err := ParseTemplate(fmt.Sprintf("github.com/LambdaIITH/Dashboard/backend-go/internal/templates/%s/body.html", mailType), bookingInfo)
	if err != nil {
		return err
	}

	e := email.NewEmail()
	e.From = "your-email@example.com"
	e.To = []string{receiver}
	e.Subject = subject
	e.HTML = []byte(body)

	err = e.Send("smtp.gmail.com:587", smtp.PlainAuth("", "your-email@example.com", "password", "smtp.gmail.com"))
	if err != nil {
		return err
	}
	return nil
}

// parseTemplate parses a template file with the provided data and returns the formatted string.
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