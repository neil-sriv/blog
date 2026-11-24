WRITING_DIR ?= $(HOME)/obsidian/neil/cs/writing
PORT ?= 1313
export WRITING_DIR PORT

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: help new sync preview
.DEFAULT_GOAL := help

help:
	@printf '%s\n' \
	  'make new post=<slug>  create a draft note in the vault' \
	  'make sync              rebuild content/ from publish: true vault notes' \
	  'make preview PORT=1414  serve every vault note on PORT (default 1313)'

new:
	@test -n "$(post)" || { echo 'usage: make new post=<slug>' >&2; exit 1; }
	@"$(ROOT)scripts/writing.sh" new "$(post)"

sync:
	@"$(ROOT)scripts/writing.sh" sync

preview:
	@"$(ROOT)scripts/writing.sh" preview
