package repositories

import (
	"errors"

	"github.com/benodiwal/server/internal/models"
	"github.com/jinzhu/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{ db }
}


func (r *UserRepository) CreateUser(user *models.User) error {
	return r.db.Create(user).Error
}

func (r *UserRepository) GetUserByID(id uint) (*models.User, error) {
	var user models.User
	err := r.db.First(&user, id).Error
	if err != nil {
		if gorm.IsRecordNotFoundError(err) {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetUserByEmail(email string) (*models.User, error) {
	var user models.User
	err := r.db.Where("email = ?", email).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetUserByUsername(username string) (*models.User, error) {
	var user models.User
	err := r.db.Where("username = ?", username).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetUserByEmailOrUsername(email string, username string) (*models.User, error) {
	var user models.User
	err := r.db.Where("email = ? OR username = ?", email, username).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) UpdateUser(user *models.User) error {
	return r.db.Save(user).Error
}

func (r *UserRepository) DeleteUser(id uint) error {
	return r.db.Delete(&models.User{}, id).Error
}

func (r *UserRepository) ListUsers(page, pageSize int) ([]models.User, error) {
	var users []models.User
	offset := (page - 1) * pageSize
	err := r.db.Offset(offset).Limit(pageSize).Find(&users).Error
	return users, err
}

func (r *UserRepository) UpdateUserPoints(userID uint, points int) error {
	return r.db.Model(&models.User{}).Where("id = ?", userID).Update("total_points", gorm.Expr("total_points + ?", points)).Error
}

func (r *UserRepository) GetTopUsers(limit int) ([]models.User, error) {
	var users []models.User
	err := r.db.Order("total_points DESC").Limit(limit).Find(&users).Error
	return users, err
}


func (r *UserRepository) GetUserRank(userID uint) (int, error) {
	var rank int
	var user models.User

	if err := r.db.Select("total_points").First(&user, userID).Error; err != nil {
		return 0, err
	}

	if err := r.db.Model(&models.User{}).
		Where("total_points > ?", user.TotalPoints).
		Count(&rank).Error; err != nil {
		return 0, err
	}

	rank++

	return rank, nil
}
