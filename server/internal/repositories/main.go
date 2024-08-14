package repositories

import (
	"errors"
	"log"

	"github.com/jinzhu/gorm"
)

type Context struct {
	UserRepository *UserRepository
	db            *gorm.DB
	logger        *log.Logger
}

type Transaction = func (*gorm.DB, *Context) bool

func NewContext(db *gorm.DB, logger *log.Logger) *Context {
	return &Context{
		UserRepository: NewUserRepository(db),
		db: db,
		logger: logger,
	}
}

func (ctx *Context) ExecuteTransaction(transaction Transaction) bool {
	err := ctx.db.Transaction(
		func(tx *gorm.DB) error {
			if (transaction(tx, NewContext(tx, ctx.logger))) {
				return nil
			} else {
				return errors.New("Transaction Failed")
			}
		},
	)
	return err == nil
}
