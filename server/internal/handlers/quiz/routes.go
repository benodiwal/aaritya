package quiz

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/benodiwal/server/internal/models"
	"github.com/benodiwal/server/internal/transport/rest"
	"github.com/gin-gonic/gin"
)

func (q *QuizHandler) Create(ctx *gin.Context) {
	var req rest.CreateQuizRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		fmt.Println(err)
		ctx.JSON(http.StatusBadRequest, gin.H {"error": err.Error()})
		return
	}

	userId := ctx.MustGet("userId").(float64)

	quiz := models.Quiz {
		UserId: uint(userId),
		Title: req.Title,
		Description: req.Description,
		TimeLimit: req.TimeLimit,
		Difficulty: req.Difficulty,
	}

	if err := q.ctx.QuizRepository.CreateQuiz(&quiz); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to create quiz"})
		return
	}

	totalPoints := 0

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

		totalPoints += ques.Points

		for _, o := range ques.Options {
			fmt.Println(o)
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

	quiz.TotalPoints = totalPoints
	if err := q.ctx.QuizRepository.UpdateQuiz(&quiz); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update quiz with total points"})
		return
	}

	for _, topicName := range req.Topics {
		topic := models.Topic{
			TopicName: topicName,
		}
		if err := q.ctx.TopicRepository.CreateTopic(&topic); err != nil {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create topic"})
			return
		}

		if err := q.ctx.QuizRepository.AddTopicToQuiz(&quiz, &topic); err != nil {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to associate topic with quiz"})
			return
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
	idStr := ctx.Param("id")
	id, _ := strconv.ParseUint(idStr, 10, 32)
	quiz, err := q.ctx.QuizRepository.GetQuizByID(uint(id))
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H {"error": "Quiz not found"})
		return
	}

	ctx.JSON(http.StatusOK, quiz)
}

func (q *QuizHandler) SubmitQuizAttempt(ctx *gin.Context) {
	var req rest.QuizAttemptRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		fmt.Println(err)
		ctx.JSON(http.StatusBadRequest, gin.H {"error": err.Error()})
		return
	}

	userId := ctx.MustGet("userId").(float64)

	_, err := q.ctx.QuizRepository.GetQuizByID(req.QuizID)
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H {"error": "Quiz not found"})
		return
	}

	attempt := models.QuizAttempt {
		UserID: uint(userId),
		QuizID: req.QuizID,
		CompletedAt: time.Now(),
	}

	if err := q.ctx.QuizAttemptRepository.CreateQuizAttempt(&attempt); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to create quiz attempt"})
		return
	}

	score := 0
	for _, answer := range req.Answers {
		question, err := q.ctx.QuestionRepository.GetQuestionByID(answer.QuestionID)
		if err != nil {
			ctx.JSON(http.StatusNotFound, gin.H {"error": "Question not found"})
			return
		}

		selectedOption, err := q.ctx.OptionRepository.GetOptionByID(answer.OptionID)
		if err != nil {
			ctx.JSON(http.StatusNotFound, gin.H {"error": "Option not found"})
			return
		}

		userAnswer := models.UserAnswer {
			AttemptID: attempt.ID,
			QuestionID: answer.QuestionID,
			OptionId: answer.OptionID,
			IsCorrect: selectedOption.IsCorrect,
		}

		if err := q.ctx.UserAnswerRepository.CreateUserAnswer(&userAnswer); err != nil {
			ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to save user answer"})
			return
		}

		if selectedOption.IsCorrect {
			score += question.Points			
		}
	}

	attempt.Score = score
	err = q.ctx.QuizAttemptRepository.UpdateQuizAttempt(&attempt)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to update quiz attempt score"})
		return
	}

	user, err := q.ctx.UserRepository.GetUserByID(uint(userId))
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H {"error": "User not found"})
		return
	}
	user.TotalPoints += score
	err = q.ctx.UserRepository.UpdateUser(user)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to update user's total points"})
		return
	}
	ctx.JSON(http.StatusCreated, gin.H {"message": "Quiz Attempt submitted successfully", "score": score})
}
