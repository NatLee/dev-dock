#!/bin/bash
# Root shell in the container started by docker-compose.yml (service "vnc")
cd "$(dirname "$0")" && exec docker compose exec vnc bash
