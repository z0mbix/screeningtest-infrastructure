.DEFAULT_GOAL := help

createsshkeypair:
	@test -f ~/.ssh/screeningtest || ssh-keygen -q -t rsa -f ~/.ssh/screeningtest -N '' -C screeningtest

plan: ## Perform a terrform dry-run
	@make createsshkeypair
	terraform plan

apply: ## Create the infrastructure/resources
	@make createsshkeypair
	terraform get
	terraform apply

destroy: ## Destroy all resources
	terraform destroy -force

help: ## See all the Makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: plan apply destroy help
