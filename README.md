arrow.mojo
====================
Apache Arrow in Mojo

This repo is very much a work in progress. The goal is to provide a way to use Apache Arrow in Mojo. This is a very early version and is not yet ready for use.

## Dev Setup

Prerequisites
- pyenv
- poetry
- Python installed via pyenv

```bash
# Install the right python version
pyenv install $(cat .python-version)

# Install python deps
make setup
```

The makefile contains some helpful commands:
- `make setup` - Install python dependencies
- `make test` - Run tests
- `make fmt` - Run formatter
- `make build` - Build the package
- `make clean` - Clean up build artifacts

However, for `make` commands to work `~/.zprofile` or `~/.bash_profile` must set MODULAR_HOME and modify the PATH to include `nightly/mojo`'s `bin` directory. For example:

```bash
export MODULAR_HOME="$HOME/.modular"
export PATH="$HOME/.modular/pkg/packages.modular.com_nightly_mojo/bin:$PATH"
```
