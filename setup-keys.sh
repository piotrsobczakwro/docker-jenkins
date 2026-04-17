#!/usr/bin/env bash
# setup-keys.sh – generate an SSH key pair for the Jenkins SSH agent.
#
# Creates:
#   secrets/agent-private-key   (mounted into Jenkins controller)
#   secrets/agent-public-key    (reference copy)
#   .env                        (read by docker-compose for JENKINS_AGENT_SSH_PUBKEY)
#
# Usage:
#   bash setup-keys.sh
#   docker-compose up -d        # (or: podman-compose up -d)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="${SCRIPT_DIR}/secrets"

if [[ -f "${SECRETS_DIR}/agent-private-key" ]]; then
    echo "SSH keys already exist in ${SECRETS_DIR}/."
    echo "Delete that directory to regenerate them."
    exit 0
fi

mkdir -p "${SECRETS_DIR}"
chmod 700 "${SECRETS_DIR}"

ssh-keygen -t ed25519 -f "${SECRETS_DIR}/agent-private-key" -N "" -C "jenkins-agent"
mv "${SECRETS_DIR}/agent-private-key.pub" "${SECRETS_DIR}/agent-public-key"

chmod 600 "${SECRETS_DIR}/agent-private-key"
chmod 644 "${SECRETS_DIR}/agent-public-key"

# Write the public key to .env so docker-compose injects it into the agent container
echo "JENKINS_AGENT_SSH_PUBKEY=$(cat "${SECRETS_DIR}/agent-public-key")" > "${SCRIPT_DIR}/.env"
chmod 600 "${SCRIPT_DIR}/.env"

echo ""
echo "SSH key pair generated:"
echo "  Private key : ${SECRETS_DIR}/agent-private-key"
echo "  Public  key : ${SECRETS_DIR}/agent-public-key"
echo "  .env written: ${SCRIPT_DIR}/.env"
echo ""
echo "Start the stack:"
echo "  docker-compose up -d"
echo "  # or: podman-compose up -d"
echo ""
echo "Jenkins UI:  http://localhost:8080"
