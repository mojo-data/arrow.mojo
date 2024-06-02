.PHONY: test
test: fmt
	@mojo test -I .

.PHONY: run
run: fmt
	@mojo run arrow/main.mojo

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