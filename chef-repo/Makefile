.DEFAULT_GOAL := help

clean: ## Remove chef nodes and clients
	@chef exec knife node bulk delete '[app|web]*' --yes
	@chef exec knife client bulk delete '[app|web]*' --yes

help: ## See all the Makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean help
