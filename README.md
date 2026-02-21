# Python Template

Python boilerplate to kickstart your projects in style!

# Setting up Python and your Virtual Environment

This project template uses [uv](https://github.com/astral-sh/uv) to manage Python dependencies. uv is a fast Python package installer and resolver written in Rust. There are
two types of dependencies: core dependencies and development dependencies. Core dependencies are those that are required
to be installed for the main, production release of your project or package. Development dependencies are auxiliary
packages that are useful in aiding in providing functionality such as formatting, documentation or type-checking, but
are non-essential for the production release.

For each dependency you come across, make a determination on whether it
is a core or development dependency, and add it to the pyproject.toml file from the command line using the following
command, where the `--dev` flag is to be used only for development dependencies.
```
uv add [--dev] <name-of-dependency>
```

When you are ready to run your code and have added all your dependencies, you can perform a `uv lock` in order to
reproducibly fix your dependency versions. This will use the pyproject.toml file to create a uv.lock file. Then, in
order to run your code, you can use the following commands to set up a virtual environment and then run your code
within the virtual environment. The optional `--no-dev` flag indicates that you only wish to install core dependencies.
```
uv sync [--no-dev]
uv run <your-command>
```

# Initializing Pre-Commit Hooks

This repository uses pre-commit hooks in order to assist you in maintaining a uniform and idiomatic code style.
If this is your first time using pre-commit hooks you can install the framework [here](https://pre-commit.com/#installation).
Once pre-commit is installed, all you need to do is execute the following command from the repository root:
```
pre-commit install
```

If you want to execute the pre-commit hooks at a time other than during the actual git commit, you can run:
```
pre-commit run --all-files
```

# Containerizing your package

Build with `make bd` (dev/fast image) or `make bd TARGET=runtime-prod` (prod image with PGO+LTO Python).

# TODO

1. Add additional pre-commit hooks that could be useful to users
2. Add documentation about how to release your package to PyPI with uv
