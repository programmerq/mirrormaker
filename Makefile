# Needed SHELL since I'm using zsh
SHELL := /bin/bash
.PHONY: help all mirrormaker mirrorserver

help: ## This help message
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

all: ## build everything

mirrormaker:  ## build the image to make a CS mirror
	docker build -t mirrormaker -f Dockerfile.mirrormaker .

mirror: mirrormaker ## mirror CS to a local directory
	mkdir -p mirror
	docker run -it --rm -v ${PWD}/mirror:/var/www/mirror mirrormaker

mirrorserver: | mirror
	docker build -t mirrorserver -f Dockerfile.mirrorserver .

all: mirrormaker mirrorserver

run: ## run the mirror 
	docker run -it --rm -p 2015:2015 mirrorserver
