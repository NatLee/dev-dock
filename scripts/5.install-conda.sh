#!/bin/bash
set -euo pipefail

# Conda: choose Miniconda installer by host architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)   MINICONDA_ARCH="Linux-x86_64" ;;
  aarch64|arm64) MINICONDA_ARCH="Linux-aarch64" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-${MINICONDA_ARCH}.sh"
echo "Installing Miniconda for $MINICONDA_ARCH..."

wget --quiet "$MINICONDA_URL" -O ~/miniconda.sh
/bin/bash ~/miniconda.sh -b -p /opt/conda
rm ~/miniconda.sh
/opt/conda/bin/conda update -y --all || true
