# Source .env file if available
ifneq ("$(wildcard ../.env)","")
	include ../.env
endif

PACKER = packer
SHELL = bash

# Ensure prerequesites
packer-validate packer-build: \
	version/$(VERSION).pkrvars.hcl

# Check if var-file exists
version/%.pkrvars.hcl:
	$(error No configuration file found (searched for '$@'))

.PHONY: packer-validate
packer-validate:
	$(PACKER) validate -var-file=version/$(VERSION).pkrvars.hcl .

.PHONY: packer-fmt
packer-fmt:
	$(PACKER) fmt -recursive .

.PHONY: packer-init
packer-init:
	$(PACKER) init .

.PHONY: packer-build
packer-build:
	$(PACKER) build -var-file=version/$(VERSION).pkrvars.hcl .

.PHONY: docs
docs:
	terraform-docs markdown . > README.md
