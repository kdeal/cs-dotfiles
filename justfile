default:
	@just --list

test:
	python -m unittest discover -s tests

lint:
	ruff check --fix scripts tests

format:
	ruff format scripts tests
	stylua .
	find . -name '*.fish' -exec fish_indent --write {} +
	oxfmt

typecheck:
	ty check scripts tests

check: test lint format typecheck
