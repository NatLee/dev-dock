#!/bin/bash
set -euxo pipefail

# Ensure apt index is available (may have been cleaned by a previous Docker layer)
apt-get -qq update -y

# Xfce desktop (lightweight, VNC-friendly)
echo "Installing Xfce desktop..."
apt-get -qq install -y supervisor dbus-x11 xfce4 xfce4-terminal
apt-get -qq purge -y lightdm* 2>/dev/null || true
# Chinese input: fcitx5 + pinyin
apt-get -qq install -y fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk3 fcitx5-config-qt im-config
# Set fcitx5 as default input method (for all users)
echo "fcitx5" | im-config -n 2>/dev/null || true
# Autostart fcitx5 in Xfce so input method is available in all apps
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/fcitx5-autostart.desktop << 'FCITX5_EOF'
[Desktop Entry]
Type=Application
Name=Fcitx 5
Exec=fcitx5 -d
OnlyShowIn=XFCE;
X-GNOME-Autostart-Phase=Application
FCITX5_EOF
apt-get -qq purge -y pm-utils xscreensaver* 2>/dev/null || true

# TigerVNC: use tarball on x86_64, apt on arm64/aarch64 (tarball is x86-only)
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    echo "Installing TigerVNC server from tarball..."
    tar xzf $VNC_TOOL_DIR/tigervnc-1.16.0.x86_64.tar.gz --strip 1 -C /
    ;;
  aarch64|arm64)
    echo "Installing TigerVNC server from apt (native $ARCH)..."
    apt-get -qq install -y tigervnc-standalone-server tigervnc-common
    ;;
  *)
    echo "Unsupported architecture for TigerVNC: $ARCH" >&2
    exit 1
    ;;
esac

# NoVNC
git clone --depth 1 https://github.com/novnc/noVNC.git $NO_VNC_DIR
chmod +x -v $NO_VNC_DIR/utils/*
ln -s $NO_VNC_DIR/vnc.html $NO_VNC_DIR/index.html