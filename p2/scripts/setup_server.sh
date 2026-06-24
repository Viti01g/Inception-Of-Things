#!/bin/bash
# setup_server.sh — Installs K3s in server mode and deploys the 3 applications

set -e

echo "=== Installing K3s Server ==="

export DEBIAN_FRONTEND=noninteractive

curl -sfL https://get.k3s.io | sh -s - server \
  --node-ip 192.168.56.110 \
  --write-kubeconfig-mode 644

echo "=== Waiting for K3s to be ready ==="
until sudo k3s kubectl get nodes 2>/dev/null | grep -q " Ready"; do
  echo "Waiting for K3s node to be Ready..."
  sleep 5
done
echo "K3s node is Ready."

echo "=== Deploying applications ==="
sudo k3s kubectl apply -f /vagrant/confs/app1.yaml
sudo k3s kubectl apply -f /vagrant/confs/app2.yaml
sudo k3s kubectl apply -f /vagrant/confs/app3.yaml
sudo k3s kubectl apply -f /vagrant/confs/ingress.yaml

echo "=== Waiting for pods to be ready ==="
sudo k3s kubectl wait --for=condition=available --timeout=120s deployment/app1-deployment
sudo k3s kubectl wait --for=condition=available --timeout=120s deployment/app2-deployment
sudo k3s kubectl wait --for=condition=available --timeout=120s deployment/app3-deployment

echo "=== All applications deployed successfully ==="
sudo k3s kubectl get pods
sudo k3s kubectl get ingress
