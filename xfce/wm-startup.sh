#!/bin/bash
set -euo pipefail

echo -e "\n------------------ startup of Xfce (X11) ------------------"

### UTF-8 locale (default en; set container env LANG to override, e.g. -e LANG=zh_TW.UTF-8)
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-$LANG}"

### ensure PATH so Code (wrapper with --no-sandbox), Firefox, and other apps are found
export PATH="/usr/local/bin:/usr/bin:$PATH"

### set Firefox as default web browser
if command -v xdg-mime &>/dev/null && [ -f /usr/share/applications/firefox.desktop ]; then
  xdg-mime default firefox.desktop x-scheme-handler/http 2>/dev/null || true
  xdg-mime default firefox.desktop x-scheme-handler/https 2>/dev/null || true
  xdg-settings set default-web-browser firefox.desktop 2>/dev/null || true
fi

### disable screensaver and power management
xset -dpms &
xset s noblank &
xset s off &

### Chinese input: fcitx5 (start before session so IM is available)
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
fcitx5 -d 2>/dev/null || true
sleep 1

### Xfce for VNC; session bus via dbus-launch (no systemd)
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session startxfce4
