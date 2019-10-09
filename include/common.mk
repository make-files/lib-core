export MF_PROJECT_ROOT := $(realpath $(dir $(word 1,$(MAKEFILE_LIST))))
export MF_ROOT := $(MF_PROJECT_ROOT)/.makefiles
export PATH := $(MF_ROOT)/lib/core/bin:$(PATH)

# GENERATED_FILES is a space separated list of files that are generated by
# the Makefile and are intended to be committed to the repository.
GENERATED_FILES +=

# GET_HEAD_xxx variables containing information about the commit at the head of
# the working tree.
GIT_HEAD_HASH		?= $(shell git rev-parse --short --verify HEAD)
GIT_HEAD_HASH_FULL	?= $(shell git rev-parse --verify HEAD)
GIT_HEAD_TAG 		?= $(shell git describe --exact-match 2>/dev/null)
GIT_HEAD_COMMITTISH	?= $(shell git describe --exact-match 2>/dev/null || git rev-parse --short --verify HEAD)

# clean --- Removes all generated and ignored files. Individual language
# Makefiles should also remove any build artifacts that aren't already ignored.
.PHONY: clean
clean::
	$(MAKE) clean-generated
	$(MAKE) clean-ignored

# clean-generated --- Removes all files in the GENERATED_FILES list.
.PHONY: clean-generated
clean-generated::
	rm -f -- $(GENERATED_FILES)

# clean-ignored --- Removes all files ignored by .gitignore files within the
# repository. It does not remove any files that are ignored due to rules in
# global ignore configurations.
.PHONY: clean-ignored
clean-ignored::
	git-find-ignored '*' | xargs -t -n1 rm -rf --

# regenerate --- Removes and regenerates all files in the GENERATED_FILES list.
.PHONY: regenerate
regenerate::
	$(MAKE) clean-generated
	$(MAKE) -- $(GENERATED_FILES)

# ci -- Perform tasks that need to be executed within a continuous integration
# environment. Individual language Makefiles are expected to add additional
# recipies for this target.
.PHONY: ci
ci::
	@echo "checking for out-of-date generated files"
	@$(MAKE) regenerate
	@git diff -- $(GENERATED_FILES)
	@!(git status --porcelain -- $(GENERATED_FILES) | grep .)
