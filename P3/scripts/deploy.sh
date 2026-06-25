#!/bin/bash

set -e

echo "----- Deploy placeholder: implementar despliegue (confs -> kubectl apply) -----"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "${SCRIPT_DIR}/../confs/deployment.yaml" ]; then
	echo "Manifiestos encontrados en confs/, puedes implementar: kubectl apply -k confs/ o kubectl apply -f confs/"
else
	echo "No se encontraron manifiestos en ../confs/ — añade deployment.yaml y service.yaml"
fi

