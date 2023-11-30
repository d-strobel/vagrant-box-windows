# Source .env file if available
ifneq ("$(wildcard ../.env)","")
	include ../.env
endif

PACKER = packer
SHELL = bash

.PHONY: packer-validate
packer-validate:
	$(PACKER) validate .

.PHONY: packer-fmt
packer-fmt:
	$(PACKER) fmt -recursive .

.PHONY: packer-init
packer-init:
	$(PACKER) init .

.PHONY: packer-build
packer-build:
	$(PACKER) build -force -parallel-builds=1 .

.PHONY: docs
docs:
	terraform-docs markdown . > README.md
