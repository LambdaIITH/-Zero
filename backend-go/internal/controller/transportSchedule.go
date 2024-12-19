package controller

import (
	"encoding/json"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func GetBusSchedule(c *gin.Context) {
	// Get the current working directory
	dir, err := os.Getwd()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get current directory: " + err.Error()})
		return
	}

	// Open the transport.json file
	file, err := os.Open(dir + "/transport.json")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to open transport.json: " + err.Error()})
		return
	}
	defer file.Close()

	// Decode the JSON data into a generic interface{}
	var data interface{}
	if err := json.NewDecoder(file).Decode(&data); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse JSON: " + err.Error()})
		return
	}

	// Return the data as a JSON response
	c.JSON(http.StatusOK, data)
}

func GetCityBusSchedule(c *gin.Context) {
	// Get the current working directory
	dir, err := os.Getwd()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get current directory: " + err.Error()})
		return
	}

	// Open the cityBus.json file
	file, err := os.Open(dir + "/cityBus.json")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to open transport.json: " + err.Error()})
		return
	}
	defer file.Close()

	// Decode the JSON data into a generic interface{}
	var data interface{}
	if err := json.NewDecoder(file).Decode(&data); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse JSON: " + err.Error()})
		return
	}

	// Return the data as a JSON response
	c.JSON(http.StatusOK, data)
}
