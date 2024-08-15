package quiz

import (
	"net/http"
	"strconv"

	"github.com/benodiwal/server/internal/models"
	"github.com/gin-gonic/gin"
)

func (q *QuizHandler) ListQuizzes(ctx *gin.Context) {
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "10"))

	quizzes, err := q.ctx.QuizRepository.ListQuizzes(page, pageSize)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H { "error": "Failed to fetch quizzes" })
		return
	}

	ctx.JSON(http.StatusOK, quizzes)
}

func (q *QuizHandler) Create(ctx *gin.Context) {
	var newQuiz models.Quiz
	if err := ctx.ShouldBindJSON(&newQuiz); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H { "error": err.Error() })
		return
	}

	userID, exists := ctx.Get("userID")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H {"error": "User not authenticated"})
		return
	}
	newQuiz.UserId = userID.(string)

	if err := q.ctx.QuizRepository.CreateQuiz(&newQuiz); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to create quiz"})
		return
	}

	ctx.JSON(http.StatusCreated, newQuiz)
}

func (q *QuizHandler) GetQuiz(ctx *gin.Context) {
	quizID, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H {"error": "Invalid quiz ID"})
		return
	}

	quiz, err := q.ctx.QuizRepository.GetQuizByID(uint(quizID))
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Quiz not found"})
		return
	}

	ctx.JSON(http.StatusOK, quiz)
}

func (q *QuizHandler) DeleteQuiz(ctx *gin.Context) {
	quizID, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quiz ID"})
		return
	}

	quiz, err := q.ctx.QuestionRepository.GetQuestionByID(uint(quizID))
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Quiz not found"})
		return
	}

	userID, _ := ctx.Get("userID")
	if quiz != userID.(uint) {
		ctx.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to delete this quiz"})
		return
	}

	if err := q.ctx.QuizRepository.DeleteQuiz(uint(quizID)); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete quiz"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Quiz deleted successfully"})
}


func (q *QuizHandler) GetQuizzesByTopic(ctx *gin.Context) {
	topicID, err := strconv.ParseUint(ctx.Param("topicId"), 10, 32)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid topic ID"})
		return
	}

	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "10"))

	_, err = q.ctx.TopicRepository.GetTopicByID(uint(topicID))
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Topic not found"})
		return
	}

	quizzes, err := q.ctx.QuizRepository.GetQuizzesByTopic(uint(topicID), page, pageSize)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch quizzes"})
		return
	}

	ctx.JSON(http.StatusOK, quizzes)
}
