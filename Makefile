.PHONY: ansible-deps ansible-check ansible-deploy terraform-init terraform-plan terraform-apply deploy

ansible-deps:
	ansible-galaxy collection install -r requirements/requirements.yml

ansible-check:
	cd ansible && ansible-playbook --syntax-check playbooks/site.yml --ask-vault-pass

ansible-deploy:
	cd ansible && ansible-playbook playbooks/site.yml --ask-vault-pass

terraform-init:
	terraform -chdir=terraform init

terraform-plan: terraform-init
	terraform -chdir=terraform plan -var-file=terraform.example.tfvars

terraform-apply: terraform-init
	terraform -chdir=terraform apply -var-file=terraform.example.tfvars

deploy: terraform-apply
	$(MAKE) ansible-deploy
