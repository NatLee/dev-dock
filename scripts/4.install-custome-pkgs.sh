#!/bin/bash

echo "Install *.deb files..."
dpkg -i ~/install/*.deb

# Install Chrome
echo "Install Chrome..."
apt-get -y install libu2f-udev
wget -O ~/install/chrome/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i ~/install/chrome/chrome.deb
cp ~/install/chrome/google-chrome-stable /usr/local/bin/google-chrome-stable
chmod +x /usr/local/bin/google-chrome-stable
CHROME_LAUNCHER_PATH="/usr/bin/google-chrome-stable"
mv "$CHROME_LAUNCHER_PATH" "${CHROME_LAUNCHER_PATH}.bak"
ln -s /usr/local/bin/google-chrome-stable /usr/bin/google-chrome-stable
xhost +SI:localuser:$DEFAULT_USER
apt-get -y --fix-broken install


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
