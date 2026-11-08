TF_DIR=terraform
ANS_DIR=ansible

.PHONY: up destroy

up:
	cd $(TF_DIR) && terraform init
	cd $(TF_DIR) && terraform apply -auto-approve
	ansible-galaxy collection install community.docker
	ansible-playbook -i $(ANS_DIR)/inventory.ini $(ANS_DIR)/playbook.yml
	@APP_IP=$$(cd $(TF_DIR) && terraform output -raw app_ip); \
	echo "App IP: $$APP_IP"; \
	curl -i http://$$APP_IP/health

destroy:
	cd $(TF_DIR) && terraform destroy -auto-approve || true
	# destroy_hook удалит VM даже если состояния terraform уже нет
	APP_NAME=app-vm DB_NAME=db-vm bash scripts/utm_destroy_vms.sh || true