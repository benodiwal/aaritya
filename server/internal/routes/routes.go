package routes

import (
	"net/http"

	"github.com/benodiwal/server/internal/handlers/auth"
	"github.com/benodiwal/server/internal/handlers/user"
	"github.com/gin-gonic/gin"
)

func (r *Router) RegisterRoutes() {
	r.Engine.GET("/", func(ctx *gin.Context) {
		ctx.String(http.StatusOK, "Ok")
	})

	r.Engine.GET("/health", func(ctx *gin.Context) {
		ctx.String(http.StatusOK, "Ok")
	})

	authhandler := auth.New(r.Engine, r.ctx)
	authhandler.RegisterRoutes()

	userHandler := user.New(r.Engine, r.ctx)
	userHandler.RegisterRoutes()
}
