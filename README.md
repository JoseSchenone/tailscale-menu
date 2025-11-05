# tailscale-menu

Un script en **Bash** para gestionar Tailscale desde la terminal con un menú interactivo y amigable.
Permite realizar las operaciones más comunes de forma rápida, segura y visual.

---

## ✨ Funcionalidades

- **Menú dinámico:** Muestra el estado actual de la conexión (Conectado/Desconectado) y si se está usando un exit-node.
- **Conexión/Desconexión simple:** Inicia (`tailscale up`) o detiene (`tailscale down`) Tailscale.
- **Gestión de Exit-Nodes:**
    - Lista los exit-nodes disponibles en tu red para que elijas a cuál conectarte.
    - Permite desconectarse del exit-node actual sin interrumpir la conexión a Tailscale.
    - **Conserva la configuración:** Mantiene tus flags (`--advertise-routes`, `--accept-routes`, etc.) al cambiar de exit-node.
- **Consulta de estado:** Muestra la salida completa de `tailscale status`.
- **Verificación de dependencias:** Comprueba si `tailscale` y `jq` están instalados antes de ejecutarse.

---

## 📥 Instalación

1.  Asegúrate de tener `git` y `jq` instalados. En sistemas basados en Debian/Ubuntu:
    ```bash
    sudo apt update && sudo apt install git jq
    ```

2.  Clona el repositorio:
    ```bash
    git clone https://github.com/jose-schenone/tailscale-menu.git
    cd tailscale-menu
    ```

3.  Da permisos de ejecución al script:
    ```bash
    chmod +x tailscale-menu.sh
    ```

4.  Ejecútalo:
    ```bash
    ./tailscale-menu.sh
    ```

## 🖼️ Ejemplo de uso

El menú te da información de un vistazo sobre el estado de tu conexión.

```
=======================================
          Control de Tailscale
=======================================
Estado: Conectado
Usando Exit-Node: mi-servidor-remoto
---------------------------------------
1) Conectar a Tailscale
2) Conectar usando exit-node
3) Desconectar de exit-node
4) Desconectar de Tailscale
5) Ver estado detallado
0) Salir
=======================================
Elige una opción:
```

## 🔧 Requisitos
- [Tailscale](https://tailscale.com/) instalado y en funcionamiento
- `jq` para el procesamiento robusto de la salida JSON.
- Un sistema operativo Linux.

## Notas
- Este script ha sido probado en Linux Mint y Ubuntu, pero debería funcionar en cualquier Linux donde se pueda instalar Tailscale.
