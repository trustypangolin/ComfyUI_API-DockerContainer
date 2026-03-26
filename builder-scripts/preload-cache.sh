#!/bin/bash

set -euo pipefail

echo "########################################"
echo "[INFO] Downloading ComfyUI & Nodes..."
echo "########################################"

cd /default-comfyui-bundle
git clone 'https://github.com/comfyanonymous/ComfyUI.git'
cd /default-comfyui-bundle/ComfyUI
# Using stable version (has a release tag)
git reset --hard "$(git tag | grep -e '^v' | sort -V | tail -1)"

# Force ComfyUI-Manager to use PIP instead of UV
mkdir -p /default-comfyui-bundle/ComfyUI/user/__manager

cat <<EOF > /default-comfyui-bundle/ComfyUI/user/__manager/config.ini
[default]
use_uv = False
security_level = weak
EOF
