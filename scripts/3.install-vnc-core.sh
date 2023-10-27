#!/bin/bash
set -euxo pipefail

# Xfce UI
echo "Installing Xfce4 UI components"
apt-get -qq install -y supervisor xfce4 xfce4-terminal
apt-get -qq purge -y pm-utils xscreensaver*

# TigerVNC
echo "Installing TigerVNC server..."
tar xzf $VNC_TOOL_DIR/tigervnc-1.10.1.x86_64.tar.gz --strip 1 -C /


# NoVNC
git clone --depth 1 https://github.com/novnc/noVNC.git $NO_VNC_DIR
chmod +x -v $NO_VNC_DIR/utils/*
ln -s $NO_VNC_DIR/vnc.html $NO_VNC_DIR/index.html