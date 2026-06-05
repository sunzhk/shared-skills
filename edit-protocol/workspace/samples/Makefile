.PHONY: build test clean lint docker-build docker-run help

# Variables
APP_NAME = myapp
BUILD_DIR = ./build
COVERAGE_THRESHOLD = 80

build: clean
	@echo "Building $(APP_NAME)..."
	mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(APP_NAME) ./cmd/...
	@echo "Build complete."

test:
	@echo "Running tests..."
	go test ./... -v -cover -coverprofile=$(BUILD_DIR)/coverage.out
	@echo "Test coverage:"
	go tool cover -func=$(BUILD_DIR)/coverage.out

lint:
	@echo "Linting..."
	golangci-lint run ./...
	@echo "Lint complete."

clean:
	@echo "Cleaning..."
	rm -rf $(BUILD_DIR)
	@echo "Clean complete."

docker-build:
	@echo "Building Docker image..."
	docker build -t $(APP_NAME):latest .
	@echo "Docker build complete."

docker-run: docker-build
	@echo "Running Docker container..."
	docker run -p 8080:8080 --name $(APP_NAME) $(APP_NAME):latest

help:
	@echo "Available commands:"
	@echo "  make build       - Build the application"
	@echo "  make test        - Run tests with coverage"
	@echo "  make lint        - Run linter"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make docker-build - Build Docker image"
	@echo "  make docker-run  - Run Docker container"
