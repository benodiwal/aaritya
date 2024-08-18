package quiz

import (
	"github.com/benodiwal/server/internal/middlewares"
	"github.com/benodiwal/server/internal/repositories"
	"github.com/gin-gonic/gin"
)

type QuizHandler struct {
	router *gin.Engine
	ctx    *repositories.Context
}

func (q *QuizHandler) RegisterRoutes() {
	quiz := q.router.Group("/quiz")
	quiz.Use(middlewares.IsAuthenticated())
	quiz.GET("/", q.GetQuizzes)
	quiz.POST("", q.Create)
	quiz.GET("/:id", q.Get)
}

func New(router *gin.Engine, ctx *repositories.Context) *QuizHandler {
	return &QuizHandler{
		router: router,
		ctx: ctx,
	}
}
