SHELL:=/bin/bash
.PHONY: clean test

#################################################################################
# GLOBALS                                                                       #
#################################################################################

ifeq (,$(shell which conda))
	@echo ">>> Please install Conda"
endif

ifeq (,$(shell which npm))
	@echo ">>> Please install node.js"
endif

ifeq (,$(shell which python3))
	@echo ">>> Please install Python3"
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Install packages
install:
	python -m pip install --upgrade pip
	pip install -e .


## Delete all compiled Python files
clean:
	@echo ⚡⚡⚡ Cleaning cache ⚡⚡⚡ 
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf .pytest_cache
	rm -rf .cache
	@echo
	@echo ⚡⚡⚡ Cleaning build ⚡⚡⚡ 
	find . -type f -name "*.egg-info" -delete
	rm -rf build
	rm -rf dist


## Lint the code
lint:
	@echo ⚡⚡⚡ Fixing order of imports using isort ⚡⚡⚡
	isort . --float-to-top --multi-line=3 --trailing-comma --force-grid-wrap=0 --use-parentheses --line-width=88	
	@echo ⚡⚡⚡ Formatting with black ⚡⚡⚡
	black -l 88 .	
	@echo ⚡⚡⚡ Linting with flake8 ⚡⚡⚡
	flake8 . --max-complexity=12 --max-line-length=88 --select=C,E,F,W,B,B950,BLK --ignore=E203,E231,E501,W503 --exclude=.cache


## Build library
build:
	python setup.py sdist bdist_wheel  



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')