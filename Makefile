IMAGE_NAME ?= tp-docker
CONTAINER_NAME ?= tp-docker
PORT ?= 80

.PHONY: all build run stop logs

all: build stop run

build:
	@echo "Building image $(IMAGE_NAME)..."
	@docker build -t $(IMAGE_NAME) $$(pwd)/src/.

stop:
	@echo "Stopping container $(CONTAINER_NAME) if running..."
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true

run:
	@echo "Running container $(CONTAINER_NAME) on port $(PORT)..."
	@docker run -d --name $(CONTAINER_NAME) \
	  -p $(PORT):80 \
	  -v $$(pwd)/.env:/.env:ro \
	  $(IMAGE_NAME)

logs:
	@docker logs -f $(CONTAINER_NAME)
