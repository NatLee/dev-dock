#!/bin/bash
# Restart the container started by docker-compose.yml (service "vnc")
cd "$(dirname "$0")" && exec docker compose restart vnc
