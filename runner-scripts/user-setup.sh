#!/bin/bash
set -euo pipefail

# Create group if it doesn't exist
if ! getent group ${PGID} > /dev/null 2>&1; then
    groupadd -g ${PGID} appgroup || true
fi

# Create user if it doesn't exist
if ! id -u ${PUID} > /dev/null 2>&1; then
    useradd -u ${PUID} -g ${PGID} -s /bin/bash -m appuser
fi

# Ensure appuser has sudo access (for package installation in venv)
echo "appuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 2>/dev/null || true

exec gosu appuser "$@"