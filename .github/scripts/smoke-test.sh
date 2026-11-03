#!/bin/bash
# Start the image the way docker-compose.yml does and check that the desktop really comes up:
# VNC answers with an RFB banner, noVNC serves its page, sshd answers, and the Xfce session
# runs as DEFAULT_USER. Used by CI and by the Docker Hub workflow before it pushes anything.
#
# usage: .github/scripts/smoke-test.sh <image> [timeout seconds]
set -euo pipefail

IMAGE="$1"
TIMEOUT="${2:-120}"
NAME="smoke-$$"
USER_NAME=smoke

trap 'docker rm -f "$NAME" > /dev/null 2>&1 || true' EXIT

docker run -d --name "$NAME" \
  -p 127.0.0.1::5901 -p 127.0.0.1::6901 -p 127.0.0.1::22 \
  -e VNC_PW=smoke-pass -e DEFAULT_USER="$USER_NAME" -e DEFAULT_USER_PASSWORD=smoke-pass \
  "$IMAGE" > /dev/null

host_port() { docker port "$NAME" "$1/tcp" | head -n1 | cut -d: -f2; }
# First bytes a TCP server sends on connect ("RFB 003.008", "SSH-2.0-…")
banner() { timeout 3 bash -c "exec 3<>/dev/tcp/127.0.0.1/$1; head -c 3 <&3" 2>/dev/null || true; }

vnc_answers()   { [[ "$(banner "$(host_port 5901)")" == RFB ]]; }
novnc_serves()  { curl -fsS -o /dev/null "http://127.0.0.1:$(host_port 6901)/vnc.html"; }
sshd_answers()  { [[ "$(banner "$(host_port 22)")" == SSH ]]; }
desktop_runs()  { docker exec "$NAME" pgrep -u "$USER_NAME" -x xfce4-session > /dev/null; }

check() {
  local what="$1" probe="$2" deadline=$((SECONDS + TIMEOUT))
  until "$probe"; do
    if ((SECONDS >= deadline)); then
      echo "FAIL: $what (gave up after ${TIMEOUT}s). Container log:" >&2
      docker logs "$NAME" 2>&1 | tail -n 80 >&2
      exit 1
    fi
    sleep 2
  done
  echo "ok: $what"
}

check "VNC answers on 5901" vnc_answers
check "noVNC serves its page on 6901" novnc_serves
check "sshd answers on 22" sshd_answers
check "Xfce session runs as $USER_NAME" desktop_runs
