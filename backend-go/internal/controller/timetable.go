package controller

import (
	"encoding/json"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/LambdaIITH/Dashboard/backend/config"
	timetable_queries "github.com/LambdaIITH/Dashboard/backend/internal/db"
	helpers "github.com/LambdaIITH/Dashboard/backend/internal/helpers"
	schema "github.com/LambdaIITH/Dashboard/backend/internal/schema"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func validateCourseSchedule(data schema.Timetable) (bool, string) {
	validWeekdays := []string{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
	timePattern := regexp.MustCompile(`^(1[0-2]|0?[1-9]):([0-5]\d)\s?(AM|PM)$`)

	// Validate 'courses'
	for courseCode, courseInfo := range data.Courses {
		if strings.TrimSpace(courseCode) == "" {
			return false, "Course code cannot be empty."
		}
		if courseInfo["title"] == "" {
			return false, "Course title cannot be empty."
		}
	}

	// Validate 'slots'
	for _, slot := range data.Slots {
		requiredFields := []string{"course_code", "day", "start_time", "end_time"}
		for _, field := range requiredFields {
			if slot[field] == "" {
				return false, "Missing field '" + field + "' in slot."
			}
		}

		if !helpers.Contains(validWeekdays, slot["day"]) {
			return false, "Invalid day: " + slot["day"]
		}

		if !helpers.MatchRegex(slot["start_time"], timePattern) || !helpers.MatchRegex(slot["end_time"], timePattern) {
			return false, "Invalid time format in slot."
		}

		startTime, err := time.Parse("3:04 PM", slot["start_time"])
		if err != nil {
			return false, "Invalid start_time format."
		}
		endTime, err := time.Parse("3:04 PM", slot["end_time"])
		if err != nil {
			return false, "Invalid end_time format."
		}
		if !startTime.Before(endTime) {
			return false, "start_time must be earlier than end_time."
		}
	}

	return true, ""
}

func GetTimetable(c *gin.Context) {
	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	timetableJSON, err := timetable_queries.GetTimetable(c, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch timetable."})
		return
	}
	var timetable schema.Timetable
	if err := json.Unmarshal([]byte(timetableJSON), &timetable); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse timetable."})
		return
	}

	c.JSON(http.StatusOK, timetable)
}

func PostEditTimetable(c *gin.Context) {
	var timetable schema.Timetable
	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	if err := c.ShouldBindJSON(&timetable); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	valid, errMsg := validateCourseSchedule(timetable)
	if !valid {
		c.JSON(http.StatusBadRequest, gin.H{"error": errMsg})
		return
	}

	_, err = timetable_queries.PostTimetable(c, userID, timetable)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update timetable."})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"message": "Timetable successfully updated",
	})

}

func GetSharedTimetable(c *gin.Context) {
	code := c.Param("code")

	if code == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Code is required"})
		return
	}

	timetableJSON, err := timetable_queries.GetSharedTimetable(c, code)
	if err != nil {

		if err.Error() == "timetable has expired" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Timetable has expired"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}
	var timetable schema.Timetable
	if err := json.Unmarshal([]byte(timetableJSON), &timetable); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse timetable."})
		return
	}

	c.JSON(http.StatusOK, timetable)
}

func GenerateRandomCode() string {
	uuidValue := uuid.New()
	code := uuidValue.String()[:6]
	return strings.ToUpper(code)
}

func PostSharedTimetable(c *gin.Context) {
	userID, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	var timetable schema.Timetable
	if err := c.ShouldBindJSON(&timetable); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON format"})
		return
	}
	code := GenerateRandomCode()

	valid, errMsg := validateCourseSchedule(timetable)
	if !valid {
		c.JSON(http.StatusBadRequest, gin.H{"error": errMsg})
		return
	}

	curDate := time.Now()
	expiryDays := 120
	expiry := curDate.AddDate(0, 0, expiryDays)
	result, err := timetable_queries.PostSharedTimetable(c, code, userID, timetable, expiry)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to share timetable."})
		return
	}

	c.JSON(http.StatusOK, result)
}

func DeleteSharedTimetable(c *gin.Context) {
	user_id, err := helpers.GetUserID(c.Request)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User not found"})
	}
	code := c.Param("code")
	if code == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Code is required"})
		return
	}
	query := "SELECT timetable FROM shared_timetable WHERE code = $1"
	var id int
	err1 := config.DB.QueryRow(c, query, code).Scan(&id)
	if err1 != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Time Table not found."})
		return
	}
	if id != user_id {
		c.JSON(http.StatusBadRequest, gin.H{"error": "You are not the owner of this timetable"})
	}

	result, err := timetable_queries.DeleteSharedTimetable(c, code)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete timetable."})
		return
	}

	c.JSON(http.StatusOK, result)
}
