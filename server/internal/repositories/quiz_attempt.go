package repositories

import (
	"errors"

	"github.com/benodiwal/server/internal/models"
	"github.com/jinzhu/gorm"
)

type QuizAttemptRepository struct {
	db *gorm.DB
}

func NewQuizAttemptRepository(db *gorm.DB) *QuizAttemptRepository {
	return &QuizAttemptRepository{db}
}

func (r *QuizAttemptRepository) CreateQuizAttempt(attempt *models.QuizAttempt) error {
	return r.db.Create(attempt).Error
}

func (r *QuizAttemptRepository) GetQuizAttemptByID(id uint) (*models.QuizAttempt, error) {
	var attempt models.QuizAttempt
	err := r.db.First(&attempt, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &attempt, nil
}

func (r *QuizAttemptRepository) UpdateQuizAttempt(attempt *models.QuizAttempt) error {
	return r.db.Save(attempt).Error
}

func (r *QuizAttemptRepository) GetQuizAttemptsByUserID(userID uint) ([]models.QuizAttempt, error) {
	var attempts []models.QuizAttempt
	err := r.db.Where("user_id = ?", userID).Find(&attempts).Error
	return attempts, err
}

func (r *QuizAttemptRepository) GetQuizAttemptsByQuizID(quizID uint) ([]models.QuizAttempt, error) {
	var attempts []models.QuizAttempt
	err := r.db.Where("quiz_id = ?", quizID).Find(&attempts).Error
	return attempts, err
}
