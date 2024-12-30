package schema

import (
	"encoding/json"
	"errors"
)

// Timetable represents a user's timetable.
type Timetable struct {
	Courses map[string]map[string]string `json:"courses"` // Mapping of course_code to slots
	Slots   []map[string]string          `json:"slots"`   // List of slots
}

// NewTimetable creates a new Timetable with default values.
func NewTimetable() *Timetable {
	return &Timetable{
		Courses: make(map[string]map[string]string),
		Slots:   make([]map[string]string, 0),
	}
}

// FromRow initializes a Timetable from a database row.
func FromRow(row map[string]interface{}) (*Timetable, error) {
	coursesJSON, ok := row["courses"].(string)
	if !ok {
		return nil, errors.New("invalid or missing courses field")
	}
	slotsJSON, ok := row["slots"].(string)
	if !ok {
		return nil, errors.New("invalid or missing slots field")
	}

	var courses map[string]map[string]string
	if err := json.Unmarshal([]byte(coursesJSON), &courses); err != nil {
		return nil, err
	}

	var slots []map[string]string
	if err := json.Unmarshal([]byte(slotsJSON), &slots); err != nil {
		return nil, err
	}

	return &Timetable{
		Courses: courses,
		Slots:   slots,
	}, nil
}
