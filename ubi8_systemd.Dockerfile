
# Use the build argument as the base image
ARG BASE_IMAGE

# Use the base image in the FROM instruction
FROM ${BASE_IMAGE}

#FROM registry.access.redhat.com/ubi8/ubi:8.9-1160
#FROM docker.io/r3dsh/ubi8:8.9

# Briefly switch to root
USER root

# Install required packages
RUN dnf install -y systemd initscripts sudo

# Cleanup DNF
RUN dnf clean dbcache \
    && dnf clean all \
    && rm -rf /var/cache/yum

# Cleanup SystemD
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in ; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);

# Configure MOTD
#RUN echo -e "UBI systemd build date: $(date)\n" >> /etc/motd
RUN sed -i "1i UBI8 SYSTEMD build date: $(date)\n" /etc/motd

# Configure sudo
RUN echo "app   ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers

CMD ["/sbin/init"]
VOLUME ["/sys/fs/cgroup"]

# go back to app user
USER app
