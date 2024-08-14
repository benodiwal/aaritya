package models

import (
	"time"

	"github.com/jinzhu/gorm"
)

type QuizAttempt struct {
	gorm.Model
	UserID uint
	QuizID uint
	Score  int
	CompletedAt time.Time
}
