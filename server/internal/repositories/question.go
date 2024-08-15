package repositories

import (
	"errors"

	"github.com/benodiwal/server/internal/models"
	"github.com/jinzhu/gorm"
)

type QuestionRepository struct {
	db *gorm.DB
}

func NewQuestionRepository(db *gorm.DB) *QuestionRepository {
	return &QuestionRepository{db}
}

func (r *QuestionRepository) CreateQuestion(question *models.Question) error {
	return r.db.Create(question).Error
}

func (r *QuestionRepository) GetQuestionByID(id uint) (*models.Question, error) {
	var question models.Question
	err := r.db.First(&question, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &question, nil
}

func (r *QuestionRepository) UpdateQuestion(question *models.Question) error {
	return r.db.Save(question).Error
}

func (r *QuestionRepository) DeleteQuestion(id uint) error {
	return r.db.Delete(&models.Question{}, id).Error
}

func (r *QuestionRepository) GetQuestionsByQuizID(quizID uint) ([]models.Question, error) {
	var questions []models.Question
	err := r.db.Where("quiz_id = ?", quizID).Find(&questions).Error
	return questions, err
}
