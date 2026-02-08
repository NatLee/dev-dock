#!/bin/bash
set -euxo pipefail

# Create required directories
echo "Creating required directories..."
mkdir -p ~/.zcs-deps
mkdir -p ~/.ivy2/cache

# Update the repository sources list
echo "Updating the repository sources list..."
apt-get -qq autoremove -y
apt-get -qq update -y

# Install required packages
echo "Installing required packages..."
apt-get -qq install -y apt-utils \
    software-properties-common \
    build-essential \
    openssh-server \
    sudo \
    ant ant-optional ant-contrib \
    wget \
    curl \
    iputils-ping \
    git \
    xdg-utils \
    libappindicator1 \
    fonts-liberation \
    libxss1 \
    vim \
    wget \
    net-tools \
    bzip2 \
    libnss-wrapper \
    gettext \
    screen \
    tmux \
    autocutsel \
    gwenview \
    htop \
    nano \
    mpv \
    gdebi \
    file-roller \
    filezilla \
    supervisor

# Set locales (required for C library and GUI; avoids "Locale not supported" / fallback 'C')
echo "Setting up locales..."
# Postinst validates LANG; use a locale that exists before we run locale-gen (Dockerfile may set LANG=zh_TW.UTF-8)
LANG=C.UTF-8 apt-get -qq install -y locales
# Enable locales in /etc/locale.gen then generate
sed -i 's/^# *\(en_US\.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^# *\(zh_TW\.UTF-8\)/\1/' /etc/locale.gen
grep -q '^en_US.UTF-8' /etc/locale.gen || echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
grep -q '^zh_TW.UTF-8' /etc/locale.gen || echo 'zh_TW.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
# Default locale en (override at run with -e LANG=zh_TW.UTF-8)
echo 'LANG=en_US.UTF-8' > /etc/default/locale
echo 'LANGUAGE=en_US:en' >> /etc/default/locale
echo 'LANG=en_US.UTF-8' >> /etc/environment
echo 'LANGUAGE=en_US:en' >> /etc/environment

# Install fonts
echo "Install Chinese fonts..."
apt-get -y install fonts-droid-fallback \
    ttf-wqy-zenhei \
    ttf-wqy-microhei \
    fonts-arphic-ukai \
    fonts-arphic-uming

echo "Install Emoji fonts..."
apt-get -y install fonts-noto-color-emoji

# Chinese input is fcitx5 (installed in 3.install-vnc-core.sh); skip old fcitx to avoid conflict

echo "Downloading ant contrib jar file..."
cd ~/.zcs-deps && wget https://files.zimbra.com/repository/ant-contrib/ant-contrib-1.0b1.jar

echo "Setting up ssh..."

echo "PasswordAuthentication yes" >>/etc/ssh/sshd_config
echo "PermitRootLogin yes" >>/etc/ssh/sshd_config

# Set ll
echo "alias ll='ls -alF'" >>$HOME/.bashrc

# Set Conda
echo "export PATH=/opt/conda/bin:$PATH" >>~/.bashrc

# Refreash
/bin/bash -c "source ~/.bashrc"

apt-get -qq update -y --fix-missing
