uvi:  # uvi = uv install
	uv sync

uvu:  # uvu = uv upgrade
	uv sync --upgrade

hooks:
	uv run pre-commit install

pre:
	uv run pre-commit run --all-files

pt:  # pt = Python Tests
	uv run pytest --cov=python_template tests
