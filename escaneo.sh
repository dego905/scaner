#!/bin/bash
#Sin Nombre
# Colores
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function scan_local_network {
    echo -e "${CYAN}Escaneando dispositivos en la red local...${NC}"
    
   
    nmap -sn 192.168.1.0/24 -oG - 2>/dev/null | awk '/Up$/{print $2,$3}'
    
    echo -e "${CYAN}¿Deseas ralentizar la velocidad de internet de algún dispositivo en la red local? (s/n)${NC}"
    read option
    if [[ $option == "s" || $option == "S" ]]; then
        slow_down_device
    fi
}

function slow_down_device {
    echo -e "${CYAN}Introduce la dirección IP del dispositivo que deseas ralentizar:${NC}"
    read device_ip
    if [[ ! $device_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${YELLOW}Dirección IP no válida.${NC}"
        return 1
    fi
    echo -e "${CYAN}Introduce la velocidad en kbps a la que deseas ralentizar el dispositivo (por ejemplo, 1000):${NC}"
    read speed_kbps
    echo -e "${CYAN}Ralentizando la velocidad del dispositivo $device_ip a $speed_kbps kbps...${NC}"
    
    termux-tts-speak "Redirigiendo el tráfico del dispositivo $device_ip a través del proxy local"
    termux-wake-lock
    termux-firewall-nat --add forward --out wlan0 --dst $device_ip
    termux-wake-lock
    
    termux-tts-speak "Limitando la velocidad de salida del dispositivo $device_ip a ${speed_kbps}kbps"
    termux-wake-lock
    termux-upload -r -c 2>/dev/null <(echo "wlan0:1.2.3.4,$speed_kbps") >/dev/null
    
    echo -e "${GREEN}La velocidad del dispositivo $device_ip se ha ralentizado a $speed_kbps kbps.${NC}"
}

function show_help {
    echo -e "${CYAN}Este script permite escanear dispositivos en la red local y ralentizar la velocidad de internet de un dispositivo.${NC}"
    echo -e "${CYAN}Opciones disponibles:${NC}"
    echo -e "${GREEN}-l${NC} : Escanear dispositivos en la red local"
    echo -e "${GREEN}-h${NC} : Mostrar esta ayuda"
}

while getopts "lh" option; do
    case $option in
        l) scan_local_network;;
        h) show_help;;
        *) echo -e "${YELLOW}Opción no válida${NC}";;
    esac
done

if [ $OPTIND -eq 1 ]; then
    echo -e "${YELLOW}No se proporcionaron opciones válidas.${NC}"
    show_help
    exit 1
fi
