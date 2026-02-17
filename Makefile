.PHONY: uvi uvu hooks pre format lint typecheck test ci pt

uvi:  # uvi = uv install
	uv sync

uvu:  # uvu = uv upgrade
	uv sync --upgrade

hooks:
	uv run pre-commit install

pre:
	uv run pre-commit run --all-files

format:
	uv run isort python_template tests
	uv run black python_template tests

lint:
	uv run isort --check-only python_template tests
	uv run black --check python_template tests
	uv run ruff check .

tc:  # tc = typecheck
	uv run mypy python_template tests

test:
	uv run pytest

ci:
	$(MAKE) lint
	$(MAKE) typecheck
	$(MAKE) test

pt:  # pt = Python Tests
	$(MAKE) test
