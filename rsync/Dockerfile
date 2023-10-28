ARG UBUNTU_VERSION="latest"
FROM ubuntu:${UBUNTU_VERSION}

MAINTAINER Alex Gonzalez <alex.glez.gcia@gmail.com>

# Non-interactive debconf package configuration
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu and Install Yocto Proyect Quick Start dependencies
RUN apt-get update && apt-get install -y --no-install-recommends locales rsync zfsutils-linux && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set bash as default shell
RUN echo "dash dash/sh boolean false" | debconf-set-selections - && dpkg-reconfigure dash

# Set the locale
RUN locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    update-locale LANG=en_US.UTF-8

COPY entrypoint.sh /entrypoint.sh
COPY zfs-utils.sh /zfs-utils.sh

ENTRYPOINT ["/entrypoint.sh"]
