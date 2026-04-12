#!/usr/bin/env bash
# jenkins-setup.sh – install Podman and run Jenkins as a systemd service via Podman Quadlets.

set -euo pipefail

# ---------------------------------------------------------------------------
# 1. Install Podman and supporting tools
# ---------------------------------------------------------------------------
sudo dnf -y install podman podman-compose

# ---------------------------------------------------------------------------
# 2. Build the Jenkins container image
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
podman build -t jenkins:jcasc "$SCRIPT_DIR"

# ---------------------------------------------------------------------------
# 3. Install the Podman Quadlet service file (rootless, current user)
# ---------------------------------------------------------------------------
QUADLET_DIR="${HOME}/.config/containers/systemd"
mkdir -p "$QUADLET_DIR"
cp "$SCRIPT_DIR/jenkins.container" "$QUADLET_DIR/jenkins.container"

# ---------------------------------------------------------------------------
# 4. Enable linger so the user service survives logout
# ---------------------------------------------------------------------------
loginctl enable-linger "$(whoami)"

# ---------------------------------------------------------------------------
# 5. Reload systemd and start Jenkins
# ---------------------------------------------------------------------------
systemctl --user daemon-reload
systemctl --user enable --now jenkins.service

echo ""
echo "Jenkins is starting. Check status with:"
echo "  systemctl --user status jenkins.service"
echo ""
echo "Access Jenkins at http://localhost:8080"
echo ""
echo "To open the firewall port run:"
echo "  sudo firewall-cmd --add-port=8080/tcp --permanent && sudo firewall-cmd --reload"

