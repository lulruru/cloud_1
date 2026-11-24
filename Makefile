BIN_DIR := $(HOME)/.local/bin
ANSIBLE_VENV_DIR := $(HOME)/.venvs/ansible
AZ_VENV_DIR := $(HOME)/.venvs/azure-cli
ZSHRC := $(HOME)/.zshrc
TF_VERSION := 1.17.2

TF_BIN := $(BIN_DIR)/terraform
ANSIBLE_PLAYBOOK_BIN := $(ANSIBLE_VENV_DIR)/bin/ansible-playbook
ANSIBLE_GALAXY_BIN := $(ANSIBLE_VENV_DIR)/bin/ansible-galaxy
AZ_BIN := $(AZ_VENV_DIR)/bin/az

export PATH := $(BIN_DIR):$(ANSIBLE_VENV_DIR)/bin:$(AZ_VENV_DIR)/bin:$(PATH)

.PHONY: tools configure-zsh install-tf install-ansible install-az clean-tools \
	ansible-deps ansible-check ansible-deploy \
	terraform-init terraform-plan terraform-apply deploy

tools: install-tf install-ansible install-az configure-zsh

configure-zsh:
	@touch "$(ZSHRC)"
	@grep -qF 'export PATH="$(BIN_DIR):$(ANSIBLE_VENV_DIR)/bin:$(AZ_VENV_DIR)/bin:$$PATH"' "$(ZSHRC)" || \
		echo 'export PATH="$(BIN_DIR):$(ANSIBLE_VENV_DIR)/bin:$(AZ_VENV_DIR)/bin:$$PATH"' >> "$(ZSHRC)"

$(TF_BIN):
	@$(MAKE) install-tf

$(ANSIBLE_PLAYBOOK_BIN):
	@$(MAKE) install-ansible

$(AZ_BIN):
	@$(MAKE) install-az

install-tf:
	@mkdir -p $(BIN_DIR)
	@curl -fsSL "https://releases.hashicorp.com/terraform/$(TF_VERSION)/terraform_$(TF_VERSION)_linux_amd64.zip" -o /tmp/terraform.zip
	@unzip -qo /tmp/terraform.zip -d /tmp/tf_extract
	@mv /tmp/tf_extract/terraform $(TF_BIN)
	@chmod +x $(TF_BIN)
	@rm -rf /tmp/terraform.zip /tmp/tf_extract
	@$(TF_BIN) version

install-ansible:
	@mkdir -p $(BIN_DIR)
	@python3 -m venv $(ANSIBLE_VENV_DIR)
	@$(ANSIBLE_VENV_DIR)/bin/pip install --upgrade --quiet pip ansible-core
	@ln -sf $(ANSIBLE_VENV_DIR)/bin/ansible $(BIN_DIR)/ansible
	@ln -sf $(ANSIBLE_VENV_DIR)/bin/ansible-playbook $(BIN_DIR)/ansible-playbook
	@$(ANSIBLE_PLAYBOOK_BIN) --version

install-az:
	@mkdir -p $(BIN_DIR)
	@python3 -m venv $(AZ_VENV_DIR)
	@$(AZ_VENV_DIR)/bin/pip install --upgrade --quiet pip azure-cli
	@ln -sf $(AZ_BIN) $(BIN_DIR)/az
	@$(AZ_BIN) version

clean-tools:
	@rm -rf $(ANSIBLE_VENV_DIR) $(AZ_VENV_DIR) $(TF_BIN) $(BIN_DIR)/ansible $(BIN_DIR)/ansible-playbook $(BIN_DIR)/az

ansible-deps: $(ANSIBLE_PLAYBOOK_BIN)
	"$(ANSIBLE_GALAXY_BIN)" collection install -r requirements/requirements.yml

ansible-check: $(ANSIBLE_PLAYBOOK_BIN)
	cd ansible && "$(ANSIBLE_PLAYBOOK_BIN)" --syntax-check playbooks/site.yml --ask-vault-pass

ansible-deploy: $(ANSIBLE_PLAYBOOK_BIN)
	cd ansible && "$(ANSIBLE_PLAYBOOK_BIN)" playbooks/site.yml --ask-vault-pass

terraform-init: $(TF_BIN)
	"$(TF_BIN)" -chdir=terraform init

terraform-plan: $(TF_BIN) $(AZ_BIN) terraform-init
	"$(TF_BIN)" -chdir=terraform plan -var-file=terraform.tfvars

terraform-apply: $(TF_BIN) $(AZ_BIN) configure-zsh terraform-init
	"$(TF_BIN)" -chdir=terraform apply -var-file=terraform.tfvars

deploy: terraform-apply
	$(MAKE) ansible-deploy
