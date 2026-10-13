FROM debian:stable-slim

# Install OpenSSH dan perkakas sistem dasar
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    wget \
    sudo \
    git \
    && rm -rf /var/lib/apt/lists/*

# Siapkan folder untuk menjalankan server SSH
RUN mkdir /var/run/sshd

# ATUR PASSWORD ROOT VPS ANDA DI SINI (Ganti 'MasukanPasswordSukaSuka' sesuai keinginan Anda)
RUN echo 'root:MasukanPasswordSukaSuka' | chpasswd

# Konfigurasi SSH agar mengizinkan akses root jarak jauh dengan password
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Menggunakan port internal default kontainer
EXPOSE 22

# Perintah untuk menghidupkan layanan SSH terus-menerus
CMD ["/usr/sbin/sshd", "-D", "-p", "22"]
