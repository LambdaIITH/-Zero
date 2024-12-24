import (
	"bytes"
	"context"
	"database/sql"
	"fmt"
	"html/template"
	"log"
	"net/smtp"
	"os"
	"sync"

	"schema"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
	"github.com/LambdaIITH/Dashboard/backend-go/config"
	"github.com/LambdaIITH/Dashboard/backend-go/internal/schema"
)

var (
	MailUser  string
	MailPass  string
	MailMutex sync.Mutex
)

func Init() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	var err error
	dsn := os.Getenv("DATABASE_URL")
	config.DB, err = sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	MailUser = os.Getenv("GMAIL")
	MailPass = os.Getenv("GMAIL_PASSWORD")
}

// verifyEmailExists checks if the email exists in the database
func VerifyEmailExists(ctx context.Context, email string) error {
	query := "SELECT phone_number FROM users WHERE email = $1"
	var phoneNumber string
	if err := config.DB.QueryRowContext(ctx, query, email).Scan(&phoneNumber); err != nil {
		if err == sql.ErrNoRows {
			return fmt.Errorf("email not found: %s", email)
		}
		return err
	}
	return nil
}

// getBookings retrieves all bookings and related travellers and requests
func GetBookings(ctx context.Context) ([]schema.Booking, error) {
	query := `
		SELECT id, start_time, end_time, capacity, from_location, to_location, owner_email
		FROM bookings
	`
	rows, err := config.DB.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bookings []schema.Booking
	for rows.Next() {
		var b schema.Booking
		if err := rows.Scan(&b.ID, &b.StartTime, &b.EndTime, &b.Capacity, &b.FromLoc, &b.ToLoc, &b.OwnerEmail); err != nil {
			return nil, err
		}

		b.Travellers, err = getTravellers(ctx, b.ID)
		if err != nil {
			return nil, err
		}

		if b.OwnerEmail != "" {
			b.Requests, err = getRequests(ctx, b.ID)
			if err != nil {
				return nil, err
			}
		}

		bookings = append(bookings, b)
	}

	return bookings, nil
}

// getTravellers fetches the list of travellers for a booking
func GetTravellers(ctx context.Context, bookingID int) ([]schema.UserDetails, error) {
	query := `
		SELECT email, comments, name, phone_number
		FROM travellers
		WHERE booking_id = $1
	`
	rows, err := config.DB.QueryContext(ctx, query, bookingID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var travellers []schema.UserDetails
	for rows.Next() {
		var t schema.UserDetails
		if err := rows.Scan(&t.Email, &t.Comments, &t.Name, &t.PhoneNumber); err != nil {
			return nil, err
		}
		travellers = append(travellers, t)
	}

	return travellers, nil
}

// getRequests fetches the list of requests for a booking
func GetRequests(ctx context.Context, bookingID int) ([]schema.JoinBooking, error) {
	query := `
		SELECT r.email, r.comments, t.name, t.phone_number
		FROM request r
		INNER JOIN travellers t u ON t.email = r.email
		WHERE r.status = $1 AND r.booking_id = $2
	`
	rows, err := config.DB.QueryContext(ctx, query, schema.StatusPending, bookingID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var requests []schema.JoinBooking
	for rows.Next() {
		var r schema.JoinBooking
		var name, phoneNumber string // To hold additional fields
		if err := rows.Scan(&r.Email, &r.Comments, &name, &phoneNumber); err != nil {
			return nil, err
		}
		r.Status = schema.StatusPending // Explicitly set the status
		requests = append(requests, r)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return requests, nil
}

// sendEmail sends an email to a recipient
func SendEmail(receiver, mailType string, booking schema.Booking, substitutions map[string]string) error {
	subjectTemplate := fmt.Sprintf("github.com/LambdaIITH/Dashboard/backend-go/internal/templates/%s/subject.txt", mailType)
	bodyTemplate := fmt.Sprintf("github.com/LambdaIITH/Dashboard/backend-go/internal/templates/%s/body.html", mailType)

	subject, err := parseTemplate(subjectTemplate, substitutions)
	if err != nil {
		return err
	}

	body, err := parseTemplate(bodyTemplate, substitutions)
	if err != nil {
		return err
	}

	return sendSMTPMail(receiver, subject, body)
}

func SendEmailAsync(receiver, mailType string, booking schema.Booking, substitutions map[string]string) {
	go func() {
		if err := sendEmail(receiver, mailType, booking, substitutions); err != nil {
			log.Printf("Failed to send email to %s: %v", receiver, err)
		} else {
			log.Printf("Email sent successfully to %s", receiver)
		}
	}()
}

func ParseTemplate(filepath string, substitutions map[string]string) (string, error) {
	tmpl, err := template.ParseFiles(filepath)
	if err != nil {
		return "", err
	}

	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, substitutions); err != nil {
		return "", err
	}

	return buf.String(), nil
}

func SendSMTPMail(receiver, subject, body string) error {
	MailMutex.Lock()
	defer MailMutex.Unlock()

	auth := smtp.PlainAuth("", MailUser, MailPass, "smtp.gmail.com")
	msg := fmt.Sprintf("From: %s\nTo: %s\nSubject: %s\n\n%s", MailUser, receiver, subject, body)
	err := smtp.SendMail("smtp.gmail.com:587", auth, MailUser, []string{receiver}, []byte(msg))
	return err
}