SHELL   := /bin/bash
VERSION := 1.10

.PHONY: help all mirrormaker mirror mirrorserver build force-build untag clean run push

help: ## This help message
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

all: help

mirrormaker:
	@if ! docker images mirrormaker | awk '{ print $$2 }' | grep -q -F ${VERSION}; then \
		echo 'mirrormaker needs building...'; \
		docker build -t mirrormaker:${VERSION} --rm -f Dockerfile.mirrormaker .; \
	else \
		echo 'mirrormaker is built.'; \
	fi

mirror: mirrormaker
	@if ! ls -A mirror &> /dev/null; then \
		echo 'The repositories need to be mirrored' \
		mkdir -p mirror; \
		docker run -it --rm -v ${PWD}/mirror:/var/www/mirror mirrormaker:${VERSION}; \
	else \
		echo 'The repositories have been mirrored.'; \
	fi

mirrorserver: mirror
	@if ! docker images mirrorserver | awk '{ print $$2 }' | grep -q -F ${VERSION}; then \
		echo 'mirrorserver needs building...'; \
		docker build -t mirrorserver:${VERSION} --rm -f Dockerfile.mirrorserver .; \
	else \
		echo 'mirrorserver is built.'; \
	fi

build: mirrorserver ## build the mirror server

force-build: untag mirrorserver ## force a rebuild while keeping the cache

untag:
	docker rmi --no-prune -f mirrormaker:${VERSION} || true
	docker rmi --no-prune -f mirrorserver:${VERSION} || true

clean: ## start from scratch
	rm -rf mirror
	docker rmi -f mirrormaker:${VERSION} || true
	docker rmi -f mirrorserver:${VERSION} || true

run: ## run the mirror server
	@if ! docker images mirrorserver | awk '{ print $$2 }' | grep -q -F ${VERSION}; then \
		echo 'mirrorserver is not yet built. Please run make build'; \
		false; \
	else \
		docker run -it --rm -p 2015:2015 mirrorserver:${VERSION} ; \
	fi

push: guard-DOCKER_REPO ## push the mirror server to a Docker repository
	docker tag mirrorserver ${DOCKER_REPO}:latest
	docker tag mirrorserver ${DOCKER_REPO}:${VERSION}
	docker push ${DOCKER_REPO}:latest
	docker push ${DOCKER_REPO}:${VERSION}

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi
