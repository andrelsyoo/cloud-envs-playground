all: plan

.PHONY: all

check:
ifdef CI
ifndef AWS_ROLE_ARN
	@echo Warning: AWS_ROLE_ARN isn\'t defined\; Did you configured IRSA properly?
	exit 1
endif

ifndef AWS_WEB_IDENTITY_TOKEN_FILE
	@echo Warning: AWS_WEB_IDENTITY_TOKEN_FILE isn\'t defined\; Did you configured IRSA properly?
	exit 1
endif
endif

ifndef CI
ifndef AWS_ACCESS_KEY_ID
	@echo Warning: AWS_ACCESS_KEY_ID isn\'t defined\; Set your credentials first.
	exit 1
endif

ifndef AWS_SECRET_ACCESS_KEY
	@echo Warning: AWS_SECRET_ACCESS_KEY isn\'t defined\; Set your credentials first.
	exit 1
endif

ifndef AWS_REGION
	@echo Warning: AWS_REGION isn\'t defined\; Set your credentials first.
	exit 1
endif
endif
	@echo "All variables checked! You're ready to go!"

init: check
	bundle exec terraspace all init
	bundle exec terraspace build

# Ignore failure on the first command to be able to print the logs after
plan: check
	-bundle exec terraspace all plan
	bundle exec terraspace logs plan --all --no-timestamps

up: check
	-bundle exec terraspace all up --yes
	bundle exec terraspace logs up --all --no-timestamps