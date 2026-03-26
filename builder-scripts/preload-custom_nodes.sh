#!/bin/bash

set -euo pipefail

gcs() {
    git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules "$@"
}

echo "########################################"
echo "[INFO] Downloading Custom Nodes..."
echo "########################################"

# General UI improvements and some useful nodes. 
# Note, for a CPU build designed around APIs, there is no need for a lot of the
# custom_nodes out there, most of the logic is handled by the API (hopefully)
# This list is primarily around loading,saving, and logic type nodes
gcs https://github.com/kijai/ComfyUI-KJNodes.git
gcs https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git
gcs https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
gcs https://github.com/rgthree/rgthree-comfy.git
gcs https://github.com/yolain/ComfyUI-Easy-Use.git

for dir in */; do
    echo "Checking folder: $dir"
    if [ -f "$dir/requirements.txt" ]; then
        echo "  Found requirements.txt - installing..."
        uv pip install -r "$dir/requirements.txt"
        echo
    else
        echo "  No requirements.txt found"
    fi
done
