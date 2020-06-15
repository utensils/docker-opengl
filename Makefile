# !/usr/bin/make - f

SHELL                   := /usr/bin/env bash
SED                     := $(shell [[ `command -v gsed` ]] && echo gsed || echo sed)
REPO_API_URL            ?= https://hub.docker.com/v2
REPO_NAMESPACE          ?= utensils
REPO_USERNAME           ?= utensils
IMAGE_NAME              ?= opengl
BASE_IMAGE              ?= alpine:3.11
LLVM_VERSION            ?= 9
TAG_SUFFIX              ?= $(shell echo "-$(BASE_IMAGE)" | $(SED) 's|:|-|g' | $(SED) 's|/|_|g' 2>/dev/null )
VCS_REF                 := $(shell git rev-parse --short HEAD)
BUILD_DATE              := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
PLATFORMS               ?= linux/amd64,linux/386,linux/arm64
RELEASES                ?= stable 20.0.6 20.1.0-rc1
STABLE                  ?= 20.0.6
BUILD_PROGRESS          ?= auto
BUILD_OUTPUT            ?= type=registry
BUILD_TYPE              ?= release
BUILD_OPTIMIZATION      ?= 3

# Default target is to build all defined Mesa releases.
.PHONY: default
default: $(STABLE)

.PHONY: latest
latest: $(LATEST)

.PHONY: stable
stable: $(STABLE)

.PHONY: all
all: $(LATEST) $(STABLE) $(RELEASES)

# Build base images for all releases using buildx.
.PHONY: $(RELEASES)
.SILENT: $(RELEASES)
$(RELEASES):
	if [ "$(@)" == "stable" ]; \
	then \
		MESA_VERSION="$(STABLE)"; \
	else \
		MESA_VERSION="$(@)"; \
	fi; \
	docker buildx build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_OPTIMIZATION=$(BUILD_OPTIMIZATION) \
		--build-arg BUILD_TYPE=$(BUILD_TYPE) \
		--build-arg LLVM_VERSION=$(LLVM_VERSION) \
		--build-arg MESA_VERSION="$$MESA_VERSION"  \
		--build-arg VCS_REF=$(VCS_REF) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(@)$(TAG_SUFFIX) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(@) \
		--platform=$(PLATFORMS) \
		--progress=$(BUILD_PROGRESS) \
		--output=$(BUILD_OUTPUT) \
		--file Dockerfile .
	
# Update README on DockerHub registry.
.PHONY: push-readme
.SILENT: push-readme
push-readme:
	echo "Authenticating to $(REPO_API_URL)"; \
		token=$$(curl -s -X POST -H "Content-Type: application/json" -d '{"username": "$(REPO_USERNAME)", "password": "'"$$REPO_PASSWORD"'"}' $(REPO_API_URL)/users/login/ | jq -r .token); \
		code=$$(jq -n --arg description "$$(<README.md)" '{"registry":"registry-1.docker.io","full_description": $$description }' | curl -s -o /dev/null  -L -w "%{http_code}" $(REPO_API_URL)/repositories/$(REPO_NAMESPACE)/$(IMAGE_NAME)/ -d @- -X PATCH -H "Content-Type: application/json" -H "Authorization: JWT $$token"); \
		if [ "$$code" != "200" ]; \
		then \
			echo "Failed to update README.md"; \
			exit 1; \
		else \
			echo "Success"; \
		fi;
