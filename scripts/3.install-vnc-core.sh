#!/bin/bash
set -euxo pipefail

# Xfce UI
echo "Installing Xfce4 UI components"
apt-get -qq install -y supervisor xfce4 xfce4-terminal
apt-get -qq purge -y pm-utils xscreensaver*

# TigerVNC
echo "Installing TigerVNC server..."
tar xzf $VNC_TOOL_DIR/tigervnc-1.10.1.x86_64.tar.gz --strip 1 -C /

# noVNC
echo "Installing noVNC..."
mkdir -p $NO_VNC_DIR/utils/websockify
tar xzf $VNC_TOOL_DIR/noVNC-v1.1.0.tar.gz --strip 1 -C $NO_VNC_DIR
tar xzf $VNC_TOOL_DIR/websockifyv0.9.0.tar.gz --strip 1 -C $NO_VNC_DIR/utils/websockify
# noVNC's `websockify` needs numpy
# https://numpy.org/doc/stable/reference/generated/numpy.fromstring.html
apt-get -y install python-numpy

chmod +x -v $NO_VNC_DIR/utils/*.sh
# Create index.html to forward automatically to `vnc_auto.html`
ln -s $NO_VNC_DIR/vnc.html $NO_VNC_DIR/index.html
