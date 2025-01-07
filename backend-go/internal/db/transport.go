package db

import (
	"context"

	_ "github.com/lib/pq"

	"github.com/LambdaIITH/Dashboard/backend/config"
)

func LogTransactionToDb(ctx context.Context, transactionData map[string]interface{}) bool {
	// Query to insert the transaction data in the database
	query := `
		INSERT INTO transactions (transaction_id, payment_time, travel_date, bus_timing, isUsed) 
		VALUES ($1, $2, $3, $4, $5);
	`

	// Execute the query
	// no need to scan the resutl
	_, err := config.DB.Exec(ctx, query, transactionData["transactionId"], transactionData["paymentTime"], transactionData["travelDate"], transactionData["busTiming"], transactionData["isUsed"])
	if err != nil {
		return false
	}

	return true
}

func ScanQR(ctx context.Context, transactionData map[string]interface{}) bool {
	// Query to update the transaction data in the database
	query := `
		UPDATE transactions 
		SET isUsed = true 
		WHERE transaction_id = $1;
	`

	// Execute the query
	// no need to scan the resutl
	_, err := config.DB.Exec(ctx, query, transactionData["transactionId"])
	if err != nil {
		return false
	}

	return true
}
