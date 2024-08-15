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

func (r *QuizRepository) GetQuizByID(id uint) (*models.Quiz, error) {
	var quiz models.Quiz
	err := r.db.First(&quiz, id).Error
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

func (r *QuizRepository) ListQuizzes(page, pageSize int) ([]models.Quiz, error) {
	var quizzes []models.Quiz
	offset := (page - 1) * pageSize
	err := r.db.Offset(offset).Limit(pageSize).Find(&quizzes).Error
	return quizzes, err
}

func (r *QuizRepository) GetQuizzesByTopic(topicID uint, page, pageSize int) ([]models.Quiz, error) {
	var quizzes []models.Quiz
	offset := (page - 1) * pageSize
	err := r.db.Joins("JOIN quiz_topics ON quizzes.id = quiz_topics.quiz_id").
		Where("quiz_topics.topic_id = ?", topicID).
		Offset(offset).Limit(pageSize).Find(&quizzes).Error
	return quizzes, err
}
