package user

import (
	"github.com/benodiwal/server/internal/middlewares"
	"github.com/benodiwal/server/internal/repositories"
	"github.com/benodiwal/server/internal/services"
	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	router *gin.Engine
	ctx    *repositories.Context
	s3Service *services.S3Service
}

func (u *UserHandler) RegisterRoutes() {
	user := u.router.Group("/user")
	user.Use(middlewares.IsAuthenticated())
	user.GET("/me", u.Me)
	user.GET("/quizes", u.Quizes)
	user.GET("/rank", u.Rank)
	user.GET("/leaderboard", u.Leaderboard)
	user.GET("/avg", u.Average)
	user.GET("/total", u.Total)
	user.GET("/upload-profile-image", )
}

func New(router *gin.Engine, ctx *repositories.Context, s3Service *services.S3Service) *UserHandler {
	return &UserHandler{
		router: router,
		ctx: ctx,
		s3Service: s3Service,
	}
}
