package quiz

import (
	"github.com/benodiwal/server/internal/repositories"
	"github.com/gin-gonic/gin"
)

type QuizHandler struct {
	router *gin.Engine
	ctx    *repositories.Context
}

func (q *QuizHandler) RegisterRoutes() {
	quiz := q.router.Group("/quiz")
	quiz.GET("/", q.ListQuizzes)
	quiz.POST("/", q.Create)
	quiz.GET("/:id", q.GetQuiz)
	quiz.DELETE("/:id", q.DeleteQuiz)
	quiz.GET("/topic/:topicId", q.GetQuizzesByTopic)
}

func New(router *gin.Engine, ctx *repositories.Context) *QuizHandler {
	return &QuizHandler{
		router: router,
		ctx: ctx,
	}
}
