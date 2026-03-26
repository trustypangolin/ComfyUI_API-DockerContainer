#!/bin/bash

set -euo pipefail

export COMFYUI_LOC=$(pwd)

echo "########################################"
echo "[INFO] Running as user $(id -un):$(id -gn) (UID:$(id -u), GID:$(id -g))"
echo "########################################"

echo "########################################"
echo "[INFO] Running preload-requirements.sh from /custom_nodes..."
echo "########################################"

# Change to custom_nodes directory and run /runner-scripts/preload-requirements.sh
if [ -f /runner-scripts/preload-requirements.sh ]; then
    cd /custom_nodes
    bash /runner-scripts/preload-requirements.sh
else
    echo "[WARN] /runner-scripts/preload-requirements.sh not found, skipping..."
fi

echo "########################################"
echo "[INFO] Starting Python main.py..."
echo "########################################"

# Execute the main.py with any passed arguments
cd $COMFYUI_LOC

# Activate virtual environment if it exists
if [ -d "/opt/venv" ]; then
    echo "[INFO] Activating virtual environment at /opt/venv"
    export VIRTUAL_ENV=/opt/venv
    export PATH="$VIRTUAL_ENV/bin:$PATH"
fi

exec python main.py --port=8188 --listen=0.0.0.0 --cpu --enable-manager "$@"
