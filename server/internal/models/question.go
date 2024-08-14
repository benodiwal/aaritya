package models

import "github.com/jinzhu/gorm"

type Question struct {
	gorm.Model
	QuizID uint
	QuestionText string
	Points int
	Options []Option
	UserAnswers []UserAnswer
}
