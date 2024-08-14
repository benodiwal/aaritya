package routes

import (
	"github.com/benodiwal/server/internal/middlewares"
	"github.com/gin-contrib/cors"
)

func (r *Router) RegisterMiddlewares() {
	r.Engine.Use(cors.Default())
	r.Engine.Use(middlewares.LoggerMiddleware())
}
