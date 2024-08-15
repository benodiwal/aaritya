package repositories

import (
	"errors"

	"github.com/benodiwal/server/internal/models"
	"github.com/jinzhu/gorm"
)

type OptionRepository struct {
	db *gorm.DB
}

func NewOptionRepository(db *gorm.DB) *OptionRepository {
	return &OptionRepository{db}
}

func (r *OptionRepository) CreateOption(option *models.Option) error {
	return r.db.Create(option).Error
}

func (r *OptionRepository) GetOptionByID(id uint) (*models.Option, error) {
	var option models.Option
	err := r.db.First(&option, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &option, nil
}

func (r *OptionRepository) UpdateOption(option *models.Option) error {
	return r.db.Save(option).Error
}

func (r *OptionRepository) DeleteOption(id uint) error {
	return r.db.Delete(&models.Option{}, id).Error
}

func (r *OptionRepository) GetOptionsByQuestionID(questionID uint) ([]models.Option, error) {
	var options []models.Option
	err := r.db.Where("question_id = ?", questionID).Find(&options).Error
	return options, err
}
