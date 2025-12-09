FROM almalinux:10

ENV TZ=America/Chicago

RUN dnf -y update && \
    dnf -y install epel-release && \
    dnf -y clean all

RUN dnf -y upgrade

RUN dnf -y install \
    ca-certificates \
    curl \
    bind-utils \
    dsniff \
    fping \
    git \
    gnupg \
    iputils \
    ipcalc \
    iperf \
    iperf3
    mtr \
    nano \
    net-tools \
    openssh-server \
    python3 \
    python3-pip \
    sudo \
    tzdata \
    vim-enhanced \
    wget \
    --allowerasing

COPY requirements.txt requirements.txt

COPY requirements.yml requirements.yml

COPY hostnetconfig.sh /usr/local/bin/hostnetconfig.sh

COPY lldp.sh /usr/bin/lldp

RUN systemctl enable lldpd

RUN systemctl start lldpd

RUN pip3 install -r requirements.txt

RUN ansible-galaxy collection install -r requirements.yml --force

RUN useradd -rm -d /home/admin -s /bin/bash -g root -G wheel -u 1099 admin

RUN echo admin:admin | chpasswd

CMD ssh-keygen -A && /usr/sbin/sshd && lldpd && sleep infinity

LABEL maintainer="Mitch Vaughan <mitch@arista.com>" \
      version="2.0.1"
