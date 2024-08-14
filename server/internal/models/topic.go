package models

import "github.com/jinzhu/gorm"

type Topic struct {
	gorm.Model
	TopicName string `gorm:"uniqueIndex"`
	Quizzes   []Quiz   `gorm:"many2many:quiz_topics;"`
}
