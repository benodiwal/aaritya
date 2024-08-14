package models

import "github.com/jinzhu/gorm"

type UserAnswer struct {
	gorm.Model
	AttemptID  uint
	QuestionID uint
	OptionId uint
	IsCorrect  bool
}
