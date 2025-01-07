package schema

/*
following simillar structure to lost and found as

lost == Buy // as here the item is with the user

Found == Sell // here user is looking for the item

*/

// SellItem
// SellItemWithUser
// BuyItem
// BuyItemWithUser

// image uri no need to re-implement this
// as this is already in lost and found

/*
	Note here price should be mentioned in description
	or we can add it later if someone reads this in my PR
*/

type SellItem struct {
	ID              int      `db:"id"`
	ItemName        string   `db:"item_name"`
	ItemDescription string   `db:"item_description"`
	UserID          int      `db:"user_id"`
	Images          []string `db:"images"`
	CreatedAt       string   `db:"created_at"`
}

type SellItemWithUser struct {
	ID              int    `db:"id"`
	ItemName        string `db:"item_name"`
	ItemDescription string `db:"item_description"`
	UserID          int    `db:"user_id"`
	UserName        string `db:"user_name"`
	CreatedAt       string `db:"created_at"`
}
