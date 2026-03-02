export DOCKER_BUILDKIT := 1

IMAGE_REPO := feliperaposo
NAME := $(IMAGE_REPO)/protheus-postgresql
VERSION := 16

.PHONY: build release release_latest

build:
	docker image build -t $(NAME):$(VERSION) .

release: build
	docker image push $(NAME):$(VERSION)

release_latest: release
	docker image tag $(NAME):$(VERSION) $(NAME):latest
	docker image push $(NAME):latest
