VERSION := $(shell docker run --rm -it node:lts bash -c "node -v")

.PHONY: push
push: build test
	docker push optimized/docker-nodejs-production; \
	git add *; \
	git commit -m "Version: $(VERSION)"; \
	git push \

.PHONY: build
build:
	@docker pull node:lts	
	@sed -i -- "s/version=.*/version=$(shell docker run --rm -it node:lts bash -c "node -v")/g" Dockerfile
	@docker build -t optimized/docker-nodejs-production:latest .
	docker tag optimized/docker-nodejs-production:latest optimized/docker-nodejs-production:$(VERSION);

.PHONY: test
test: build
	@docker run --rm -it optimized/docker-nodejs-production:$(VERSION) bash -c "node -v; yarn -v; cd /tmp; yarn install && echo Test passed; exit;"
	@docker run --rm -it optimized/docker-nodejs-production:$(VERSION) bash -c "whoami; exit;"