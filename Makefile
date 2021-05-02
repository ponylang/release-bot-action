IMAGE := ponylang/release-bot-action

ifndef tag
  IMAGE_TAG := $(shell cat VERSION)
else
  IMAGE_TAG := $(tag)
endif

all: build

build:
	docker build --pull -t "${IMAGE}:${IMAGE_TAG}" .
	docker build --pull -t "${IMAGE}:latest" .

push: build
	docker push "${IMAGE}:${IMAGE_TAG}"
	docker push "${IMAGE}:latest"

pylint: build
	docker run --entrypoint pylint --rm "${IMAGE}:latest" /commands/update-version-in-README.py

.PHONY: build push pylint
