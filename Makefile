.DEFAULT_GOAL := help

help: ## display this help message
	@echo "Please use \`make <target>' where <target> is one of"
	@perl -nle'print $& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'

clean: ## remove generated byte code, coverage reports, and build artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -rf {} +
	find . -name '*~' -exec rm -f {} +
	coverage erase
	rm -fr build/
	rm -fr dist/
	rm -fr *.egg-info

piptools-requirements: ## install tools prior to requirements
	pip install -q -r requirements/pip_tools.txt

coverage: clean ## generate and view HTML coverage report
	py.test --cov-report html
	$(BROWSER) htmlcov/index.html

upgrade: export CUSTOM_COMPILE_COMMAND=make upgrade
upgrade: ## update the requirements/*.txt files with the latest packages satisfying requirements/*.in
	pip install -q -r requirements/pip_tools.txt
	pip-compile --upgrade -o requirements/pip_tools.txt requirements/pip_tools.in
	pip-compile --upgrade -o requirements/base.txt requirements/base.in requirements/reporting.in
	pip-compile --upgrade -o requirements/dev.txt requirements/base.in requirements/reporting.in requirements/dev-enterprise_data.in \
		                                      requirements/dev-enterprise_reporting.in requirements/quality.in
	pip-compile --upgrade -o requirements/quality.txt requirements/base.in requirements/reporting.in requirements/dev-enterprise_data.in \
	                                              requirements/quality.in requirements/test.in
	pip-compile --upgrade -o requirements/travis.txt requirements/travis.in
	pip-compile --upgrade -o requirements/test.txt requirements/base.in requirements/reporting.in requirements/test.in
	pip-compile --upgrade -o requirements/test-reporting.txt requirements/test-reporting.in
	pip-compile --upgrade -o requirements/test-master.txt requirements/base.in requirements/reporting.in requirements/test-master.in \
	                                                      requirements/test.in
	# Let tox control the Django version for tests
	grep -e "^django==" requirements/base.txt > requirements/django.txt
	sed '/^[dD]jango==/d' requirements/test-master.txt > requirements/test-master.tmp
	mv requirements/test-master.tmp requirements/test-master.txt
	sed '/^[dD]jango==/d' requirements/test-reporting.txt > requirements/test-reporting.tmp
	mv requirements/test-reporting.tmp requirements/test-reporting.txt


requirements: piptools-requirements ## install development environment requirements
	pip install -qr requirements/base.txt --exists-action w
	pip-sync requirements/base.txt requirements/dev.txt requirements/test.txt

test: clean ## run tests in the current virtualenv
	pip install -qr requirements/test.txt --exists-action w
	py.test

test-all: clean ## run tests on every supported Python/Django combination
	tox
	tox -e quality

validate: test ## run tests and quality checks
	tox -e quality

isort: ## call isort on packages/files that are checked in quality tests
	isort --recursive tests enterprise_reporting enterprise_data enterprise_data_roles manage.py setup.py

.PHONY: requirements upgrade help
