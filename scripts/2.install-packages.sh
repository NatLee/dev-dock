#!/bin/bash
set -euxo pipefail

# Create required directories
echo "Creating required directories..."
mkdir -p ~/.zcs-deps
mkdir -p ~/.ivy2/cache

# Environment variables
ENVIRONMENT_FILE="/etc/environment"
echo 'LANG='zh_TW.utf-8'' >>$ENVIRONMENT_FILE
echo 'LANGUAGE='en_US:en'' >>$ENVIRONMENT_FILE

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

# Set locales
echo "Setting up locales..."
apt-get -qq install -y locales
locale-gen zh_TW.UTF-8

# Install fonts
echo "Install Chinese fonts..."
apt-get -y install fonts-droid-fallback \
    ttf-wqy-zenhei \
    ttf-wqy-microhei \
    fonts-arphic-ukai \
    fonts-arphic-uming

echo "Install Emoji fonts..."
apt-get -y install fonts-noto-color-emoji

# Install Chinese input methods
echo "Install Chinese input methods..."
apt-get update -y
apt-get -y install fcitx fcitx-chewing

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
