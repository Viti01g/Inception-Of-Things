#!/bin/bash

set -euo pipefail

# Obtener el directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOYMENT_FILE="${SCRIPT_DIR}/../confs/deployment.yaml"

if [ ! -f "$DEPLOYMENT_FILE" ]; then
    echo "ERROR: No se encontró el archivo $DEPLOYMENT_FILE" >&2
    exit 1
fi

# Detectar la versión actual
CURRENT_VERSION=$(grep -oE 'wil42/playground:v[1-9][0-9]*' "$DEPLOYMENT_FILE" | cut -d':' -f2 || true)

if [ -z "$CURRENT_VERSION" ]; then
    echo "ERROR: No se pudo determinar la versión actual de la imagen (debe tener el formato wil42/playground:vX)" >&2
    exit 1
fi

echo "Versión actual de la aplicación: $CURRENT_VERSION"

# Determinar nueva versión
TARGET_VERSION=""
if [ $# -ge 1 ]; then
    TARGET_VERSION="$1"
else
    # Si no se pasa argumento, alternar entre v1 y v2
    if [ "$CURRENT_VERSION" = "v1" ]; then
        TARGET_VERSION="v2"
    else
        TARGET_VERSION="v1"
    fi
fi

if [ "$CURRENT_VERSION" = "$TARGET_VERSION" ]; then
    echo "La aplicación ya está en la versión $TARGET_VERSION. Nada que hacer."
    exit 0
fi

echo "Cambiando versión de $CURRENT_VERSION a: $TARGET_VERSION..."

# Reemplazar versión en el deployment.yaml (compatible con GNU y BSD sed)
if sed --version >/dev/null 2>&1; then
    # GNU sed (Linux)
    sed -i "s|wil42/playground:$CURRENT_VERSION|wil42/playground:$TARGET_VERSION|g" "$DEPLOYMENT_FILE"
else
    # BSD sed (macOS)
    sed -i '' "s|wil42/playground:$CURRENT_VERSION|wil42/playground:$TARGET_VERSION|g" "$DEPLOYMENT_FILE"
fi

echo "Archivo de despliegue actualizado:"
grep "image: wil42/playground" "$DEPLOYMENT_FILE"

# Intentar subir el cambio a GitHub automáticamente para disparar Argo CD
echo ""
echo "=== Actualizando en GitHub (GitOps) ==="
cd "${SCRIPT_DIR}/../.."

# Verificar si hay cambios en git
if git diff --quiet P3/confs/deployment.yaml; then
    echo "No hay cambios locales en deployment.yaml detectados por git."
else
    git add P3/confs/deployment.yaml
    git commit -m "Update application to $TARGET_VERSION"
    echo "Ejecutando git push..."
    git push origin p3
    echo "¡Cambios empujados a GitHub! Argo CD comenzará la sincronización."
fi
