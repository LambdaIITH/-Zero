package router

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/LambdaIITH/Dashboard/backend/internal/controller"
	"github.com/LambdaIITH/Dashboard/backend/internal/middlewares"
)

func home(c *gin.Context) {
	HTMLString := "<h1>Hello from <a href='https://iith.dev' target='_blank'>Lambda IITH</a></h1>"
	c.Writer.WriteHeader(http.StatusOK)

	c.Writer.Write([]byte(HTMLString))
}

func SetupRoutes(router *gin.Engine) {

	// Home route
	router.GET("/", home)

	// Group routes for authentication
	authGroup := router.Group("/auth")
	{
		authGroup.POST("/login", controller.LoginHandler)
		authGroup.GET("/logout", controller.LogoutHandler)
	}

	// Group routes for lost items
	lostGroup := router.Group("/lost")
	{
		lostGroup.POST("/add_item", controller.AddItemHandler)
		lostGroup.GET("/all", controller.GetAllItemsHandler)
		lostGroup.GET("/get_item/:id", controller.GetItemByIdHandler)
		lostGroup.PUT("/edit_item", controller.EditItemHandler)
		lostGroup.POST("/delete_item", controller.DeleteItemHandler)
		lostGroup.GET("/search", controller.SearchItemHandler)
	}

	// Group routes for transport
	transportGroup := router.Group("/transport")
	{
		transportGroup.GET("/", middlewares.AuthMiddleware(), controller.GetBusSchedule)
		transportGroup.GET("/cityBus", middlewares.AuthMiddleware(), controller.GetCityBusSchedule)
		transportGroup.POST("/qr", middlewares.AuthMiddleware(), controller.ProcessTransaction)
		transportGroup.POST("/qr/scan", middlewares.AuthMiddleware(), controller.ScanQRCode)
		transportGroup.GET("/qr/recent", middlewares.AuthMiddleware(), controller.GetRecentTransaction)
	}

	sellGroup := router.Group("/sell")
	{
		sellGroup.POST("/add_item", controller.AddSellItemHandler)
		sellGroup.GET("/all", controller.GetAllSellItemsHandler)
		sellGroup.GET("/get_item/:id", controller.GetSellItemByIdHandler)
		sellGroup.PUT("/edit_item", controller.EditSellItemHandler)
		sellGroup.POST("/delete_item", controller.DeleteSellItemHandler)
		sellGroup.GET("/search", controller.SearchSellItemHandler)
	}

	userGroup := router.Group("/user")
	{
		userGroup.GET("/", middlewares.AuthMiddleware(), controller.User)
		userGroup.PATCH("/update", middlewares.AuthMiddleware(), controller.UpdateUser)
		userGroup.PATCH("/fcm/update", middlewares.AuthMiddleware(), controller.UpdateUserFCMToken)
	}

	router.POST("found/add_item", controller.AddFoundItemHandler)
	router.GET("/found/all", controller.GetAllFoundItemsHandler)
	router.GET("/found/get_item/:id", controller.GetFoundItemByIdHandler)
	router.PUT("/found/edit_item", controller.EditFoundItemHandler)
	router.POST("/found/delete_item", controller.DeleteFoundItemHandler)
	router.GET("/found/search", controller.SearchFoundItemHandler)

	//Group routes for timetable/calendar
	timetableGroup := router.Group("/timetable")
	{
		timetableGroup.GET("/courses", controller.GetTimetable)
		timetableGroup.POST("/courses", controller.PostEditTimetable)
		timetableGroup.GET("/share/{code}", controller.GetSharedTimetable)
		timetableGroup.POST("/share", controller.PostSharedTimetable)
		timetableGroup.DELETE("/share/{code}", controller.DeleteSharedTimetable)
	}

	// GET : /announcements?limit=4&offset=4
	router.GET("/announcements", controller.GetAnnouncements)
	router.Static("/announcements/images", "announcementImages/")
	router.POST("/announcements", controller.PostAnnouncement)
}
