TERRAGRUNT=terragrunt
ROOT=infra

.PHONY: fmt plan-k3s apply-k3s plan-mqtt apply-mqtt destroy-k3s destroy-mqtt

fmt:
	cd $(ROOT) && $(TERRAGRUNT) hclfmt
	cd $(ROOT) && terraform fmt -recursive

plan-k3s:
	cd $(ROOT)/live/home/k3s && $(TERRAGRUNT) plan

apply-k3s:
	cd $(ROOT)/live/home/k3s && $(TERRAGRUNT) apply

destroy-k3s:
	cd $(ROOT)/live/home/k3s && $(TERRAGRUNT) destroy

plan-mqtt:
	cd $(ROOT)/live/home/mosquitto && $(TERRAGRUNT) plan

apply-mqtt:
	cd $(ROOT)/live/home/mosquitto && $(TERRAGRUNT) apply

destroy-mqtt:
	cd $(ROOT)/live/home/mosquitto && $(TERRAGRUNT) destroy
