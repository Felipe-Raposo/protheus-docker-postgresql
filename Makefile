export DOCKER_BUILDKIT := 1

IMAGE_REPO := feliperaposo
NAME := $(IMAGE_REPO)/protheus-postgresql
VERSION := 16

.PHONY: build release release_latest

build:
	docker image build -t $(NAME):$(VERSION) -t $(NAME):latest .

release: build
	docker image push $(NAME):$(VERSION)

release_latest: release
	docker image push $(NAME):latest
