PROJECT_CONFIG_FILE=pyproject.toml
APP_VERSION=`grep -G '^[ ]*version' ${PROJECT_CONFIG_FILE} | sed -r 's:^[ ]*version[ ]*=[ ]*"([0-9]+.[0-9]+.[0-9]+)":\1:'`
APP_NAME=`grep -G '^[ ]*name' ${PROJECT_CONFIG_FILE} | sed -r 's/[ ]*name[ ]*=[ ]*"(.*)"/\1/'`
APP_IMAGE_NAME=${APP_NAME}:${APP_VERSION}
PORT=8000

deps:
	@echo "Installing project dependencies..."
	@poetry install

dev: deps
	@echo "Running app locally with hot reload on http://localhost:${PORT}..."
	@poetry run uvicorn src.main:app \
		--loop uvloop \
		--host 0.0.0.0 \
		--port ${PORT} \
		--reload

build:
	@echo "Building ${APP_IMAGE_NAME}"
	@docker build \
		-t "${APP_IMAGE_NAME}" \
		.

serve: build
	@echo "Running app container on http://localhost:${PORT}"
	@docker run -it --rm \
		-p ${PORT}:8080 \
		${APP_IMAGE_NAME}
