package auth

import (
	"log"
	"net/http"
	"time"

	"github.com/benodiwal/server/internal/libs"
	"github.com/benodiwal/server/internal/models"
	"github.com/benodiwal/server/internal/transport/rest"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

func (h *AuthHandler) Login(ctx *gin.Context) {
	var req rest.LoginRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H {"error": err.Error()})
		return
	}

	user, err := h.ctx.UserRepository.GetUserByEmail(req.Email)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H { "error": "Failed to retrieve user" })
		return
	}

	if user == nil {
		ctx.JSON(http.StatusUnauthorized, gin.H { "error": "Invalid email or password" })
		return
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password))
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H { "erorr": "Invalid email or password" })
	}

	claims := jwt.MapClaims{
		"user_id": user.ID,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	}

	token, err := libs.SignJwt(claims)
	if err != nil {
		log.Println(err)
		ctx.JSON(http.StatusInternalServerError, gin.H { "error": "Unable to generate JWT" })
		return
	}

	ctx.JSON(http.StatusOK, gin.H {
		"message": "Login successful",
		"user": user.WithoutPassword(),
		"token": token,
	})
}

func (h *AuthHandler) Signup(ctx *gin.Context) {
	var req rest.SignupRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H { "error": err.Error() })
		return	
	}

	existingUser, err := h.ctx.UserRepository.GetUserByEmailOrUsername(req.Email, req.Username)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H { "error": "Failed to check existing user" })
		return
	}

	if existingUser != nil {
		ctx.JSON(http.StatusConflict, gin.H { "error": "User with this email or username already exists" })
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H { "error": "Failed to hash password" })
		return
	}

	newUser := &models.User{
		Username: req.Username,
		Email: req.Email,
		Password: string(hashedPassword),
	}

	err = h.ctx.UserRepository.CreateUser(newUser)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H { "error": "Failed to create user" })
		return
	}

	ctx.JSON(http.StatusOK, gin.H {
		"message": "Signup successful",
		"user": newUser.WithoutPassword(), 
	})
}
