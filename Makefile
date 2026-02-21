.PHONY: help uvi uvu hooks pre format lint typecheck test test_cov ci pt install static_analysis build bd bd-prod clean
.DEFAULT_GOAL := help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "  install         Install all dependencies (uv sync)"
	@echo "  format          Format code with isort and black"
	@echo "  lint            Check style and lint (isort, black, ruff)"
	@echo "  typecheck       Run mypy on python_template and tests"
	@echo "  static_analysis Run lint and typecheck"
	@echo "  test            Run unit tests"
	@echo "  test_cov        Run tests with coverage report"
	@echo "  ci              Full gate: static_analysis then test"
	@echo "  bd		         Build Docker image (fast, default)"
	@echo "  bd-prod         Build Docker image (production, PGO+LTO)"
	@echo "  clean           Remove dist/, caches, and __pycache__"
	@echo ""
	@echo "  hooks           Install pre-commit hooks"
	@echo "  pre             Run pre-commit on all files"
	@echo "  uvi             Same as install"
	@echo "  uvu             Upgrade all dependencies"
	@echo "  tc              Same as typecheck"
	@echo "  pt              Same as test"

uvi:  # uvi = uv install
	uv sync

uvu:  # uvu = uv upgrade
	uv sync --upgrade

hooks:
	uv run pre-commit install

install: uvi hooks

pre:
	uv run pre-commit run --all-files

format:
	uv run isort python_template tests
	uv run black python_template tests

lint:
	uv run isort --check-only python_template tests
	uv run black --check python_template tests
	uv run ruff check .

typecheck tc:
	uv run mypy python_template tests

test:
	uv run pytest

test_cov:
	uv run pytest --cov=python_template --cov-report=term-missing

static_analysis:
	$(MAKE) lint
	$(MAKE) typecheck

ci:
	$(MAKE) static_analysis
	$(MAKE) test_cov

bp:  # bp = build python
	uv build

build bd:  # bd = build docker
	docker build -t python-template .

bd-prod:  # bd-prod = build docker production
	docker build --target runtime-prod -t python-template:prod .

clean:
	rm -rf dist .ruff_cache .mypy_cache .pytest_cache
	find . -type d -name __pycache__ -delete 2>/dev/null || true
	find . -type d -name "*.egg-info" -delete 2>/dev/null || true
