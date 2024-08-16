package repositories

import (
	"errors"

	"github.com/benodiwal/server/internal/models"
	"github.com/jinzhu/gorm"
)

type QuizRepository struct {
	db *gorm.DB
}

func NewQuizRepository(db *gorm.DB) *QuizRepository {
	return &QuizRepository{db}
}

func (r *QuizRepository) CreateQuiz(quiz *models.Quiz) error {
	return r.db.Create(quiz).Error
}

func (r *QuizRepository) GetQuizzes(page, pageSize int) ([]models.Quiz, int64, error) {
	var quizzes []models.Quiz
	var totalCount int64

	if err := r.db.Model(&models.Quiz{}).Count(&totalCount).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	
	err := r.db.Offset(offset).Limit(pageSize).Preload("Topics").Find(&quizzes).Error
	if err != nil {
		return nil, 0, err
	}

	return quizzes, totalCount, nil
}

func (r *QuizRepository) GetQuizByID(id uint) (*models.Quiz, error) {
	var quiz models.Quiz
	err := r.db.Preload("Questions.Options").Preload("Topics").First(&quiz, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &quiz, nil
}

func (r *QuizRepository) UpdateQuiz(quiz *models.Quiz) error {
	return r.db.Save(quiz).Error
}

func (r *QuizRepository) DeleteQuiz(id uint) error {
	return r.db.Delete(&models.Quiz{}, id).Error
}

func (r *QuizRepository) GetRecentQuizzesByUserID(userID uint, limit int) ([]models.Quiz, error) {
	var quizzes []models.Quiz
	err := r.db.Where("user_id = ?", userID).Order("created_at DESC").Limit(limit).Find(&quizzes).Error
	return quizzes, err
}
