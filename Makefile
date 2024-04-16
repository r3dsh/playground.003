## Define colors
GREEN=\033[0;32m
NC=\033[0m # No Color

IMAGE_REPO=docker.io/r3dsh
UBI_NAME=ubi8
UBI_VERSION=8.9

# Default containerization tools
#CONTAINER_TOOLS ?= docker podman
CONTAINER_TOOLS ?= docker

# Default base image to use in the Dockerfile
BASE_IMAGE ?= ${IMAGE_REPO}/${UBI_NAME}:${UBI_VERSION}

# Set the base image as a build argument for all targets
BASE_IMAGE_ARG ?= ""

UBI_BASE_IMAGE := "registry.access.redhat.com/ubi8/ubi:8.9-1160"
UBI_TARGET_IMAGE := ${IMAGE_REPO}/${UBI_NAME}:${UBI_VERSION}
#
#
#
UBI_PODMAN_BASE_IMAGE := ${UBI_TARGET_IMAGE}
UBI_PODMAN_TARGET_IMAGE := ${IMAGE_REPO}/${UBI_NAME}:${UBI_VERSION}-podman
#
UBI_SYSTEMD_BASE_IMAGE := ${UBI_TARGET_IMAGE}
UBI_SYSTEMD_TARGET_IMAGE := ${IMAGE_REPO}/${UBI_NAME}:${UBI_VERSION}-systemd
#
UBI_DOCKER_BASE_IMAGE := ${UBI_SYSTEMD_BASE_IMAGE}
UBI_DOCKER_TARGET_IMAGE := ${IMAGE_REPO}/${UBI_NAME}:${UBI_VERSION}-docker
#
#
#
UBI_VNODE_DOCKER_BASE_IMAGE := ${UBI_DOCKER_TARGET_IMAGE}
UBI_VNODE_DOCKER_TARGET_IMAGE := ${IMAGE_REPO}/${UBI_NAME}-vnode:${UBI_VERSION}-docker
#
UBI_VNODE_PODMAN_BASE_IMAGE := ${UBI_PODMAN_TARGET_IMAGE}
UBI_VNODE_PODMAN_TARGET_IMAGE := ${IMAGE_REPO}/${UBI_NAME}-vnode:${UBI_VERSION}-podman
#
UBI_VNODE_SYSTEMD_BASE_IMAGE := ${UBI_SYSTEMD_TARGET_IMAGE}
UBI_VNODE_SYSTEMD_TARGET_IMAGE := ${IMAGE_REPO}/${UBI_NAME}-vnode:${UBI_VERSION}-systemd

# UBI

ubi8:
	@echo -e "\n${GREEN}Building UBI image (${IMAGE_REPO}/${UBI_NAME}:${UBI_VERSION}) ...${NC}\n"
	@for tool in $(CONTAINER_TOOLS); do \
  		$$tool build -t ${UBI_TARGET_IMAGE} --build-arg BASE_IMAGE=${UBI_BASE_IMAGE} -f ubi8.Dockerfile .; \
	 done;

# SERVICE

ubi8-docker:
	@echo -e "\n${GREEN}Building docker UBI image (${UBI_DOCKER_TARGET_IMAGE}) ...${NC}\n"
	@for tool in $(CONTAINER_TOOLS); do \
  		$$tool build -t ${UBI_DOCKER_TARGET_IMAGE} --build-arg BASE_IMAGE=${UBI_DOCKER_BASE_IMAGE} -f ubi8_docker.Dockerfile .; \
	done;

ubi8-podman:
	@echo -e "\n${GREEN}Building podman UBI image ${UBI_PODMAN_TARGET_IMAGE} from ${UBI_PODMAN_BASE_IMAGE} ...${NC}\n"
	@for tool in $(CONTAINER_TOOLS); do \
  		$$tool build -t ${UBI_PODMAN_TARGET_IMAGE} --build-arg BASE_IMAGE=${UBI_PODMAN_BASE_IMAGE} -f ubi8_podman.Dockerfile .; \
	done;

ubi8-systemd:
	@echo -e "\n${GREEN}Building systemd UBI image (${UBI_SYSTEMD_TARGET_IMAGE}) ...${NC}\n"
	@for tool in $(CONTAINER_TOOLS); do \
  		$$tool build -t ${UBI_SYSTEMD_TARGET_IMAGE} --build-arg BASE_IMAGE=${UBI_SYSTEMD_BASE_IMAGE} -f ubi8_systemd.Dockerfile .; \
  	done;

# VNODE

ubi8-vnode-docker:
	@echo -e "\n${GREEN}Building docker UBI image (${IMAGE_REPO}/${UBI_NAME}-vnode:${UBI_VERSION}-docker) ...${NC}\n"
	@for tool in $(CONTAINER_TOOLS); do \
  		$$tool build -t ${UBI_VNODE_DOCKER_TARGET_IMAGE} --build-arg BASE_IMAGE=${UBI_VNODE_DOCKER_BASE_IMAGE} -f ubi8_vnode_docker.Dockerfile .; \
  	done;

ubi8-vnode-podman:
	@echo -e "\n${GREEN}Building podman UBI image (${IMAGE_REPO}/${UBI_NAME}-vnode:${UBI_VERSION}-podman) ...${NC}\n"
	@for tool in $(CONTAINER_TOOLS); do \
  		$$tool build -t ${UBI_VNODE_PODMAN_TARGET_IMAGE} --build-arg BASE_IMAGE=${UBI_VNODE_PODMAN_BASE_IMAGE} -f ubi8_vnode_podman.Dockerfile .; \
  	done;

ubi8-vnode-systemd:
	@echo -e "\n${GREEN}Building systemd UBI image (${IMAGE_REPO}/${UBI_NAME}-vnode:${UBI_VERSION}-systemd) ...${NC}\n"
	@for tool in $(CONTAINER_TOOLS); do \
  		$$tool build -t ${UBI_VNODE_SYSTEMD_TARGET_IMAGE} --build-arg BASE_IMAGE=${UBI_VNODE_SYSTEMD_BASE_IMAGE} -f ubi8_vnode_systemd.Dockerfile .; \
  	done;

all:
	@echo -e "\n${GREEN}Running all defined targets:${NC}\n"
	@grep -E '^[a-zA-Z0-9_.-]+:' $(MAKEFILE_LIST) | awk -F ':' '{print $$1}' | grep -vE '^( |\.PHONY|all)' | xargs make

	@echo -e "\n${GREEN}Recreating test docker agent:${NC}\n"
	@docker rm -f agent-docker
	@docker run --name=agent-docker --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:rw --tmpfs=/tmp --tmpfs=/run --cgroupns host -v $$(pwd):/home/app/workspace -v $$(pwd)/tests:/home/app/tests ${IMAGE_REPO}/${UBI_NAME}-vnode:${UBI_VERSION}-docker

	@echo -e "\n${GREEN}Recreating test podman agent:${NC}\n"
	@docker rm -f agent-podman
	@docker run --name=agent-podman -d --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $$(pwd):/home/app/workspace -v $$(pwd)/tests:/home/app/tests ${IMAGE_REPO}/${UBI_NAME}-vnode:${UBI_VERSION}-podman
