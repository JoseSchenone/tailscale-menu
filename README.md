# tailscale-menu

Script en **Bash** para gestionar Tailscale desde la terminal con un menú interactivo.  
Permite conectarse/desconectarse fácilmente, elegir exit-nodes disponibles y consultar el estado de la red.

---

## ✨ Funcionalidades

- Conectar Tailscale (`tailscale up`)
- Conectarse usando un **exit-node** (si hay más de uno, te deja elegir)
- Desconectarse del exit-node (volver al modo normal)
- Desconectarse de Tailscale (`tailscale down`)
- Ver estado de la red (`tailscale status`)

---

## 📥 Instalación

1. Clona el repositorio:
    ```bash
    git clone https://github.com/<tu-usuario>/tailscale-menu.git
    cd tailscale-menu
    ```

2. Da permisos de ejecución al script:
    ```bash
    chmod +x tailscale-menu.sh
    ```

3. Ejecutalo:
    ```bash
    ./tailscale-menu.sh
    ```

## 🖼️ Ejemplo de uso
    ```
    ============================
       Control de Tailscale
    ============================
    1) Conectar a Tailscale
    2) Conectar usando exit-node
    3) Desconectar de exit-node (volver a normal)
    4) Desconectar de Tailscale
    5) Ver estado
    0) Salir
    ============================
    Elige una opción: 
    ```

Si eliges la opción 2, mostrará una lista de exit-nodes disponibles en tu red.

## 🔧 Requisitos
- Tailscale instalado y en funcionamiento
- Linux (probado en Linux Mint y Ubuntu, debería funcionar en cualquier distro)
