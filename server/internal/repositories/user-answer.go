package repositories

import (
	"errors"

	"github.com/benodiwal/server/internal/models"
	"github.com/jinzhu/gorm"
)

type UserAnswerRepository struct {
	db *gorm.DB
}

func NewUserAnswerRepository(db *gorm.DB) *UserAnswerRepository {
	return &UserAnswerRepository{db}
}

func (r *UserAnswerRepository) CreateUserAnswer(answer *models.UserAnswer) error {
	return r.db.Create(answer).Error
}

func (r *UserAnswerRepository) GetUserAnswerByID(id uint) (*models.UserAnswer, error) {
	var answer models.UserAnswer
	err := r.db.First(&answer, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &answer, nil
}

func (r *UserAnswerRepository) UpdateUserAnswer(answer *models.UserAnswer) error {
	return r.db.Save(answer).Error
}

func (r *UserAnswerRepository) GetUserAnswersByAttemptID(attemptID uint) ([]models.UserAnswer, error) {
	var answers []models.UserAnswer
	err := r.db.Where("attempt_id = ?", attemptID).Find(&answers).Error
	return answers, err
}
