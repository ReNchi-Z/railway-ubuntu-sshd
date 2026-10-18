FROM ubuntu:24.04

# Build-time install — python + sshd kebake, runtime langsung siap
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-server sudo python3 python3-pip python3-venv curl git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# SSH config: root + password auth, port 2222 (diproxikan ke publik)
RUN mkdir -p /run/sshd /root/.ssh && \
    sed -i 's/^#*Port .*/Port 2222/' /etc/ssh/sshd_config && \
    sed -i 's/^#*PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'if [ -n "$ROOT_PASSWORD" ]; then echo "root:$ROOT_PASSWORD" | chpasswd; fi' >> /entrypoint.sh && \
    echo 'if [ -n "$USER_NAME" ] && [ -n "$USER_PASSWORD" ]; then' >> /entrypoint.sh && \
    echo '  useradd -m -s /bin/bash "$USER_NAME" && echo "$USER_NAME:$USER_PASSWORD" | chpasswd && echo "$USER_NAME ALL=(ALL) ALL" >> /etc/sudoers' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo 'exec /usr/sbin/sshd -D' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 2222
CMD ["/entrypoint.sh"]
