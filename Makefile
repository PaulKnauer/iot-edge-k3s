TERRAGRUNT=terragrunt
ROOT=infra

.PHONY: fmt plan-k3s apply-k3s plan-mqtt apply-mqtt plan-longhorn apply-longhorn plan-nodered apply-nodered plan-registry apply-registry plan-clock-server apply-clock-server plan-cert-manager apply-cert-manager plan-ingress apply-ingress destroy-k3s destroy-mqtt destroy-longhorn destroy-nodered destroy-registry destroy-clock-server destroy-ingress destroy-cert-manager

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

plan-nodered:
	cd $(ROOT)/live/home/nodered && $(TERRAGRUNT) plan

apply-nodered:
	cd $(ROOT)/live/home/nodered && $(TERRAGRUNT) apply

destroy-nodered:
	cd $(ROOT)/live/home/nodered && $(TERRAGRUNT) destroy

plan-registry:
	cd $(ROOT)/live/home/registry && $(TERRAGRUNT) plan

apply-registry:
	cd $(ROOT)/live/home/registry && $(TERRAGRUNT) apply

destroy-registry:
	cd $(ROOT)/live/home/registry && $(TERRAGRUNT) destroy

plan-clock-server:
	cd $(ROOT)/live/home/clock-server && $(TERRAGRUNT) plan

apply-clock-server:
	cd $(ROOT)/live/home/clock-server && $(TERRAGRUNT) apply

destroy-clock-server:
	cd $(ROOT)/live/home/clock-server && $(TERRAGRUNT) destroy

plan-cert-manager:
	cd $(ROOT)/live/home/cert-manager && $(TERRAGRUNT) plan

apply-cert-manager:
	cd $(ROOT)/live/home/cert-manager && $(TERRAGRUNT) apply

destroy-cert-manager:
	cd $(ROOT)/live/home/cert-manager && $(TERRAGRUNT) destroy

plan-ingress:
	cd $(ROOT)/live/home/ingress && $(TERRAGRUNT) plan

apply-ingress:
	cd $(ROOT)/live/home/ingress && $(TERRAGRUNT) apply

destroy-ingress:
	cd $(ROOT)/live/home/ingress && $(TERRAGRUNT) destroy
