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
	@uv venv
	@echo "\n***\nInstalling python dependencies\n***\n"
	@uv pip install -r requirements.txt
	@echo "\n***\nInstalling pre-commit hooks\n***\n"
	@./.venv/bin/pre-commit install
	@echo "\n***\nRunning tests (they should all pass)\n***\n"
	@source .venv/bin/activate && mojo test -I .