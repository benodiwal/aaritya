package routes

import (
	"github.com/benodiwal/server/internal/env"
	"github.com/benodiwal/server/internal/repositories"
	"github.com/gin-gonic/gin"
)

type Router struct {
	ctx    *repositories.Context
	Engine *gin.Engine
}

var appEnvToGinMode = map[string]string {
	"TEST": gin.TestMode,
	"DEV": gin.DebugMode,
	"PRODUCTION": gin.ReleaseMode,
}

func New(ctx *repositories.Context) *Router {
	gin.SetMode(appEnvToGinMode[env.GetEnv(env.APP_ENV)])
	return &Router{
		ctx: ctx,
		Engine: gin.New(),
	}
}
