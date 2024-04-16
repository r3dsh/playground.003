#FROM registry.access.redhat.com/ubi8/ubi:8.9-1160
# Use the build argument as the base image
ARG BASE_IMAGE

# Use the base image in the FROM instruction
FROM ${BASE_IMAGE}
#FROM docker.io/library/almalinux:8.9
#FROM docker.io/library/rockylinux:8.9
#FROM docker.io/library/rockylinux:8.9-minimal
#FROM docker.io/library/fedora:41

# Update the system
RUN dnf makecache --timer

RUN dnf clean dbcache \
    && dnf clean all \
    && rm -rf /var/cache/yum

# Create app user
RUN useradd -ms /bin/bash -d /home/app app
RUN grep -qxF 'cat /etc/motd' /home/app/.bashrc || echo 'cat /etc/motd' >> /home/app/.bashrc

# Enable red PS for root
RUN echo 'if [ "$LOGNAME" = root ] || [ "`id -u`" -eq 0 ] ; then' > /etc/profile.d/redrootprompt.sh
RUN echo "PS1='[\[\033[01;31m\]\u\033[@\h\[\033[00m\]:\w] : '" >> /etc/profile.d/redrootprompt.sh
RUN echo "else" >> /etc/profile.d/redrootprompt.sh
RUN echo "PS1='[\u@\h \w] : '" >> /etc/profile.d/redrootprompt.sh
RUN echo "fi" >> /etc/profile.d/redrootprompt.sh

# Configure MOTD
#RUN echo -e "\nUBI8 build date: $(date)\n" > /etc/motd
RUN sed -i "1i UBI8 build date: $(date)\n" /etc/motd

# Switch to app user
USER app
WORKDIR /home/app
