package auth

import (
	"github.com/benodiwal/server/internal/repositories"
	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	router *gin.Engine
	ctx    *repositories.Context
}

func (h *AuthHandler) RegisterRoutes() {
	auth := h.router.Group("/auth")
	auth.POST("/login", h.Login)
	auth.POST("/signup", h.Signup)
}

func New(router *gin.Engine, ctx *repositories.Context) *AuthHandler {
	return &AuthHandler{
		router: router,
		ctx: ctx,
	}
}
