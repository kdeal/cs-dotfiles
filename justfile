default:
	@just --list

test:
	python -m unittest discover -s tests

lint:
	uv run ruff check --fix scripts tests

format:
	uv run ruff format scripts tests

typecheck:
	ty check scripts tests

check: test lint format typecheck
