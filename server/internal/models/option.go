package models

import "github.com/jinzhu/gorm"

type Option struct {
	gorm.Model
	QuestionID uint
	OptionText string
	IsCorrect  bool
}
