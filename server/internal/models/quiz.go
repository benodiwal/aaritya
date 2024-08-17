package models

import "github.com/jinzhu/gorm"

type Quiz struct {
	gorm.Model
	UserId uint
	Title  string
	Description string
	TimeLimit int
	TotalPoints int
	Difficulty string
	Questions   []Question
	Topics      []Topic `gorm:"many2many:quiz_topics;"`
	Attempts    []QuizAttempt
}
