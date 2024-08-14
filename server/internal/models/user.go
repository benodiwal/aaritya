package models

import "github.com/jinzhu/gorm"

type User struct {
	gorm.Model
	Username string `gorm:"uniqueIndex"`
	Email string `gorm:"uniqueIndex"`
	Password string
	TotalPoints int `gorm:"default:0"`
	Quizzes  []Quiz `gorm:"foreignKey:UserID"`
}
