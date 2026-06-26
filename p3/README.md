# P3: K3d y Argo CD - Guía de Uso Rápido

Esta guía explica **qué hace** y **cuándo debes ejecutar** cada comando automatizado en el `Makefile` para la defensa o comprobación de la **Parte 3** del proyecto *Inception-of-Things*.

---

## 🚀 Flujo de Trabajo Completo (Paso a Paso)

### 1. Inicialización del Entorno (Al empezar)
**Cuándo ejecutarlo:** La primera vez que vayas a montar el laboratorio o si quieres rehacerlo de cero en un clúster limpio.

```bash
make setup
```
* **¿Qué hace?**: Crea un nuevo clúster de K3d (`iot-cluster`), instala Argo CD en el namespace `argocd`, crea el namespace `dev`, y configura la aplicación `wil-playground` para que apunte a tu repositorio de GitHub.
* **Resultado**: Al finalizar, imprimirá en la consola las instrucciones de acceso y la **contraseña inicial** de Argo CD.

---

### 2. Recuperación de Credenciales (Si olvidas la contraseña)
**Cuándo ejecutarlo:** Si necesitas entrar a la interfaz web de Argo CD y olvidaste la contraseña que imprimió el comando anterior.

```bash
make password
```
* **¿Qué hace?**: Extrae de forma segura el secreto cifrado de Kubernetes donde se guarda la contraseña por defecto de Argo CD y la muestra decodificada.

---

### 3. Acceso a la Interfaz de Argo CD (Para ver el estado visual)
**Cuándo ejecutarlo:** Cuando quieras abrir la interfaz gráfica de Argo CD (`https://localhost:8081`) para verificar el árbol de recursos y las sincronizaciones.

```bash
make port-forward
```
* **¿Qué hace?**: Crea un túnel de red directo entre tu máquina y el servicio de Argo CD.
* **Nota**: La terminal se quedará "bloqueada" transmitiendo datos. Déjala abierta y ve al navegador. Cuando quieras cerrarlo, presiona `Ctrl + C` en esa terminal.

---

### 4. Consultar el Estado del Clúster (Diagnósticos rápidos)
**Cuándo ejecutarlo:** En cualquier momento que quieras ver si los pods están corriendo, si el service funciona o si el ingress está activo en Kubernetes.

```bash
make status
```
* **¿Qué hace?**: Lanza comandos `kubectl` para mostrarte de forma ordenada todos los recursos desplegados en los namespaces `dev` (tu app) y `argocd` (el panel de control).

---

### 5. Probar el Funcionamiento de la Aplicación
**Cuándo ejecutarlo:** Una vez que Argo CD haya terminado de sincronizarse para certificar que la aplicación responde.

```bash
make test
```
* **¿Qué hace?**: Lanza un `curl` al puerto local `8888` (puerto del Ingress) y te muestra qué versión de la aplicación responde en ese instante (`v1` o `v2`).

---

### 6. Demostración de GitOps (Cambio de Versión)
**Cuándo ejecutarlo:** Durante la evaluación/defensa, para demostrar que Argo CD detecta y despliega automáticamente cambios realizados en tu código en GitHub.

```bash
make deploy
```
* **¿Qué hace?**: Detecta la versión actual de la aplicación (`v1` o `v2`), la cambia por la otra en tu archivo local `deployment.yaml`, realiza automáticamente un commit en Git y hace un `git push` a tu repositorio.
* **Resultado**: Al cabo de unos segundos, verás en la web de Argo CD cómo se sincroniza y, si ejecutas `make test`, verás que la aplicación ha cambiado de versión.

---

### 7. Limpieza total (Al terminar)
**Cuándo ejecutarlo:** Al finalizar tus pruebas o la evaluación si quieres apagar y eliminar todo el clúster para liberar recursos de tu máquina.

```bash
make clean
```
* **¿Qué hace?**: Borra completamente el clúster de K3d (`iot-cluster`) y todos los datos asociados, dejando tu sistema limpio.
