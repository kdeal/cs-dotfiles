default:
	@just --list

test:
	python -m unittest discover -s tests

lint:
	ruff check --exit-non-zero-on-fix --fix scripts tests

format:
	ruff format scripts tests
	stylua .
	find . -name '*.fish' -exec fish_indent --write {} +

typecheck:
	ty check scripts tests

check: test lint format typecheck
