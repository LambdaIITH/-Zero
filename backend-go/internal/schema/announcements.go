package schema

type Announcement struct {
	ID          int      `json:"id"`
	Title       string   `json:"title"`
	Description string   `json:"description"`
	CreatedAt   int      `json:"createdAt"`
	CreatedBy   string   `json:"createdBy"`
	Tags        []string `json:"tags"`
}

type RequestAnnouncement struct {
	Title       string   `json:"title"`
	Description string   `json:"description"`
	CreatedAt   int      `json:"createdAt"`
	CreatedBy   string   `json:"createdBy"`
	Tags        []string `json:"tags"`
}
