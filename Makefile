.PHONY: ansible-deps ansible-check ansible-deploy

ansible-deps:
	ansible-galaxy collection install -r requirements/requirements.yml

ansible-check:
	cd ansible && ansible-playbook --syntax-check playbooks/site.yml --ask-vault-pass

ansible-deploy:
	cd ansible && ansible-playbook playbooks/site.yml --ask-vault-pass
