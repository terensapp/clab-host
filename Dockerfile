FROM almalinux:10

# 1. Update & Enable EPEL (Required for lldpd, iperf3, etc.)
RUN dnf -y update && \
    dnf -y install epel-release && \
    dnf -y config-manager --set-enabled crb && \
    dnf clean all

# 2. Install Tools & Services
#    (Added 'lldpd' to this list)
RUN dnf -y install \
    bind-utils \
    curl \
    git \
    iproute \
    iputils \
    lldpd \
    mtr \
    nano \
    net-tools \
    nmap-ncat \
    nginx \
    openssh-server \
    tcpdump \
    traceroute \
    vim-enhanced \
    wget \
    python3 \
    python3-pip \
    && dnf clean all

# --- WEB SERVER SETUP ---
RUN echo "<html><body><h1>Hello World from Alma 10</h1></body></html>" > /usr/share/nginx/html/index.html
EXPOSE 80

# --- SSH SERVER SETUP ---
RUN sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'root:password' | chpasswd && \
    ssh-keygen -A
EXPOSE 22

WORKDIR /scripts

COPY hostnetconfig.sh /usr/local/bin/hostnetconfig.sh

RUN useradd -rm -d /home/admin -s /bin/bash -g root -G wheel -u 1099 admin

RUN echo admin:admin | chpasswd

# --- STARTUP COMMAND ---
# Start Nginx (bg), SSHD (bg), LLDPD (bg), then sleep forever
CMD bash -c "nginx && /usr/sbin/sshd && /usr/sbin/lldpd && sleep infinity"
