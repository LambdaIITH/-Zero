package config

import (
	"fmt"
	"log"
	"github.com/joho/godotenv"
)

func LoadEnv() {
	err := godotenv.Load()
	if err != nil {
		fmt.Println("\033[31mError loading .env file\033[0m")
		log.Fatal("Error loading .env file")
	}
}
