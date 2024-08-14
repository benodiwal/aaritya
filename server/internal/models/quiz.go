package models

import "github.com/jinzhu/gorm"

type Quiz struct {
	gorm.Model
	UserId string
	Title  string
	Description string
	TotalPoints int
	Questions   []Question
	Topics      []Topic `gorm:"many2many:quiz_topics;"`
	Attempts    []QuizAttempt
}
