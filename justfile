default:
	@just --list

test:
	python -m unittest discover -s tests

lint:
	ruff check --fix bin/cmd-install tests

format:
	ruff format bin/cmd-install tests
	stylua .
	find . -name '*.fish' -exec fish_indent --write {} +
	oxfmt

typecheck:
	ty check bin/cmd-install tests

check: test lint format typecheck
