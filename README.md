arrow.mojo
====================
Apache Arrow in Mojo

This repo is very much a work in progress. The goal is to provide a way to use Apache Arrow in Mojo. This is a very early version and is not yet ready for use.

## Dev Setup

Prerequisites
- Python 3.11 (recommended via pyenv, but not required)
- [`uv`](https://github.com/astral-sh/uv) for python package management
- [Mojo](https://www.modular.com/max/mojo)

```bash
# Install python deps
make setup
```

The makefile contains some helpful commands:
- `make setup` - Install python dependencies & setup .venv
- `make test` - Run tests
- `make fmt` - Run formatter
- `make build` - Build the package
- `make clean` - Clean up build artifacts

However, for `make` commands to work 
`MODULAR_HOME` and `PATH` must be configured in `~/.zprofile` or `~/.bash_profile` in addition to `~/.zshrc` or `~/.bashrc`.

```bash
export MODULAR_HOME="$HOME/.modular"

# Pick one of the following, don't use both
# Option A: Nightly Mojo
export PATH="$HOME/.modular/pkg/packages.modular.com_nightly_mojo/bin:$PATH"
# Option B: Stable Mojo
export PATH="$HOME/.modular/pkg/packages.modular.com_mojo/bin:$PATH"
```
