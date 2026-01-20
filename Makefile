IMAGE_NAME ?= tp-docker
CONTAINER_NAME ?= tp-docker
HTTP_PORT ?= 80
HTTPS_PORT ?= 443
MYSQL_PORT ?= 3306

.PHONY: all build run stop clean fclean re logs

all: build stop run

build:
	@echo "Building image $(IMAGE_NAME)..."
	@docker build -t $(IMAGE_NAME) $$(pwd)/src/.

stop:
	@echo "Stopping container $(CONTAINER_NAME) if running..."
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true

clean: stop

fclean: clean
	@echo "Removing image $(IMAGE_NAME) if it exists..."
	@docker rmi $(IMAGE_NAME) 2>/dev/null || true

re: fclean build run

run:
	@echo "Running container $(CONTAINER_NAME) on HTTP_PORT $(HTTP_PORT)..."
	@docker run -d --name $(CONTAINER_NAME) \
	  -p $(HTTP_PORT):80 \
	  -p $(MYSQL_PORT):3306 \
	  -p $(HTTPS_PORT):443 \
	  -v $$(pwd)/.env:/.env:ro \
	  $(IMAGE_NAME)

logs:
	@docker logs -f $(CONTAINER_NAME)

