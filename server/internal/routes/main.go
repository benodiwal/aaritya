package routes

import (
	"github.com/benodiwal/server/internal/env"
	"github.com/gin-gonic/gin"
)

type Router struct {
	Engine *gin.Engine
}

var appEnvToGinMode = map[string]string {
	"TEST": gin.TestMode,
	"DEV": gin.DebugMode,
	"PRODUCTION": gin.ReleaseMode,
}

func New() *Router {
	gin.SetMode(appEnvToGinMode[env.GetEnv(env.APP_ENV)])
	return &Router{
		Engine: gin.New(),
	}
}
