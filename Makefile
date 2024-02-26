.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help

export AWS_ACCOUNT_NUMBER ?= 1234567890
export DOCKER_REPO ?= ${AWS_ACCOUNT_NUMBER}.dkr.ecr.eu-west-1.amazonaws.com


define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@poetry run python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

codeartifact-authenticate:
	poetry config http-basic.artifact aws `aws codeartifact get-authorization-token --domain Macrovesta  --query authorizationToken --output text`

python-env:
	poetry config virtualenvs.in-project true
	poetry install

lint: check-types check-style ## run all checks

check-types: ## check types with mypy
	poetry run mypy src/

check-style: ## check style with flake8, isort and black
	poetry run ruff --fix=false .
	poetry run black --check --diff .

fix-style: ## fix black and isort style violations
	poetry run ruff .
	poetry run black .

tests: ## run tests quickly with the default Python
	poetry run pytest --verbose --capture=no

coverage: ## check code coverage quickly with the default Python
	poetry run coverage run --source src -m pytest
	poetry run coverage report -m
	poetry run coverage html
	poetry run $(BROWSER) htmlcov/index.html

release: dist ## package and upload a release, manage version yourself
	# poetry version prerelease/patch/minor/major
	# https://python-poetry.org/docs/cli/#version
	sed -i 's/simple/upload/g' pyproject.toml
	poetry publish -r pypigetfeed
	sed -i 's/upload/simple/g' pyproject.toml

dist: clean ## builds source and wheel package
	poetry build

infra__%:
	${MAKE} --directory infra -f make.mk $*

docker__%:
	${MAKE} --directory docker -f make.mk $*

build_push_deploy: docker__login docker__front__build docker__front__push infra__build infra__deploy

# Clean all the things
clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache
