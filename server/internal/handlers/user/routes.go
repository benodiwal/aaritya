package user

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func (u *UserHandler) Me(ctx *gin.Context) {
	userId, _ := ctx.Get("userId")
	user, err := u.ctx.UserRepository.GetUserByID(uint(userId.(float64)))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to fetch user data"})
		return
	}
	ctx.JSON(http.StatusOK, user)
}

func (u *UserHandler) Quizes(ctx *gin.Context) {
	userId, _ := ctx.Get("userId")
	limit := 10
	quizzes, err := u.ctx.QuizRepository.GetRecentQuizzesByUserID(uint(userId.(float64)), limit)
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

func (u *UserHandler) Rank(ctx *gin.Context) {
	userId, _ := ctx.Get("userId")
	rank, err := u.ctx.UserRepository.GetUserRank(uint(userId.(float64)))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to fetch user rank"})
		return
	}
	ctx.JSON(http.StatusOK, gin.H {"rank": rank})
}

func (u *UserHandler) Total(ctx *gin.Context) {
	userId, _ := ctx.Get("userId")
	score, err := u.ctx.UserRepository.GetUserAverageScore(uint(userId.(float64)))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to fetch user average score"})
		return
	}
	ctx.JSON(http.StatusOK, score)
}

func (u *UserHandler) Average(ctx *gin.Context) {
	userId, _ := ctx.Get("userId")
	total, err := u.ctx.UserRepository.GetUserTotalQuizzes(uint(userId.(float64)))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H {"error": "Failed to fetch user total quizzes"})
		return
	}
	ctx.JSON(http.StatusOK, total)
}


func (u *UserHandler) UploadProfileImage(ctx *gin.Context) {
	userId := ctx.MustGet("userId").(float64)
	key := fmt.Sprintf("profile-image/%f.jpg", userId)

	url, err := u.s3Service.GeneratePresignedURL(key, "image/jpeg", 15*time.Minute)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate upload URL"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"uploadUrl": url})
}
