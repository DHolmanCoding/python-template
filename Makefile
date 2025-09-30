install:
	uv sync

update:
	uv sync --upgrade

hooks:
	uv run pre-commit install

pre:
	uv run pre-commit run --all-files
