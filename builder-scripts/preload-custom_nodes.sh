#!/bin/bash

set -euo pipefail

gcs() {
    git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules "$@"
}

echo "########################################"
echo "[INFO] Downloading Custom Nodes..."
echo "########################################"

# General
gcs https://github.com/kijai/ComfyUI-KJNodes.git
gcs https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git
gcs https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
gcs https://github.com/rgthree/rgthree-comfy.git
gcs https://github.com/yolain/ComfyUI-Easy-Use.git

for dir in */; do
    echo "Checking folder: $dir"
    if [ -f "$dir/requirements.txt" ]; then
        echo "  Found requirements.txt - installing..."
        pip install -r "$dir/requirements.txt" # --root-user-action=ignore
        echo
    else
        echo "  No requirements.txt found"
    fi
done
