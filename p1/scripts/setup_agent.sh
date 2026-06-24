#!/bin/bash
# setup_agent.sh — Installs K3s in agent (worker) mode

set -e

echo "=== Installing K3s Agent ==="

export K3S_URL="https://192.168.56.110:6443"
export K3S_TOKEN="token-secreto-vruiz"

curl -sfL https://get.k3s.io | sh -s - agent \
  --node-ip 192.168.56.111

echo "=== K3s Agent installed successfully ==="
