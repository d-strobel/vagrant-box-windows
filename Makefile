# Source .env file if available
ifneq ("$(wildcard ../.env)","")
	include ../.env
endif

PACKER = packer
SHELL = bash

# Ensure prerequesites
packer-validate packer-build: \
	tags/2022-sc.pkrvars.hcl

# Check if var-file exists
version/%.pkrvars.hcl:
	$(error No configuration file found (searched for '$@'))

.PHONY: packer-validate
packer-validate:
	$(PACKER) validate -var-file=tags/2022-sc.pkrvars.hcl .
	$(PACKER) validate -var-file=tags/2022-sc-ad.pkrvars.hcl .

.PHONY: packer-fmt
packer-fmt:
	$(PACKER) fmt -recursive .

.PHONY: packer-init
packer-init:
	$(PACKER) init .

.PHONY: packer-build
packer-build:
	$(PACKER) build -force -var-file=tags/2022-sc.pkrvars.hcl -parallel-builds=1 .
	$(PACKER) build -force -var-file=tags/2022-sc-ad.pkrvars.hcl -parallel-builds=1 .

.PHONY: docs
docs:
	terraform-docs markdown . > README.md
