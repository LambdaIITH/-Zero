package schema

type Announcement struct {
	id          string   `db:"id"`
	Title       string   `db:"title"`
	Description string   `db:"description"`
	CreatedAt   int      `db:"createdAt"`
	CreatedBy   string   `db:"createdBy"`
	Tags        []string `db:"tags"`
}

type RequestAnnouncement struct {
	Title       string   `json:"title"`
	Description string   `json:"description"`
	CreatedAt   int      `json:"createdAt"`
	CreatedBy   string   `json:"createdBy"`
	Tags        []string `json:"tags"`
}
