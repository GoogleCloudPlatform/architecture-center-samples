# Variables
PROJECT_ID ?= your-gcp-project-id
REGION ?= us-central1
REPO_NAME ?= cloudrun
IMAGE_NAME ?= agent-app
TAG ?= latest
DOCKER_IMAGE = ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${TAG}

.PHONY: help build run-local push deploy

help:
	@echo "Available commands:"
	@echo "  make build      - Build the Docker image"
	@echo "  make run-local  - Run the Docker container locally on port 8080"
	@echo "  make push       - Push the Docker image to Google Artifact Registry"

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

run-local: build
	docker run -p 8080:8080 -e PORT=8080 $(IMAGE_NAME):$(TAG)

push: build
	docker tag $(IMAGE_NAME):$(TAG) $(DOCKER_IMAGE)
	docker push $(DOCKER_IMAGE)