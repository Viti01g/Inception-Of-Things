#!/bin/bash
# setup_server.sh — Installs K3s in server (controller) mode

set -e

echo "=== Installing K3s Server ==="

export INSTALL_K3S_EXEC="server"
export K3S_TOKEN="token-secreto-vruiz"

curl -sfL https://get.k3s.io | sh -s - server \
  --node-ip 192.168.56.110 \
  --write-kubeconfig-mode 644

echo "=== K3s Server installed successfully ==="
echo "Waiting for K3s to be ready..."
sleep 10

# Verify the node is up
sudo k3s kubectl get nodes
echo "=== Server setup complete ==="
