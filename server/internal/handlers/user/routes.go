package user

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func (u *UserHandler) Me(ctx *gin.Context) {
	userId, _ := ctx.Get("user_id")
	user, err := u.ctx.UserRepository.GetUserByID(userId.(uint))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to fetch user data"})
		return
	}
	ctx.JSON(http.StatusOK, user)
}

func (u *UserHandler) Quizes(ctx *gin.Context) {
	userId, _ := ctx.Get("user_id")
	limit := 10
	quizzes, err := u.ctx.QuizRepository.GetRecentQuizzesByUserID(userId.(uint), limit)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to fetch quizzes"})
		return
	}
	ctx.JSON(http.StatusOK, quizzes)
}

func (u *UserHandler) Leaderboard(ctx *gin.Context) {
	limit := 10
	users, err := u.ctx.UserRepository.GetTopUsers(limit)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to fetch leaderboard"})
		return
	}
	ctx.JSON(http.StatusOK, users)
}
