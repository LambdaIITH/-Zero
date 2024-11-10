package main

import (
	"fmt"
	"os"

	"github.com/LambdaIITH/Dashboard/backend/config"
	"github.com/LambdaIITH/Dashboard/backend/internal/router"
)

func init() {
	config.Init()
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}

	fmt.Printf("\033[1;36m%s\033[0m \033[1;32m%s%s\033[0m\n", "Server running on:", "http://localhost:", port)

	r := router.SetupRouter()
	defer config.DB.Close()

	r.Run(":" + port)
}
