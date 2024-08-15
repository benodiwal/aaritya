package libs

import (
	"errors"
	"github.com/benodiwal/server/internal/env"
	"github.com/golang-jwt/jwt/v5"
)

func SignJwt(claims jwt.MapClaims) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(env.GetEnv(env.JWT_SECRET)))
	if err != nil {
		return "", err
	}
	return tokenString, nil
}

func VerifyJwt(tokenString string) (jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(env.GetEnv(env.JWT_SECRET)), nil
	})
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(jwt.MapClaims)
	if !token.Valid || !ok {
		return nil, errors.New("invalid token")
	}
	return claims, nil
}
