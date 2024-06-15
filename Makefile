.PHONY: test
test: fmt
	mojo test -I .

.PHONY: build
build: fmt
	@mkdir -p dist
	@mojo package arrow -o dist/arrow.mojopkg

.PHONY: clean
clean: 
	rm -rf dist

.PHONY: fmt
fmt: 
	@mojo format arrow test

.PHONY: setup
setup:
	pip install -r requirements.txt
	@pre-commit install
	@echo "\n***\nInstalling python dependencies\n***\n"
	POETRY_VIRTUALENVS_IN_PROJECT=true poetry install
	@echo "\n***\nRunning tests (they should all pass)\n***\n"
	poetry run mojo test -I .
