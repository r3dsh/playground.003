
# Use the build argument as the base image
ARG BASE_IMAGE

FROM gcr.io/kaniko-project/executor:latest as kaniko

# Use the base image in the FROM instruction
FROM ${BASE_IMAGE}

#FROM registry.access.redhat.com/ubi8/ubi:8.9-1160
#FROM docker.io/r3dsh/ubi8:8.9

# Briefly switch to root
USER root

# Install required packages
RUN dnf install -y python3 iputils bind-utils iproute procps which buildah skopeo sudo

RUN pip3 install podman-compose

# Cleanup DNF
RUN dnf clean dbcache \
    && dnf clean all \
    && rm -rf /var/cache/yum

# Install additional applications
COPY --from=kaniko /kaniko /kaniko
RUN mv /kaniko/executor /usr/bin/kaniko && mv /kaniko/* /usr/bin/ && rm -rf /kaniko \
  && curl -o /usr/bin/crane -sfL https://github.com/michaelsauter/crane/releases/download/v3.6.1/crane_linux_amd64 \
  && chmod +x /usr/bin/crane

# Configure MOTD
#RUN echo -e "VirtualNode podman build date: $(date)\n" >> /etc/motd
RUN sed -i "1i VirtualNode PODMAN build date: $(date)\n" /etc/motd

CMD ["/sbin/init"]
VOLUME ["/sys/fs/cgroup"]

# go back to app user
USER app
