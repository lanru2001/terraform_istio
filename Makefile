# Set environment directory path from user-passed ENV variable
FOLDER := "environments/${ENV}"
BASE_DIR := "$${PWD}"

# Check to make sure that ENV variable was passed and environments folder exists
.PHONY: checkenv
checkenv:
	@echo "[INFO]: Checking environment...";\
	if [ -z "${ENV}" ]; then\
		echo "[ERROR]: Environment not set";\
		exit 10;\
	fi;\
	if [ ! -d "${FOLDER}" ]; then\
		echo "[ERROR] environments folder does not exist";\
		exit 10;\
	echo ${BASE_DIR};\
	fi;\

.PHONY: init
init: checkenv
	@export MODULE="$$(basename $$(pwd))";\
	cd ./"${FOLDER}" > /dev/null;\
	echo "[INFO]: Performing terraform init";\
	terraform init -reconfigure;\
	if [ ! $$? -eq 0 ]; then\
		echo "[ERROR] Command failed";\
		exit 13;\
	fi;\
	cd ../.. > /dev/null;\
	echo "Done!"

.PHONY: validate
validate: init
	@export MODULE="$$(basename $$(pwd))";\
	cd ./"${FOLDER}" > /dev/null;\
	echo "[INFO]: Performing terraform validate";\
	terraform validate;\
	if [ ! $$? -eq 0 ]; then\
		echo "[ERROR] Command failed";\
		exit 13;\
	fi;\
	cd ../.. > /dev/null;\
	echo "Done!"

.PHONY: plan
plan: init
	@export MODULE="$$(basename $$(pwd))";\
	cd ./"${FOLDER}" > /dev/null;\
	echo "[INFO]: Performing terraform plan";\
	export timestamp=$$(date +%Y-%m-%d-%H.%M.%S);\
	terraform plan -refresh=true;\
	terraform plan -no-color -refresh=true > "tf.$${timestamp}.tfplan";\
	rm tf.$${timestamp}.tfplan;\
	cd ../.. > /dev/null;\
	echo "Done!"

.PHONY: apply_auto_approve # This is only to be used by the CICD job
apply_auto_approve: init
	@export MODULE="$$(basename $$(pwd))";\
	cd ./"${FOLDER}" > /dev/null;\
	echo "[INFO]: Performing terraform apply with auto-approve...";\
	export timestamp=$$(date +%Y-%m-%d-%H.%M.%S);\
	terraform plan -no-color -refresh=true > "tf.$${timestamp}.tfplan";\
	terraform apply -refresh=true --auto-approve;\
	rm tf.$${timestamp}.tfplan;\
	cd ../.. > /dev/null;\
	echo "Done!"

.PHONY: apply
apply: init
	@export MODULE="$$(basename $$(pwd))";\
	cd ./"${FOLDER}" > /dev/null;\
	echo "[INFO]: Performing terraform apply...";\
	export timestamp=$$(date +%Y-%m-%d-%H.%M.%S);\
	terraform plan -no-color -refresh=true > "tf.$${timestamp}.tfplan";\
	terraform apply -refresh=true;\
	rm tf.$${timestamp}.tfplan;\
	cd ../.. > /dev/null;\
	echo "Done!"

.PHONY: fmt
fmt:
	@echo "Performing terraform fmt recursively.";\
	terraform fmt -recursive;\
	echo "Done!"

.PHONY: destroy
destroy: init
	@cd ./"${FOLDER}" > /dev/null;\
	echo "[INFO]: Performing terraform destroy...";\
	terraform destroy -refresh=true;\
	cd ../.. > /dev/null;\
	echo "Done!"
