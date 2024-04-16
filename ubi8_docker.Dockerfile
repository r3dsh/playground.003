# Use the build argument as the base image
ARG BASE_IMAGE

# Use the base image in the FROM instruction
FROM ${BASE_IMAGE}
#FROM docker.io/r3dsh/ubi8-vnode:8.9

# Switch to root
USER root

# Configure Docker
RUN dnf install -y yum-utils
RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
RUN dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin sudo
RUN systemctl enable docker
RUN usermod -aG docker app

RUN dnf clean dbcache \
    && dnf clean all \
    && rm -rf /var/cache/yum

# Configure MOTD
#RUN echo -e "UBI DOCKER build date: $(date)\n" >> /etc/motd
RUN sed -i "1i UBI8 DOCKER build date: $(date)\n" /etc/motd

# Configure sudo
RUN echo "app   ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers

CMD ["/sbin/init"]
VOLUME ["/sys/fs/cgroup"]
