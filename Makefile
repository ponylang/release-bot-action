IMAGE := ponylang/release-bot-action

ifndef tag
  IMAGE_TAG := $(shell cat VERSION)
else
  IMAGE_TAG := $(tag)
endif

PYTHON_COMMANDS := $(shell find scripts/)

all: build

build: action.yml Dockerfile entrypoint scripts/*
	docker build --pull -t "ghcr.io/${IMAGE}:${IMAGE_TAG}" .
	docker build --pull -t "ghcr.io/${IMAGE}:latest" .
	touch $@

push: build
	docker push "ghcr.io/${IMAGE}:${IMAGE_TAG}"
	docker push "ghcr.io/${IMAGE}:latest"

pylint: build $(PYTHON_COMMANDS)
	$(foreach file, $(notdir $(PYTHON_COMMANDS)), \
		echo "Linting $(file)"; \
		docker run --entrypoint pylint --rm "ghcr.io/${IMAGE}:latest" /commands/$(file) || exit 1; \
	)

.PHONY: push
