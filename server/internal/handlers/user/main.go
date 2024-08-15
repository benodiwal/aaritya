package user

import (
	"github.com/benodiwal/server/internal/repositories"
	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	router *gin.Engine
	ctx    *repositories.Context
}

func (u *UserHandler) RegisterRoutes() {
	user := u.router.Group("/user")
	user.GET("/me", u.Me)
	user.GET("/quizes", u.Quizes)
	user.GET("/leaderboard", u.Leaderboard)
}

func New(router *gin.Engine, ctx *repositories.Context) *UserHandler {
	return &UserHandler{
		router: router,
		ctx: ctx,
	}
}
