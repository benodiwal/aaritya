package routes

import (
	"log"
	"net/http"

	"github.com/benodiwal/server/internal/env"
	"github.com/benodiwal/server/internal/handlers/auth"
	"github.com/benodiwal/server/internal/handlers/quiz"
	"github.com/benodiwal/server/internal/handlers/user"
	"github.com/benodiwal/server/internal/services"
	"github.com/gin-gonic/gin"
)

func (r *Router) RegisterRoutes() {

	s3Service, err := services.NewS3Service(env.GetEnv(env.AWS_REGION), env.GetEnv(env.S3_BUCKET_NAME))
	if err != nil {
		log.Fatalf("Failed to initialize S3 service: %v", err)
	}

	r.Engine.GET("/", func(ctx *gin.Context) {
		ctx.String(http.StatusOK, "Ok")
	})

	r.Engine.GET("/health", func(ctx *gin.Context) {
		ctx.String(http.StatusOK, "Ok")
	})

	authhandler := auth.New(r.Engine, r.ctx)
	authhandler.RegisterRoutes()

	userHandler := user.New(r.Engine, r.ctx, s3Service)
	userHandler.RegisterRoutes()

	quizHandler := quiz.New(r.Engine, r.ctx)
	quizHandler.RegisterRoutes()
}
