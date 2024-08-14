package app

import (
	"log"

	database "github.com/benodiwal/server/internal/database/postgres"
	"github.com/benodiwal/server/internal/env"
)

func Run() {
	env.LoadEnv()
	logger := log.Default()
	database.ConnectDatabase(logger)
}
