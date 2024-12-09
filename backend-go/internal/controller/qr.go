package controller

import (
	"net/http"
	"time"

	"github.com/LambdaIITH/Dashboard/backend/config"
	queries "github.com/LambdaIITH/Dashboard/backend/internal/db"
	"github.com/gin-gonic/gin"
)

type TransactionRequest struct {
	TransactionId string `json:"transactionId"`
}

type TransactionResponse struct {
	TransactionId string `json:"transactionId"`
	PaymentTime   string `json:"paymentTime"`
	TravelDate    string `json:"travelDate"`
	BusTiming     string `json:"busTiming"`
	IsUsed        bool   `json:"isUsed"`
}

type ScanQRModel struct {
	IsScanned bool `json:"isScanned"`
}

func ProcessTransaction(c *gin.Context) {
	var request TransactionRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	paymentTime := time.Now().Format("2006-01-02 15:04:05")
	travelDate := time.Now().Format("2006-01-02")

	// logic for determining bus timing
	busTiming := "14:30 PM"

	response := TransactionResponse{
		TransactionId: request.TransactionId,
		PaymentTime:   paymentTime,
		TravelDate:    travelDate,
		BusTiming:     busTiming,
		IsUsed:        false,
	}

	result := queries.LogTransactionToDb(c, map[string]interface{}{"transactionId": request.TransactionId, "paymentTime": paymentTime, "travelDate": travelDate, "busTiming": busTiming, "isUsed": false})

	if !result {
		query := `SELECT payment_time, travel_date, bus_timing, isUsed
        FROM transactions
        WHERE transaction_id = $1
		LIMIT 1
		returning *;`

		var res TransactionResponse
		err := config.DB.QueryRow(c, query, request.TransactionId).Scan(&res.PaymentTime, &res.TravelDate, &res.BusTiming, &res.IsUsed)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		if res.TransactionId == "" {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Transaction not found"})
			return
		}

		response := TransactionResponse{
			TransactionId: res.TransactionId,
			PaymentTime:   res.PaymentTime,
			TravelDate:    res.TravelDate,
			BusTiming:     res.BusTiming,
			IsUsed:        res.IsUsed,
		}

		c.JSON(http.StatusOK, response)

	}

	c.JSON(http.StatusOK, response)

}

func ScanQRCode(c *gin.Context) {
	var request TransactionRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	response := ScanQRModel{
		IsScanned: true,
	}

	result := queries.ScanQR(c, map[string]interface{}{"transactionId": request.TransactionId})

	if !result {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Transaction not found"})
		return
	}

	c.JSON(http.StatusOK, response)
}
