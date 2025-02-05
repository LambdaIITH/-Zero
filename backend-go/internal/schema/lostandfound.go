package schema

import (
	"time"
)
type FoundItem struct {
	ID              int      `db:"id"`
	ItemName        string   `db:"item_name"`
	ItemDescription string   `db:"item_description"`
	UserID          int      `db:"user_id"`
	Images          []string `db:"images"`
	CreatedAt       time.Time   `db:"created_at"`
}

type FoundItemWithUser struct {
	ID              int    `db:"id"`
	ItemName        string `db:"item_name"`
	ItemDescription string `db:"item_description"`
	UserID          int    `db:"user_id"`
	UserName        string `db:"username"`
	CreatedAt       string `db:"created_at"`
}

type LostItem struct {
	ID              int      `db:"id"`
	ItemName        string   `db:"item_name"`
	ItemDescription string   `db:"item_description"`
	UserID          int      `db:"user_id"`
	Images          []string `db:"images"`
	CreatedAt       time.Time   `db:"created_at"`
}

type LostItemWithUser struct {
	ID              int    `db:"id"`
	ItemName        string `db:"item_name"`
	ItemDescription string `db:"item_description"`
	UserID          int    `db:"user_id"`
	UserName        string `db:"username"`
	CreatedAt       string `db:"created_at"`
}

type ImageURI struct {
	ItemID   int    `db:"item_id"`
	ImageURL string `db:"image_url"`
}
