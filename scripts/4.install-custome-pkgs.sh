#!/bin/bash

echo "Install *.deb files..."
dpkg -i ~/install/*.deb

# Install Firefox
wget -O ~/FirefoxSetup.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64"
tar xjf ~/FirefoxSetup.tar.bz2 -C /opt/
mv /usr/lib/firefox/firefox /usr/lib/firefox/firefox_backup
mkdir /usr/lib/firefox 
ln -s /opt/firefox/firefox /usr/lib/firefox/firefox
cp ~/install/firefox.desktop /usr/share/applications/


# Install Anydesk
echo "Install Anydesk..."
apt-get -y install libpango1.0-0 \
    libgtkglext1
apt-get -y --fix-broken install
dpkg -i ~/install/anydesk/*.deb

# Autoremove
apt-get -y --fix-broken install
apt-get -y autoremove
