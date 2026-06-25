# Variables
CLUSTER_NAME = iot-cluster
ARGOCD_NS = argocd
DEV_NS = dev

.PHONY: all setup deploy clean port-forward password status test help

all: help

help:
	@echo 
	@echo "  make setup        - Ejecuta el script de instalación (setup.sh) para crear el clúster y Argo CD"
	@echo "  make deploy       - Alterna la versión de la app v1 <-> v2 y sube los cambios a GitHub (deploy.sh)"
	@echo "  make port-forward - Levanta el túnel para acceder a Argo CD en https://localhost:8081"
	@echo "  make password     - Muestra la contraseña inicial de administrador de Argo CD"
	@echo "  make status       - Muestra el estado de todos los recursos en 'dev' y 'argocd'"
	@echo "  make test         - Realiza un curl a http://localhost:8888/ para comprobar la versión de la app"
	@echo "  make clean        - Elimina el clúster de K3d y limpia los recursos"

setup:
	@chmod +x scripts/setup.sh
	./scripts/setup.sh

deploy:
	@chmod +x scripts/deploy.sh
	./scripts/deploy.sh $(VERSION)

port-forward:
	@echo "Iniciando reenvío de puertos para Argo CD..."
	@echo "Abre https://localhost:8081 en tu navegador."
	kubectl port-forward svc/argocd-server -n $(ARGOCD_NS) 8081:443

password:
	@echo "Contraseña de administrador de Argo CD:"
	@kubectl -n $(ARGOCD_NS) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "Secreto no encontrado. Quizás ya fue eliminado o Argo CD no está instalado."
	@echo ""

status:
	@echo "=== Recursos en namespace: $(DEV_NS) ==="
	kubectl get all,ingress -n $(DEV_NS)
	@echo ""
	@echo "=== Recursos en namespace: $(ARGOCD_NS) ==="
	kubectl get pods -n $(ARGOCD_NS)

test:
	@curl -s http://localhost:8888/ || echo "Error: La aplicación no responde. ¿Se ha sincronizado Argo CD y creado el Ingress?"
	@echo ""

clean:
	@echo "Eliminando clúster k3d: $(CLUSTER_NAME)..."
	k3d cluster delete $(CLUSTER_NAME)
