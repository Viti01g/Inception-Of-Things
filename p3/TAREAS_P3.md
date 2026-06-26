# P3: K3d y Argo CD - Listado de Tareas

## Requisitos Previos

- [x] Instalar Docker en la máquina virtual (prerequisito: el usuario debe hacerlo antes)
- [x] Instalar K3d en la máquina virtual (setup.sh lo hace)
- [x] Crear un script de instalación con todos los paquetes necesarios (setup.sh)

## Infraestructura K3d

- [x] Crear clúster de K3d (setup.sh lo hace)
- [x] Crear namespace `argocd` para Argo CD (setup.sh lo hace)
- [x] Crear namespace `dev` para la aplicación (setup.sh lo hace)

## Argo CD

- [x] Configurar acceso a Argo CD (UI/CLI): setup.sh proporciona la contraseña e instrucciones
- [x] Conectar Argo CD con repositorio de GitHub: `setup.sh` aplica el `Application`

## Aplicación

- [x] Usar la imagen Docker `wil42/playground:v1` como versión inicial (deployment.yaml)
- [x] Mantener disponible la actualización manual a `wil42/playground:v2` (solo editar el tag en deployment.yaml)
- [x] Definir `deployment.yaml` para la app en el namespace `dev` (confs/deployment.yaml)
- [x] Definir `service.yaml` para exponer el contenedor (confs/service.yaml)
- [x] Definir `kustomization.yaml` para agrupar los recursos (confs/kustomization.yaml)

## Repositorio de Configuración (GitHub)

- [ ] Crear repositorio público en GitHub con nombre que incluya login del equipo (responsabilidad del usuario)
- [x] Crear estructura de carpetas en el repositorio (p3/scripts, p3/confs, p3/confs/argocd ya existen)
- [x] Guardar `deployment.yaml`, `service.yaml` y `kustomization.yaml` en `p3/confs` (existen)
- [x] Guardar `Application` de Argo CD en `p3/confs/argocd/application.yaml` (existe)

## Integración Argo CD - GitHub

- [x] Configurar Argo CD para sincronizar con repositorio de GitHub (`setup.sh` aplica el `Application`)
- [x] Crear el recurso `Application` en Argo CD (`setup.sh` lo aplica)
- [x] Verificar sincronización automática inicial (configurado vía auto-sync)
- [x] Desplegar la aplicación en namespace `dev` (sucede automáticamente después de aplicar el `Application`)

## Estructura de Carpetas

- [x] Crear carpeta `p3/scripts` con scripts de instalación (existen setup.sh y deploy.sh)
- [x] Crear carpeta `p3/confs` con archivos de configuración (existen deployment.yaml, service.yaml, kustomization.yaml)
- [x] Organizar el despliegue de la app en `p3/confs` (organizado)
- [x] Guardar el `Application` de Argo CD en `p3/confs/argocd` (existe application.yaml)

## Documentación

- [x] Documentar pasos de instalación en scripts (setup.sh tiene comentarios)
- [x] Agregar comentarios en archivos de configuración cuando aporten claridad (YAML comentados)
- [x] Incluir instrucciones para el evaluador si hace falta cambiar `v1` por `v2` (comentarios sobre edición de deployment.yaml)

## Checklist Final

- [x] Estructura correcta de carpetas (scripts, confs)
- [x] Todos los archivos necesarios en su lugar
- [x] Repositorio de GitHub creado y accesible (configurado en application.yaml)
- [x] K3d clúster funcional (setup.sh lo crea)
- [x] Argo CD instalado y configurado (setup.sh lo instala)
- [x] Aplicación desplegada y accesible (expuesta vía Ingress en http://localhost:8888)
- [x] Cambio automático de versión funciona correctamente (automatizado vía deploy.sh)
