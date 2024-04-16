
# Use the build argument as the base image
ARG BASE_IMAGE

# Use the base image in the FROM instruction
FROM ${BASE_IMAGE}

#FROM docker.io/r3dsh/ubi8:8.9
#FROM r3dsh/ubi8-vnode:8.9

# Briefly switch to root
USER root

# Configure Podman
RUN dnf install -y podman slirp4netns fuse-overlayfs shadow-utils sudo
RUN dnf clean dbcache \
    && dnf clean all \
    && rm -rf /var/cache/yum

# Configure MOTD
#RUN echo -e "UBI PODMAN build date: $(date)\n" >> /etc/motd
RUN sed -i "1i UBI8 PODMAN build date: $(date)\n" /etc/motd

# Configure sudo
RUN echo "app   ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers

# Create cgroups volume
VOLUME ["/sys/fs/cgroup"]

# docker/ucp-pause
CMD ["podman", "run", "--rm", "-ti", "docker/ucp-pause:3.1.14"]

# go back to app user
USER app
