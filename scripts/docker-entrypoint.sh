#!/bin/bash

# Change user settings (create DEFAULT_USER, set passwords)
$SCRIPTS_DIR/1.user-settings.sh

source $HOME/.bashrc

# Add `--skip` to startup args, to skip the VNC startup procedure
if [[ $1 =~ --skip ]]; then
    echo -e "\n\n------------------ SKIP VNC STARTUP -----------------"
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '${@:2}'"
    exec "${@:2}"
fi

VNC_IP=$(hostname -i)
USER_HOME=$(getent passwd "$DEFAULT_USER" | cut -d: -f6)

# Prepare VNC session for DEFAULT_USER (so desktop runs as non-root, e.g. AnyDesk allows it)
echo -e "\n------------------ Setup VNC for user $DEFAULT_USER ------------------"
mkdir -p "$USER_HOME/.vnc"
chown -R "$DEFAULT_USER:$DEFAULT_USER" "$USER_HOME/.vnc"
# Locale for VNC session (default en; pass -e LANG=zh_TW.UTF-8 to override)
VNC_LANG="${LANG:-en_US.UTF-8}"
echo "export LANG=\"$VNC_LANG\"" > "$USER_HOME/.vnc/env"
echo "export LC_ALL=\"$VNC_LANG\"" >> "$USER_HOME/.vnc/env"
chown "$DEFAULT_USER:$DEFAULT_USER" "$USER_HOME/.vnc/env"

# VNC password for DEFAULT_USER
if [[ $VNC_VIEW_ONLY == "true" ]]; then
    echo "start VNC server in VIEW ONLY mode!"
    RAND_PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20)
    runuser -u "$DEFAULT_USER" -- bash -c "echo '$RAND_PW' | vncpasswd -f > \$HOME/.vnc/passwd"
else
    runuser -u "$DEFAULT_USER" -- bash -c "echo '$VNC_PW' | vncpasswd -f > \$HOME/.vnc/passwd"
fi
runuser -u "$DEFAULT_USER" -- chmod 600 "$USER_HOME/.vnc/passwd"

# Copy Xfce config to DEFAULT_USER and fix paths
if [ -d "$HOME/.config" ]; then
    cp -r "$HOME/.config" "$USER_HOME/"
    sed -i "s|/root/.config|$USER_HOME/.config|g" "$USER_HOME/.config/xfconf/xfce-perchannel-xml/"*.xml 2>/dev/null || true
    chown -R "$DEFAULT_USER:$DEFAULT_USER" "$USER_HOME/.config"
fi
# Default input method for VNC user (Chinese input)
runuser -u "$DEFAULT_USER" -- bash -c 'echo fcitx5 | im-config -n 2>/dev/null' || true

# xstartup: run WM as DEFAULT_USER when VNC session starts
cat > "$USER_HOME/.vnc/xstartup" << 'XSTARTUP_EOF'
#!/bin/bash
# VNC X session startup (runs as DEFAULT_USER)
[ -f "$HOME/.vnc/env" ] && . "$HOME/.vnc/env"
/usr/local/bin/wm-startup.sh
XSTARTUP_EOF
chmod 755 "$USER_HOME/.vnc/xstartup"
chown "$DEFAULT_USER:$DEFAULT_USER" "$USER_HOME/.vnc/xstartup"

# Kill any existing server on this display, then start vncserver as DEFAULT_USER
runuser -u "$DEFAULT_USER" -- vncserver -kill "$DISPLAY" 2>/dev/null || true
rm -rf /tmp/.X*-lock /tmp/.X11-unix 2>/dev/null || true
runuser -u "$DEFAULT_USER" -- env DISPLAY="$DISPLAY" vncserver "$DISPLAY" -depth "$VNC_COL_DEPTH" -geometry "$VNC_RESOLUTION"

# Start noVNC webclient (stays as root, proxies to localhost:5901)
echo -e "\n------------------ VNC environment started (user: $DEFAULT_USER) ------------------"
echo -e "\nVNCSERVER on DISPLAY=$DISPLAY \n\t=> VNC viewer: $VNC_IP:$VNC_PORT"
echo -e "\nnoVNC => http://$VNC_IP:$NO_VNC_PORT/?password=...\n"

# Traefik strips /novnc/NAME and forwards to container; noVNC serves at / (--web so vnc.html is found)
(cd "$NO_VNC_DIR" && $NO_VNC_DIR/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT --web "$NO_VNC_DIR") &

if [ -z "$1" ] || [[ $1 =~ -t|--tail-log ]]; then
    echo -e "\n------------------ $USER_HOME/.vnc/*$DISPLAY.log ------------------"
    tail -f $USER_HOME/.vnc/*$DISPLAY.log
else
    echo -e "\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '$@'"
    exec "$@"
fi
