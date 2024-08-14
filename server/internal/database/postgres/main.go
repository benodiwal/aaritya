package database

import (
	"fmt"
	"log"

	"github.com/benodiwal/server/internal/env"
	"github.com/jinzhu/gorm"
	_ "github.com/lib/pq"
)

type Database struct {
	DB     *gorm.DB
	logger *log.Logger
}

func ConnectDatabase(logger *log.Logger) *Database {
	db_driver := env.GetEnv(env.DB_DRIVER)
	db_host := env.GetEnv(env.DB_HOST)
	db_user := env.GetEnv(env.DB_USER)
	db_password := env.GetEnv(env.DB_PASSWORD)
	db_name := env.GetEnv(env.DB_NAME)
	db_port := env.GetEnv(env.DB_PORT)

	db_url := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable", db_host, db_user, db_password, db_name, db_port)
	DB, err := gorm.Open(db_driver, db_url)

	if err != nil {
		logger.Panic("database connection error: ", err)
	} else {
		logger.Println("database connection successful: ", db_driver)
	}

	if env.GetEnv(env.APP_ENV) == "DEV" {
		DB.LogMode(true)
	}

	return &Database{DB: DB, logger: logger}
}
