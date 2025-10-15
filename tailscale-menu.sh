#!/bin/bash
# tailscale-menu.sh
# Script interactivo para gestionar Tailscale en Linux
# Autor: José Schenone
# Email: jose.schenone@gmail.com
# Web: https://lu3ibm.blogspot.com/
# Licencia: MIT

while true; do
    clear
    echo "============================"
    echo "   Control de Tailscale"
    echo "============================"
    echo "1) Conectar a Tailscale"
    echo "2) Conectar usando exit-node"
    echo "3) Desconectar de exit-node (volver a normal)"
    echo "4) Desconectar de Tailscale"
    echo "5) Ver estado"
    echo "0) Salir"
    echo "============================"
    read -rp "Elige una opción: " opcion

    case $opcion in
        1)
            echo ">> Conectando a Tailscale..."
            sudo tailscale up
            read -rp "Presiona Enter para continuar..."
            ;;
        2)
            echo ">> Buscando nodos que ofrecen exit-node..."
            # Obtener nombre (columna 2) e IP (columna 1)
            nodes=$(tailscale status | grep "exit node")
            if [ -z "$nodes" ]; then
                echo "No hay nodos disponibles como exit-node."
            else
                echo "Nodos disponibles:"
                i=1
                declare -A map
                while read -r line; do
                    name=$(echo "$line" | awk '{print $2}')
                    ip=$(echo "$line" | awk '{print $1}')
                    echo "$i) $name  (IP: $ip)"
                    map[$i]=$name
                    ((i++))
                done <<< "$nodes"
                echo "0) Cancelar"

                read -rp "Selecciona un nodo: " choice
                if [ "$choice" == "0" ]; then
                    echo "Cancelado, volviendo al menú principal..."
                elif [ -n "${map[$choice]}" ]; then
                    nodename=${map[$choice]}
                    echo ">> Conectando al exit-node: $nodename"
                    # Detectar flags no-default activos
                    flags=""
                    if tailscale status --json | grep -q '"AdvertiseRoutes":'; then
                        advertise_routes=$(tailscale status --json | jq -r '.Self.AdvertiseRoutes | join(",")')
                        [ "$advertise_routes" != "null" ] && flags+=" --advertise-routes=$advertise_routes"
                    fi
                    if tailscale status --json | grep -q '"AcceptRoutes":true'; then
                        flags+=" --accept-routes"
                    fi

                    # Conectarse al exit-node respetando flags existentes
                    sudo tailscale up --exit-node="$nodename" $flags
                else
                    echo "Opción inválida."
                fi
            fi
            read -rp "Presiona Enter para continuar..."
            ;;
        3)
            echo ">> Quitando exit-node, volviendo a modo normal..."
            sudo tailscale up --exit-node=
            read -rp "Presiona Enter para continuar..."
            ;;
        4)
            echo ">> Desconectando de Tailscale..."
            sudo tailscale down
            read -rp "Presiona Enter para continuar..."
            ;;
        5)
            echo ">> Estado actual de Tailscale:"
            tailscale status
            read -rp "Presiona Enter para continuar..."
            ;;
        0)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción inválida."
            sleep 1
            ;;
    esac
done

