package quiz

import (
	"fmt"

	"github.com/benodiwal/server/internal/repositories"
	"github.com/gin-gonic/gin"
)

type QuizHandler struct {
	router *gin.Engine
	ctx    *repositories.Context
}

func (q *QuizHandler) RegisterRoutes() {
	quiz := q.router.Group("/quiz")
	fmt.Println(quiz)
}

func New(router *gin.Engine, ctx *repositories.Context) *QuizHandler {
	return &QuizHandler{
		router: router,
		ctx: ctx,
	}
}
