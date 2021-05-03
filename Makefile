IMAGE := ponylang/release-bot-action

ifndef tag
  IMAGE_TAG := $(shell cat VERSION)
else
  IMAGE_TAG := $(tag)
endif

PYTHON_COMMANDS := $(shell find $(SRC_DIR) -name *.py)

all: build

build:
	docker build --pull -t "${IMAGE}:${IMAGE_TAG}" .
	docker build --pull -t "${IMAGE}:latest" .

push: build
	docker push "${IMAGE}:${IMAGE_TAG}"
	docker push "${IMAGE}:latest"

pylint: build $(PYTHON_COMMANDS)
	$(foreach file, $(notdir $(PYTHON_COMMANDS)), \
		echo "Linting $(file)"; \
		docker run --entrypoint pylint --rm "${IMAGE}:latest" /commands/$(file); \
	)

.PHONY: build push pylint
