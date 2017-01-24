
PACKAGE_VERSION=$(shell node -pe "require('./package.json').version")

build:
	docker build \
		--build-arg NPM_TOKEN=${NPM_TOKEN} \
		-t getlazy/lazy:$(PACKAGE_VERSION) \
		-t getlazy/lazy:latest \
		-t us.gcr.io/decent-terra-156222/lazy:$(PACKAGE_VERSION) \
		-t us.gcr.io/decent-terra-156222/lazy:latest \
		.

push:
	docker push getlazy/lazy:$(PACKAGE_VERSION)
	docker push getlazy/lazy:latest
	gcloud docker -- push us.gcr.io/decent-terra-156222/lazy:$(PACKAGE_VERSION)
	gcloud docker -- push us.gcr.io/decent-terra-156222/lazy:latest

test:
	docker run -it --rm \
	    -v "$(shell pwd):/app" \
	    -v "/var/run/docker.sock:/var/run/docker.sock" \
	    -w /app \
	    --stop-signal SIGINT \
	    ierceg/node-dev:6.9.1 \
	    mocha -r test/bootstrap

test-cont:
	docker run -it --rm \
	    -v "$(shell pwd):/app" \
	    -v "/var/run/docker.sock:/var/run/docker.sock" \
	    -w /app \
	    --stop-signal SIGINT \
	    ierceg/node-dev:6.9.1 \
	    nodemon -V -d 1 -L -w /app --exec mocha -r test/bootstrap

coverage:
	docker run -it --rm \
	    -v "$(shell pwd):/app" \
	    -v "/var/run/docker.sock:/var/run/docker.sock" \
	    -w /app \
	    --stop-signal SIGINT \
	    ierceg/node-dev:6.9.1 \
	    istanbul cover _mocha -- --recursive -r test/bootstrap
	docker run -it --rm \
	    -v "$(shell pwd):/app" \
	    -v "/var/run/docker.sock:/var/run/docker.sock" \
	    -w /app \
	    ierceg/node-dev:6.9.1 \
	    istanbul report text

.PHONY: *
