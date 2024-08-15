package repositories

import (
	"errors"
	"github.com/benodiwal/server/internal/models"
	"github.com/jinzhu/gorm"
)

type TopicRepository struct {
	db *gorm.DB
}

func NewTopicRepository(db *gorm.DB) *TopicRepository {
	return &TopicRepository{db}
}

func (r *TopicRepository) CreateTopic(topic *models.Topic) error {
	return r.db.Create(topic).Error
}

func (r *TopicRepository) GetTopicByID(id uint) (*models.Topic, error) {
	var topic models.Topic
	err := r.db.First(&topic, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &topic, nil
}

func (r *TopicRepository) GetTopicByName(name string) (*models.Topic, error) {
	var topic models.Topic
	err := r.db.Where("topic_name = ?", name).First(&topic).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &topic, nil
}

func (r *TopicRepository) UpdateTopic(topic *models.Topic) error {
	return r.db.Save(topic).Error
}

func (r *TopicRepository) DeleteTopic(id uint) error {
	return r.db.Delete(&models.Topic{}, id).Error
}

func (r *TopicRepository) ListTopics(page, pageSize int) ([]models.Topic, error) {
	var topics []models.Topic
	offset := (page - 1) * pageSize
	err := r.db.Offset(offset).Limit(pageSize).Find(&topics).Error
	return topics, err
}
