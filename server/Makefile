.PHONY: dev build run test

dev:
	@echo "Setting APP_ENV to DEV and running the application"
	@export APP_ENV=DEV && go run cmd/app/main.go

build:
	@echo "Building the application"
	@go build -o build/server cmd/app/main.go

run:
	@echo "Setting APP_ENV to PRODUCTION and running the application"
	@export APP_ENV=PRODUCTION && ./build/server

test:
	@echo "Setting APP_ENV to TEST and running test"
	@export APP_ENV=TEST && go test -v ./tests/
