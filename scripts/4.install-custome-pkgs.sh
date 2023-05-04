#!/bin/bash

echo "Install *.deb files..."
dpkg -i ~/install/*.deb

# Install Chrome
echo "Install Chrome..."
apt-get -y install libu2f-udev
wget -O -P ~/install/chrome/ https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i ~/install/chrome/google-chrome-stable_current_amd64.deb
cp /usr/bin/google-chrome-stable /usr/bin/google-chrome-stable.bak
cp ~/install/chrome/google-chrome-stable /usr/bin/google-chrome-stable
apt-get -y --fix-broken install

# Install Anydesk
echo "Install Anydesk..."
apt-get -y install libpango1.0-0 \
    libgtkglext1
apt-get -y --fix-broken install
dpkg -i ~/install/anydesk/*.deb

# Autoremove
apt-get -y --fix-broken install
apt-get -y autoremove
