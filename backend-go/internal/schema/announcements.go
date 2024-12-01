package schema

type Announcement struct {
	Title       string   `db:"title"`
	Description string   `db:"description"`
	CreatedAt   int      `db:"createdAt"`
	CreatedBy   string   `db:"createdBy"`
	Tags        []string `db:"tags"`
}
