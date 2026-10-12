FROM ubuntu:22.04

# Set non-interactive mode agar instalasi tidak berhenti meminta input region
ENV DEBIAN_FRONTEND=noninteractive

# Update system dan install tools dasar + SSH
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    wget \
    sudo \
    net-tools \
    screen && \
    mkdir /var/run/sshd

# Set password root VPS kamu
RUN echo 'root:passwordvps123' | chpasswd

# Mengizinkan login SSH menggunakan user root
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Bikin script startup otomatis untuk Ngrok dan SSH
RUN echo '#!/bin/bash\n\
service ssh start\n\
if [ -z "$NGROK_AUTH_TOKEN" ]; then\n\
  echo "Error: NGROK_AUTH_TOKEN tidak ditemukan!"\n\
  exit 1\n\
fi\n\
curl -s https://amazonaws.com | sudo tee /etc/apt/trusted.gpg.dev/ngrok.asc >/dev/null\n\
echo "deb https://amazonaws.com buster main" | sudo tee /etc/apt/sources.list.dev/ngrok.list\n\
sudo apt-get update && sudo apt-get install -y ngrok\n\
ngrok config add-authtoken $NGROK_AUTH_TOKEN\n\
ngrok tcp 22 --log=stdout\n\
' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80
EXPOSE 22

CMD ["/entrypoint.sh"]
