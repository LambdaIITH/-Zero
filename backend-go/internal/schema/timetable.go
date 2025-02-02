package schema

import (
	"encoding/json"
	"errors"
)

type Timetable struct {
	Courses map[string]map[string]string `json:"courses"`
	Slots   []map[string]string          `json:"slots"`
}

// NewTimetable creates a new Timetable with default values.
func NewTimetable() *Timetable {
	return &Timetable{
		Courses: make(map[string]map[string]string), // Creates an empty map for courses.
		Slots:   make([]map[string]string, 0),       // Creates an empty slice for slots (slice of maps).
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
