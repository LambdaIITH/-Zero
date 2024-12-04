package schema

type Announcement struct {
	ID          int      `json:"id"`
	Title       string   `json:"title"`
	Description string   `json:"description"`
	CreatedAt   int      `json:"createdAt"`
	CreatedBy   string   `json:"createdBy"`
	Tags        []string `json:"tags"`
}

type AnnouncementWithImages struct {
	Announcement
	ImageUrl string `json:"imageUrl"`
}

type RequestAnnouncement struct {
	Title       string   `json:"title"`
	Description string   `json:"description"`
	CreatedAt   int      `json:"createdAt"`
	CreatedBy   string   `json:"createdBy"`
	Tags        []string `json:"tags"`
}
