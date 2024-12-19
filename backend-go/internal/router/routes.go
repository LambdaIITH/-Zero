package router

import (
	"net/http"

	"github.com/LambdaIITH/Dashboard/backend/internal/controller"
	"github.com/gin-gonic/gin"
)

func home(c *gin.Context) {
	HTMLString := "<h1>Hello from <a href='https://iith.dev' target='_blank'>Lambda IITH</a></h1>"
	c.Writer.WriteHeader(http.StatusOK)

	c.Writer.Write([]byte(HTMLString))
}

func SetupRoutes(router *gin.Engine) {
	router.GET("/", home)
	router.POST("/auth/login", controller.LoginHandler)
	router.POST("/auth/logout", controller.LogoutHandler)
	router.POST("/lost/add_item", controller.AddItemHandler)
	router.GET("/lost/all", controller.GetAllItemsHandler)
	router.GET("/lost/get_item/:id", controller.GetItemByIdHandler)
	router.PUT("/lost/edit_item", controller.EditItemHandler)
	router.POST("/lost/delete_item", controller.DeleteItemHandler)
	router.GET("/lost/search", controller.SearchItemHandler)
	router.GET("/transport", controller.GetBusSchedule)
	router.GET("/transport/cityBus", controller.GetCityBusSchedule)
	router.POST("/transport/qr", controller.ProcessTransaction)
	router.POST("/transport/qr/scan", controller.ScanQRCode)

}
