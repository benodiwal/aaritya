package app

import (
	"fmt"
	"log"

	database "github.com/benodiwal/server/internal/database/postgres"
	"github.com/benodiwal/server/internal/env"
	"github.com/benodiwal/server/internal/routes"
)

func Run() {
	env.LoadEnv()
	logger := log.Default()
	database.ConnectDatabase(logger)

	router := routes.New()
	router.RegisterMiddlewares()
	router.RegisterRoutes()

	fmt.Printf("Application running on port: %s\n", env.GetEnv(env.PORT))
	router.Engine.Run(fmt.Sprintf(":%s", env.GetEnv(env.PORT)))
}
