TERRAGRUNT=terragrunt
ROOT=infra

.PHONY: fmt plan-k3s apply-k3s plan-mqtt apply-mqtt plan-longhorn apply-longhorn destroy-k3s destroy-mqtt destroy-longhorn

fmt:
	cd $(ROOT) && $(TERRAGRUNT) hcl format
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

plan-longhorn:
	cd $(ROOT)/live/home/longhorn && $(TERRAGRUNT) plan

apply-longhorn:
	cd $(ROOT)/live/home/longhorn && $(TERRAGRUNT) apply

destroy-longhorn:
	cd $(ROOT)/live/home/longhorn && $(TERRAGRUNT) destroy
