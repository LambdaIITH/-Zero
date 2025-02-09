package schema

type Course struct {
	Segment    string `json:"segment"`
	CourseCode string `json:"course_code"`
	Name       string `json:"name"`
	Credits    float64    `json:"credits"`
	Slot       string `json:"slot"`
	Instructor string `json:"instructor"`
}