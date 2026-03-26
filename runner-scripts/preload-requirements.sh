#!/bin/bash

set -euo pipefail

echo "Running in $(pwd)"

# Activate virtual environment if it exists
if [ -d "/opt/venv" ]; then
    echo "[INFO] Activating virtual environment at /opt/venv"
    export VIRTUAL_ENV=/opt/venv
    export PATH="$VIRTUAL_ENV/bin:$PATH"
fi

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
