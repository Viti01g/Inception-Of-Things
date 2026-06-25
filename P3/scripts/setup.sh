#!/bin/bash

set -euo pipefail
trap 'echo "ERROR en la línea $LINENO" >&2' ERR

echo "----- Configurando... -----"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Asegurar que los scripts en este directorio sean ejecutables (idempotente)
if [ -d "$SCRIPT_DIR" ]; then
    chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true
fi

CLUSTER_NAME="iot-cluster"
ARGOCD_NAMESPACE="argocd"
DEV_NAMESPACE="dev"
GITHUB_REPO="https://github.com/Viti01g/Inception-Of-Things.git"

# Opcional: no forzar upgrade automático a menos que se exporte AUTO_UPGRADE=true
sudo apt update -y
if [ "${AUTO_UPGRADE:-false}" = "true" ]; then
    sudo apt upgrade -y
fi

if ! command -v docker &> /dev/null; then
    echo "Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    sudo usermod -aG docker "${USER}" 2>/dev/null || true
    echo "Docker instalado. Puede que necesites hacer logout/login para que los permisos se apliquen."
else
    echo "Docker already installed."
fi

if ! command -v kubectl &> /dev/null; then
    echo "Instalando kubectl..."
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64) BIN_ARCH=amd64 ;;
        aarch64|arm64) BIN_ARCH=arm64 ;;
        *) BIN_ARCH=amd64 ;;
    esac
    K8S_VER=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -LO "https://dl.k8s.io/release/${K8S_VER}/bin/linux/${BIN_ARCH}/kubectl"
    chmod +x kubectl
    if command -v sudo &> /dev/null; then
        sudo mv kubectl /usr/local/bin/
    else
        mv kubectl ~/bin/
    fi
else
    echo "kubectl already installed."
fi


if ! command -v k3d &> /dev/null; then
    echo "Instalando k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
    echo "K3D already installed."
fi


# Re-crear el cluster evita estados raros entre ejecuciones de la práctica.
k3d cluster delete "$CLUSTER_NAME" 2>/dev/null || true

# Mapeamos 8888 al load balancer del cluster para acceder a la app desde la VM.
k3d cluster create "$CLUSTER_NAME" -p "8888:80@loadbalancer" -p "8080:443@loadbalancer"

# Namespace dedicado para Argo CD, separado de la app.
if ! kubectl get namespace "$ARGOCD_NAMESPACE" &> /dev/null; then
    kubectl create namespace "$ARGOCD_NAMESPACE"
fi

# Instalación oficial de Argo CD en el namespace anterior.
kubectl apply -n "$ARGOCD_NAMESPACE" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Esperar a que el deployment de argocd-server esté disponible
kubectl -n "$ARGOCD_NAMESPACE" wait --for=condition=Available deployment/argocd-server --timeout=300s || true

# Namespace donde vive la aplicación demo.
if ! kubectl get namespace "$DEV_NAMESPACE" &> /dev/null; then
    kubectl create namespace "$DEV_NAMESPACE"
fi

# La contraseña inicial de Argo CD puede tardar unos segundos en aparecer.
for i in {1..30}; do
    if kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret &> /dev/null; then
        ARGOCD_PASSWORD=$(kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
        break
    fi
    echo "Esperando secret argocd-initial-admin-secret... (intento $i)"
    sleep 5
done
if [ -z "${ARGOCD_PASSWORD:-}" ]; then
    echo "No se pudo obtener la contraseña inicial de Argo CD." >&2
    ARGOCD_PASSWORD="<no-disponible>"
fi

APP_MANIFEST="${SCRIPT_DIR}/../confs/argocd/application.yaml"
if [ -f "$APP_MANIFEST" ]; then
    echo ""
    echo "Aplicando Application de Argo CD para sincronizar con GitHub..."
    kubectl apply -f "$APP_MANIFEST"
    echo "Application creado. Argo CD comenzará a sincronizar automáticamente."
else
    echo "ADVERTENCIA: No se encontró $APP_MANIFEST" >&2
fi

echo ""
echo "=== Setup completado ==="
echo ""
echo "Información de acceso a Argo CD:"
echo "  Usuario: admin"
echo "  Password: $ARGOCD_PASSWORD"
echo ""
echo "Para acceder a Argo CD UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8081:443"
echo "  Luego abre: https://localhost:8081"
echo ""
echo "Para acceder a la aplicación (después del despliegue):"
echo "  La aplicación se expone automáticamente a través de Ingress."
echo "  Abre directamente: http://localhost:8888"
echo "  O prueba con: curl http://localhost:8888/"
echo ""
