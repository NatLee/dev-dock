#!/bin/bash
set -euo pipefail

# VS Code: manual install from official .deb (no Microsoft apt repo)
echo "Installing VS Code (manual .deb)..."
apt-get -qq update -y
apt-get -qq install -y wget
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)   VSCODE_DEB="linux-deb-x64"   ; FIREFOX_OS="linux64" ;;
  aarch64|arm64) VSCODE_DEB="linux-deb-arm64" ; FIREFOX_OS="linux64-aarch64" ;;
  *) echo "Unsupported arch for VS Code: $ARCH" >&2; exit 1 ;;
esac
# Avoid interactive prompt to add Microsoft repo (we install .deb only)
echo "code code/add-microsoft-repo boolean false" | debconf-set-selections
# Timeout and show progress so build does not appear stuck (VS Code .deb is large)
wget --timeout=300 --tries=2 --progress=bar:force:noscroll -O /tmp/vscode.deb "https://update.code.visualstudio.com/latest/${VSCODE_DEB}/stable" || \
  { echo "VS Code download failed or timed out" >&2; exit 1; }
dpkg -i /tmp/vscode.deb || true
apt-get install -f -y
rm -f /tmp/vscode.deb
# Wrapper so Code runs with --no-sandbox (container often lacks namespace permissions)
cat > /usr/local/bin/code << 'CODEEOF'
#!/bin/sh
if [ -x /usr/share/code/code ]; then
  exec /usr/share/code/code --no-sandbox "$@"
else
  exec /usr/bin/code --no-sandbox "$@"
fi
CODEEOF
chmod 755 /usr/local/bin/code
# Desktop shortcuts must use wrapper so launcher runs with --no-sandbox
for f in /usr/share/applications/code.desktop /usr/share/applications/code-url-handler.desktop; do
  [ -f "$f" ] && sed -i 's|Exec=/usr/share/code/code|Exec=/usr/local/bin/code|g' "$f"
done

# Firefox (standalone to /opt; Mozilla now ships Linux as .tar.xz)
echo "Installing Firefox..."
apt-get -qq install -y xz-utils
wget --timeout=300 --tries=2 --progress=bar:force:noscroll -O /tmp/FirefoxSetup.tar.xz "https://download.mozilla.org/?product=firefox-latest-ssl&os=${FIREFOX_OS}&lang=en-US" || \
  { echo "Firefox download failed or timed out" >&2; exit 1; }
tar xJf /tmp/FirefoxSetup.tar.xz -C /opt/
rm -f /tmp/FirefoxSetup.tar.xz
cat > /usr/share/applications/firefox.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=Firefox Web Browser
Comment=Browse the World Wide Web
GenericName=Web Browser
Keywords=Internet;WWW;Browser;Web;Explorer
Exec=/opt/firefox/firefox %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;
StartupNotify=true
Actions=new-window;new-private-window;

[Desktop Action new-window]
Name=New Window
Exec=/opt/firefox/firefox -new-window

[Desktop Action new-private-window]
Name=New Private Window
Exec=/opt/firefox/firefox -private-window
EOF
# System default browser (for x-www-browser / www-browser)
update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200
update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /opt/firefox/firefox 200

# AnyDesk from official apt repository
echo "Installing AnyDesk..."
wget --timeout=60 -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
echo "deb http://deb.anydesk.com/ all main" | tee /etc/apt/sources.list.d/anydesk-stable.list
apt-get -qq update -y
apt-get -qq install -y anydesk

apt-get -y -qq autoremove || true
