IMAGE_TAG := $(shell ./scripts/generate-tag)

docker:
	docker buildx build --platform linux/amd64,linux/arm64 $(DOCKER_OPTS) -t pkrohn/k8s-backup-mysql:${IMAGE_TAG} . --push
