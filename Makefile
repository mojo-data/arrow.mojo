.PHONY: test
test: fmt
	@mojo test -I .

.PHONY: build
build: fmt
	@mkdir -p dist
	@mojo package arrow -o dist/arrow.mojopkg

.PHONY: clean
clean: 
	rm -rf dist

.PHONY: fmt
fmt: 
	@mojo format arrow
	@mojo format test

.PHONY: setup
setup:
	@POETRY_VIRTUALENVS_IN_PROJECT=true poetry install