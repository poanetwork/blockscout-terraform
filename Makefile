.PHONY: help

IMAGE_NAME ?= poa-aws
INFRA_PREFIX ?= poa-example
KEY_PAIR ?= poa

help:
	@echo "$(IMAGE_NAME)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check: lint ## Run linters and validation
	@bin/infra precheck
	@terraform validate -var-file=ignore.tfvars base
	@if [ -f main.tfvars ]; then \
		terraform validate \
		  -var='db_password=foo' \
		  -var='new_relic_app_name=foo' \
		  -var='new_relic_license_key=foo' \
		  -var-file=main.tfvars main; \
	fi
	@rm ignore.tfvars

format: ## Apply canonical formatting to Terraform files
	@terraform fmt

lint: shellcheck check-format ## Lint scripts and config files

check-format:
	@terraform fmt -check=true

shellcheck:
	@shellcheck --shell=bash bin/infra
	@shellcheck --shell=bash modules/stack/libexec/init.sh
