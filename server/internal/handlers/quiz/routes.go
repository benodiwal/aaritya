package quiz

import (
	"net/http"
	"strconv"

	"github.com/benodiwal/server/internal/models"
	"github.com/benodiwal/server/internal/transport/rest"
	"github.com/gin-gonic/gin"
)

func (q *QuizHandler) Create(ctx *gin.Context) {
	var req rest.CreateQuizRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H {"error": err.Error()})
		return
	}

	userId := ctx.MustGet("user_id").(string)

	quiz := models.Quiz {
		UserId: userId,
		Title: req.Title,
		Description: req.Descriptoin,
		TimeLimit: req.TimeLimit,
	}

	if err := q.ctx.QuizRepository.CreateQuiz(&quiz); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to create quiz"})
		return
	}

	for _, ques := range req.Questions {
		question := models.Question {
			QuizID: quiz.ID,
			QuestionText: ques.QuestionText,
			Points: ques.Points,
		}
		if err := q.ctx.QuestionRepository.CreateQuestion(&question); err != nil {
			ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to create question"})
			return
		}

		for _, o := range question.Options {
			option := models.Option {
				QuestionID: question.ID,
				OptionText: o.OptionText,
				IsCorrect: o.IsCorrect,
			}
			if err := q.ctx.OptionRepository.CreateOption(&option); err != nil {
				ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to create option"})
				return
			}
		}
	}

	ctx.JSON(http.StatusCreated, gin.H{"message": "Quiz created successfully", "quiz_id": quiz.ID})
}

func (q *QuizHandler) GetQuizzes(ctx *gin.Context) {
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "10"))

	quizzes, totalCount, err := q.ctx.QuizRepository.GetQuizzes(page, pageSize)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to fetch quizzes"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H {
		"quizzes": quizzes,
		"total": totalCount,
		"page": page,
		"pageSize": pageSize,
	})
}

func (q *QuizHandler) Get(ctx *gin.Context) {
	id := ctx.Param("id")
	quiz, err := q.ctx.QuizRepository.GetQuizByID(id)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H {"error": "Quiz not found"})
		return
	}

	ctx.JSON(http.StatusOK, quiz)
}
