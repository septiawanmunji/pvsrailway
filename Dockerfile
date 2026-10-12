FROM ubuntu:latest

# Install SSH server, Ngrok dependencies, dan tools dasar
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    wget \
    sudo \
    net-tools \
    screen \
    &> /dev/null

# Konfigurasi SSH Server
RUN mkdir /var/run/sshd
RUN echo 'root:passwordvps123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Script otomatis untuk menjalankan SSH dan Ngrok sekaligus
RUN echo '#!/bin/bash\n\
service ssh start\n\
if [ -z "$NGROK_AUTH_TOKEN" ]; then\n\
  echo "Error: NGROK_AUTH_TOKEN tidak ditemukan!"\n\
  exit 1\n\
fi\n\
curl -s https://amazonaws.com | sudo tee /etc/apt/trusted.gpg.dev/ngrok.asc >/dev/null && echo "deb https://amazonaws.com buster main" | sudo tee /etc/apt/sources.list.dev/ngrok.list && sudo apt-get update && sudo apt-get install ngrok\n\
ngrok config add-authtoken $NGROK_AUTH_TOKEN\n\
ngrok tcp 22 --log=stdout\n\
' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Port internal untuk Railway (Railway membutuhkan port web terdeteksi)
EXPOSE 80
EXPOSE 22

CMD ["/entrypoint.sh"]
