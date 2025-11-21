#!/bin/bash
# tailscale-menu.sh
# Script interactivo para gestionar Tailscale en Linux
#
# Autor: José Schenone
# Email: jose.schenone@gmail.com
# Web: https://lu3ibm.blogspot.com/
# Licencia: MIT

# --- Colores ---
readonly C_RESET='\033[0m'
readonly C_GREEN='\033[0;32m'
readonly C_RED='\033[0;31m'
readonly C_YELLOW='\033[1;33m' # Amarillo brillante para acciones
readonly C_CYAN='\033[1;36m'   # Cian brillante para bordes y títulos
readonly C_BLUE='\033[1;34m'   # Azul brillante para números de opción

# --- Verificaciones Iniciales ---

# Verificar si se está ejecutando como root
if [[ $EUID -ne 0 ]]; then
   echo -e "${C_RED}Este script debe ejecutarse como root (sudo).${C_RESET}"
   echo -e "${C_YELLOW}Intentando reiniciar con sudo...${C_RESET}"
   exec sudo bash "$0" "$@"
fi

# --- Funciones de Utilidad ---

# Pausa la ejecución hasta que el usuario presione Enter
pause() {
    read -rp "Presiona Enter para continuar..."
}

# Comprueba si los comandos necesarios están instalados
# Comprueba si los comandos necesarios están instalados
check_deps() {
    local missing_deps=0
    for cmd in tailscale jq; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "${C_RED}Error: El comando '$cmd' no está instalado.${C_RESET}"
            missing_deps=1
        fi
    done
    
    if [[ $missing_deps -eq 1 ]]; then
        echo -e "${C_YELLOW}Por favor, instala las dependencias faltantes para continuar.${C_RESET}"
        exit 1
    fi
}

# --- Funciones del Menú ---

connect_ts() {
    echo -e ">> ${C_YELLOW}Conectando a Tailscale...${C_RESET}"
    tailscale up
    pause
}

connect_exit_node() {
    echo -e ">> ${C_YELLOW}Buscando nodos que ofrecen exit-node...${C_RESET}"
    
    # Usar jq para parsear el JSON de forma segura
    local nodes_json
    nodes_json=$(tailscale status --json | jq -c '.Peer[] | select(.ExitNodeOption)')
    
    if [[ -z "$nodes_json" ]]; then
        echo "No hay nodos disponibles como exit-node."
    else
        echo "Nodos disponibles:"
        local i=1
        # Usamos un array indexado para mapear la opción al nombre del nodo
        declare -a nodes_map
        while read -r node; do
            local name ip online
            name=$(echo "$node" | jq -r '.HostName')
            ip=$(echo "$node" | jq -r '.TailscaleIPs[0]')
            online=$(echo "$node" | jq -r '.Online')
            
            local status_color=$C_GREEN
            if [[ "$online" != "true" ]]; then
                status_color=$C_RED
            fi

            echo -e "${C_BLUE}$i)${C_RESET} $name (IP: $ip) [${status_color}Online: $online${C_RESET}]"
            nodes_map[$i]=$name
            ((i++))
        done <<< "$nodes_json"
        echo "0) Cancelar"

        read -rp "Selecciona un nodo: " choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 0 ]] && [[ "$choice" -lt "$i" ]]; then
            if [[ "$choice" == "0" ]]; then
                echo "Cancelado, volviendo al menú principal..."
            else
                local nodename=${nodes_map[$choice]}
                echo -e ">> ${C_YELLOW}Conectando al exit-node: $nodename${C_RESET}"
                
                # Obtener flags actuales para mantenerlos
                local current_flags
                current_flags=$(tailscale status --json | jq -r '.Self | 
                    (if .AcceptRoutes then "--accept-routes " else "" end) + 
                    (if .AdvertiseRoutes | length > 0 then "--advertise-routes=" + (.AdvertiseRoutes | join(",")) else "" end)'
                )

                # Conectarse al exit-node respetando flags existentes
                # shellcheck disable=SC2086
                tailscale up --exit-node="$nodename" $current_flags
            fi
        else
            echo -e "${C_RED}Opción inválida.${C_RESET}"
        fi
    fi
    pause
}

disconnect_exit_node() {
    echo -e ">> ${C_YELLOW}Quitando exit-node, volviendo a modo normal...${C_RESET}"
    tailscale up --exit-node=
    pause
}

disconnect_ts() {
    echo -e ">> ${C_YELLOW}Desconectando de Tailscale...${C_RESET}"
    tailscale down
    pause
}

show_status() {
    echo -e ">> ${C_YELLOW}Estado actual de Tailscale:${C_RESET}"
    tailscale status
    pause
}

toggle_accept_routes() {
    echo -e ">> ${C_YELLOW}Cambiando configuración de rutas...${C_RESET}"
    
    # Verificar estado actual
    local current_state
    current_state=$(tailscale status --json | jq -r '.Self.AcceptRoutes')
    
    if [[ "$current_state" == "true" ]]; then
        echo "Desactivando 'Accept Routes'..."
        tailscale up --accept-routes=false
    else
        echo "Activando 'Accept Routes'..."
        tailscale up --accept-routes=true
    fi
    pause
}

# --- Bucle Principal ---
main() {
    check_deps

    while true; do
        clear
        
        # Obtener estado actual para mostrar en el menú
        local status_output backend_state exit_node_ip self_ip tailscale_version
        status_output=$(tailscale status --json 2>/dev/null)
        backend_state=$(echo "$status_output" | jq -r '.BackendState')
        exit_node_ip=$(echo "$status_output" | jq -r '.Self.ExitNodeIP // ""')
        self_ip=$(echo "$status_output" | jq -r '.Self.TailscaleIPs[0] // "Desconocido"')
        tailscale_version=$(tailscale version | head -n 1)

        echo -e "${C_CYAN}=======================================${C_RESET}"
        echo -e "${C_CYAN}          Control de Tailscale         ${C_RESET}"
        echo -e "${C_CYAN}=======================================${C_RESET}"
        echo -e "Versión: ${tailscale_version}"
        echo -e "IP Local: ${self_ip}"
        echo -e "${C_CYAN}---------------------------------------${C_RESET}"

        if [[ "$backend_state" == "Running" ]]; then
            echo -e "Estado: ${C_GREEN}Conectado${C_RESET}"
            if [[ -n "$exit_node_ip" ]]; then
                local exit_node_name
                exit_node_name=$(echo "$status_output" | jq -r --arg ip "$exit_node_ip" '.Peer[] | select(.TailscaleIPs[] == $ip) | .HostName')
                echo -e "Usando Exit-Node: ${C_GREEN}${exit_node_name:-$exit_node_ip}${C_RESET}"
            else
                 echo -e "Exit-Node: ${C_RED}Ninguno${C_RESET}"
            fi
        else
            echo -e "Estado: ${C_RED}Desconectado${C_RESET}"
        fi
        echo -e "${C_CYAN}---------------------------------------${C_RESET}"

        echo "1) Conectar a Tailscale"
        echo "2) Conectar usando exit-node"
        echo "3) Desconectar de exit-node"
        echo "4) Desconectar de Tailscale"
        echo "5) Ver estado detallado"
        echo "6) Alternar 'Accept Routes'"
        echo "0) Salir"
        echo -e "${C_CYAN}=======================================${C_RESET}"
        read -rp "$(echo -e "${C_CYAN}Elige una opción:${C_RESET} ")" choice

        case $choice in
            1)
                connect_ts
                ;;
            2)
                connect_exit_node
                ;;
            3)
                disconnect_exit_node
                ;;
            4)
                disconnect_ts
                ;;
            5)
                show_status
                ;;
            6)
                toggle_accept_routes
                ;;
            0)
                echo "¡Hasta luego!"
                exit 0
                ;;
            *)
                echo -e "${C_RED}Opción inválida.${C_RESET}"
                sleep 1
                ;;
        esac
    done
}

main "$@"
