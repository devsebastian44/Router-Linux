#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuración de Rutas
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DHCP_DIR="$PROJECT_ROOT/configs/dhcp"
DNS_DIR="$PROJECT_ROOT/configs/dns"

# Archivo de log
LOG_FILE="router_setup.log"

# Función de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Banner
mostrar_banner() {
    clear
    echo
    echo -e "${BLUE} __________               __                 .____    .__                      ${NC}"
    echo -e "${BLUE} \\______   \\ ____  __ ___/  |_  ___________  |    |   |__| ____  __ _____  ___ ${NC}"
    echo -e "${BLUE}  |       _//  _ \\|  |  \\   __\\/ __ \\_  __ \\ |    |   |  |/    \\|  |  \\  \\/  / ${NC}"
    echo -e "${BLUE}  |    |   (  <_> )  |  /|  | \\  ___/|  | \\/ |    |___|  |   |  \\  |  />    <  ${NC}"
    echo -e "${BLUE}  |____|_  /\\____/|____/ |__|  \\___  >__|    |_______ \\__|___|  /____//__/\\_ \\ ${NC}"
    echo -e "${BLUE}        \\/                        \\/                \\/       \\/            \\/  ${NC}"
    echo
}

# Manejador de interrupción
int_handler() {
    echo
    echo -e "${YELLOW}[!] Instalación interrumpida${NC}"
    log "Instalación interrumpida por el usuario"
    exit 1
}

trap 'int_handler' INT

# Verificar root
verificar_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}[!] Este script debe ejecutarse como root (usando sudo)${NC}"
        log "ERROR: Script ejecutado sin privilegios root"
        exit 1
    fi
}

# Crear backup de configuración
backup_archivo() {
    local archivo=$1
    if [ -f "$archivo" ]; then
        local backup="${archivo}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$archivo" "$backup"
        echo -e "${GREEN}[✓]${NC} Backup creado: $backup"
        log "Backup creado: $backup"
    fi
}

# Obtener adaptador principal
obtener_adaptador_principal() {
    echo -e "${YELLOW}[*]${NC} Detectando adaptador de red principal..."
    
    # Método 1: ip route
    local adaptador=$(ip route | grep default | awk '{print $5}' | head -n 1)
    
    if [ -z "$adaptador" ]; then
        # Método 2: route -n
        adaptador=$(route -n | grep '^0.0.0.0' | awk '{print $8}' | head -n 1)
    fi
    
    if [ -z "$adaptador" ]; then
        echo -e "${RED}[!]${NC} No se puede determinar el adaptador principal"
        log "ERROR: No se pudo detectar adaptador principal"
        return 1
    fi
    
    # Verificar que el adaptador existe
    if ! ip link show "$adaptador" &>/dev/null; then
        echo -e "${RED}[!]${NC} El adaptador $adaptador no existe"
        log "ERROR: Adaptador $adaptador no encontrado"
        return 1
    fi
    
    echo -e "${GREEN}[✓]${NC} Adaptador detectado: ${BOLD}$adaptador${NC}"
    log "Adaptador principal: $adaptador"
    echo "$adaptador"
    return 0
}

# Listar todos los adaptadores disponibles
listar_adaptadores() {
    echo -e "\n${BOLD}Adaptadores de red disponibles:${NC}"
    ip -br link show | while read -r iface state rest; do
        if [ "$iface" != "lo" ]; then
            local ip_addr=$(ip -4 addr show "$iface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)
            if [ -n "$ip_addr" ]; then
                echo -e "  ${GREEN}[✓]${NC} $iface - $state - IP: $ip_addr"
            else
                echo -e "  ${YELLOW}[-]${NC} $iface - $state - Sin IP"
            fi
        fi
    done
}

# Configurar IP forwarding
configurar_ip_forward() {
    echo
    echo -e "${BOLD}=== CONFIGURANDO IP FORWARDING ===${NC}"
    log "Configurando IP forwarding"
    
    # Habilitar temporalmente
    echo -e "${YELLOW}[*]${NC} Habilitando IP forwarding..."
    if echo 1 > /proc/sys/net/ipv4/ip_forward; then
        echo -e "${GREEN}[✓]${NC} IP forwarding habilitado"
        log "IP forwarding habilitado temporalmente"
    else
        echo -e "${RED}[!]${NC} Error al habilitar IP forwarding"
        return 1
    fi
    
    # Hacer permanente en sysctl.conf
    echo -e "${YELLOW}[*]${NC} Configurando permanentemente..."
    backup_archivo "/etc/sysctl.conf"
    
    if grep -q "^net.ipv4.ip_forward" /etc/sysctl.conf; then
        sed -i 's/^net.ipv4.ip_forward.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
    else
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    fi
    
    sysctl -p /etc/sysctl.conf >> "$LOG_FILE" 2>&1
    echo -e "${GREEN}[✓]${NC} IP forwarding configurado permanentemente"
    log "IP forwarding configurado en sysctl.conf"
    
    return 0
}

# Configurar iptables
configurar_iptables() {
    local adaptador=$1
    
    echo
    echo -e "${BOLD}=== CONFIGURANDO IPTABLES ===${NC}"
    log "Configurando iptables para adaptador: $adaptador"
    
    # Mostrar reglas actuales
    echo -e "${YELLOW}[*]${NC} Reglas actuales:"
    iptables -L -n --line-numbers | head -20
    
    echo -e "\n${YELLOW}[?]${NC} ¿Deseas limpiar las reglas existentes? [s/N]"
    read -r respuesta
    if [[ "$respuesta" =~ ^[Ss]$ ]]; then
        echo -e "${YELLOW}[*]${NC} Limpiando reglas existentes..."
        iptables -F
        iptables -X
        iptables -t nat -F
        iptables -t nat -X
        iptables -t mangle -F
        iptables -t mangle -X
        echo -e "${GREEN}[✓]${NC} Reglas limpiadas"
        log "Reglas de iptables limpiadas"
    fi
    
    # NAT/Masquerading
    echo -e "\n${YELLOW}[*]${NC} Configurando NAT/Masquerading..."
    if iptables --table nat --append POSTROUTING --out-interface "$adaptador" -j MASQUERADE; then
        echo -e "${GREEN}[✓]${NC} NAT configurado en $adaptador"
        log "NAT configurado en $adaptador"
    else
        echo -e "${RED}[!]${NC} Error al configurar NAT"
        return 1
    fi
    
    # Protección contra SYN flood
    echo -e "${YELLOW}[*]${NC} Configurando protección contra SYN flood..."
    iptables -A INPUT -p tcp --syn -m limit --limit 5/s -j ACCEPT
    iptables -A INPUT -p tcp --syn -j DROP
    echo -e "${GREEN}[✓]${NC} Protección SYN flood configurada"
    log "Protección SYN flood configurada"
    
    # Protección contra escaneo de puertos
    echo -e "${YELLOW}[*]${NC} Configurando protección contra escaneo..."
    iptables -N SCANNER_PROTECTION 2>/dev/null || iptables -F SCANNER_PROTECTION
    iptables -A SCANNER_PROTECTION -p tcp --tcp-flags ALL NONE -j DROP
    iptables -A SCANNER_PROTECTION -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
    iptables -A SCANNER_PROTECTION -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
    iptables -A INPUT -j SCANNER_PROTECTION
    echo -e "${GREEN}[✓]${NC} Protección contra escaneo configurada"
    log "Protección contra escaneo configurada"
    
    # Permitir tráfico establecido
    echo -e "${YELLOW}[*]${NC} Permitiendo tráfico relacionado y establecido..."
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    echo -e "${GREEN}[✓]${NC} Tráfico establecido permitido"
    log "Tráfico RELATED,ESTABLISHED permitido"
    
    # Permitir loopback
    echo -e "${YELLOW}[*]${NC} Permitiendo tráfico loopback..."
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    echo -e "${GREEN}[✓]${NC} Loopback permitido"
    
    # ICMP (ping) - Opcional
    echo -e "\n${YELLOW}[?]${NC} ¿Deseas bloquear ping (ICMP)? [s/N]"
    read -r respuesta
    if [[ "$respuesta" =~ ^[Ss]$ ]]; then
        iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
        echo -e "${GREEN}[✓]${NC} Ping bloqueado"
        log "ICMP echo-request bloqueado"
    else
        iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
        echo -e "${GREEN}[✓]${NC} Ping permitido"
        log "ICMP echo-request permitido"
    fi
    
    # Mostrar resumen
    echo -e "\n${BOLD}Reglas de iptables configuradas:${NC}"
    iptables -L -n --line-numbers | head -30
    
    return 0
}

# Guardar reglas de iptables
guardar_iptables() {
    echo
    echo -e "${BOLD}=== GUARDANDO REGLAS DE IPTABLES ===${NC}"
    
    # Verificar si iptables-persistent está instalado
    if ! dpkg -l | grep -q iptables-persistent; then
        echo -e "${YELLOW}[*]${NC} Instalando iptables-persistent..."
        echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
        echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
        
        if apt-get install -y iptables-persistent >> "$LOG_FILE" 2>&1; then
            echo -e "${GREEN}[✓]${NC} iptables-persistent instalado"
            log "iptables-persistent instalado"
        else
            echo -e "${RED}[!]${NC} Error al instalar iptables-persistent"
            return 1
        fi
    fi
    
    # Guardar reglas
    echo -e "${YELLOW}[*]${NC} Guardando reglas..."
    if netfilter-persistent save; then
        echo -e "${GREEN}[✓]${NC} Reglas guardadas permanentemente"
        log "Reglas de iptables guardadas"
    else
        echo -e "${RED}[!]${NC} Error al guardar reglas"
        return 1
    fi
    
    return 0
}

# Instalar y configurar DNS (BIND9)
configurar_dns() {
    echo
    echo -e "${BOLD}=== CONFIGURANDO SERVIDOR DNS (BIND9) ===${NC}"
    log "Iniciando configuración de DNS"
    
    # Verificar si existen los archivos de configuración
    if [ ! -d "$DNS_DIR" ]; then
        echo -e "${RED}[!]${NC} No se encuentra el directorio '$DNS_DIR' con las configuraciones"
        echo -e "${YELLOW}[?]${NC} ¿Deseas continuar sin configurar DNS? [S/n]"
        read -r respuesta
        if [[ "$respuesta" =~ ^[Nn]$ ]]; then
            return 1
        fi
        return 0
    fi
    
    # Instalar BIND9
    if ! dpkg -l | grep -q "^ii.*bind9 "; then
        echo -e "${YELLOW}[*]${NC} Instalando BIND9..."
        if apt-get install -y bind9 bind9-utils bind9-doc >> "$LOG_FILE" 2>&1; then
            echo -e "${GREEN}[✓]${NC} BIND9 instalado"
            log "BIND9 instalado"
        else
            echo -e "${RED}[!]${NC} Error al instalar BIND9"
            return 1
        fi
    else
        echo -e "${GREEN}[✓]${NC} BIND9 ya está instalado"
    fi
    
    # Backup de configuraciones
    backup_archivo "/etc/bind/named.conf.options"
    backup_archivo "/etc/default/named"
    backup_archivo "/etc/bind/named.conf.local"
    
    # Copiar configuraciones
    echo -e "${YELLOW}[*]${NC} Copiando configuraciones DNS..."
    
    # Copiar configuraciones
    echo -e "${YELLOW}[*]${NC} Copiando configuraciones DNS..."
    
    if [ -f "$DNS_DIR/named.conf.options" ]; then
        cp "$DNS_DIR/named.conf.options" /etc/bind/
        echo -e "${GREEN}[✓]${NC} named.conf.options copiado"
    fi
    
    if [ -f "$DNS_DIR/named" ]; then
        cp "$DNS_DIR/named" /etc/default/
        echo -e "${GREEN}[✓]${NC} named copiado"
    fi
    
    if [ -f "$DNS_DIR/named.conf.local" ]; then
        cp "$DNS_DIR/named.conf.local" /etc/bind/
        echo -e "${GREEN}[✓]${NC} named.conf.local copiado"
    fi
    
    # Crear directorio de zonas
    mkdir -p /etc/bind/zonas
    
    if [ -f "$DNS_DIR/db.router.local" ]; then
        cp "$DNS_DIR/db.router.local" /etc/bind/zonas/
        echo -e "${GREEN}[✓]${NC} db.router.local copiado"
    fi
    
    if [ -f "$DNS_DIR/db.10.10.10" ]; then
        cp "$DNS_DIR/db.10.10.10" /etc/bind/zonas/
        echo -e "${GREEN}[✓]${NC} db.10.10.10 copiado"
    fi
    
    # Verificar configuración
    echo -e "${YELLOW}[*]${NC} Verificando configuración DNS..."
    if named-checkconf; then
        echo -e "${GREEN}[✓]${NC} Configuración DNS válida"
        log "Configuración DNS validada"
    else
        echo -e "${RED}[!]${NC} Error en la configuración DNS"
        log "ERROR: Configuración DNS inválida"
        return 1
    fi
    
    # Reiniciar servicio
    echo -e "${YELLOW}[*]${NC} Reiniciando BIND9..."
    if systemctl restart bind9; then
        echo -e "${GREEN}[✓]${NC} BIND9 reiniciado"
        log "BIND9 reiniciado exitosamente"
        
        if systemctl is-active --quiet bind9; then
            echo -e "${GREEN}[✓]${NC} BIND9 está activo"
        fi
    else
        echo -e "${RED}[!]${NC} Error al reiniciar BIND9"
        return 1
    fi
    
    return 0
}

# Instalar y configurar DHCP
configurar_dhcp() {
    echo
    echo -e "${BOLD}=== CONFIGURANDO SERVIDOR DHCP ===${NC}"
    log "Iniciando configuración de DHCP"
    
    # Verificar si existen los archivos de configuración
    if [ ! -d "$DHCP_DIR" ]; then
        echo -e "${RED}[!]${NC} No se encuentra el directorio '$DHCP_DIR' con las configuraciones"
        echo -e "${YELLOW}[?]${NC} ¿Deseas continuar sin configurar DHCP? [S/n]"
        read -r respuesta
        if [[ "$respuesta" =~ ^[Nn]$ ]]; then
            return 1
        fi
        return 0
    fi
    
    # Instalar ISC-DHCP-SERVER
    if ! dpkg -l | grep -q "^ii.*isc-dhcp-server"; then
        echo -e "${YELLOW}[*]${NC} Instalando ISC-DHCP-SERVER..."
        if apt-get install -y isc-dhcp-server >> "$LOG_FILE" 2>&1; then
            echo -e "${GREEN}[✓]${NC} ISC-DHCP-SERVER instalado"
            log "ISC-DHCP-SERVER instalado"
        else
            echo -e "${RED}[!]${NC} Error al instalar ISC-DHCP-SERVER"
            return 1
        fi
    else
        echo -e "${GREEN}[✓]${NC} ISC-DHCP-SERVER ya está instalado"
    fi
    
    # Backup de configuraciones
    backup_archivo "/etc/dhcp/dhcpd.conf"
    backup_archivo "/etc/default/isc-dhcp-server"
    
    # Copiar configuraciones
    echo -e "${YELLOW}[*]${NC} Copiando configuraciones DHCP..."
    
    # Copiar configuraciones
    echo -e "${YELLOW}[*]${NC} Copiando configuraciones DHCP..."
    
    if [ -f "$DHCP_DIR/dhcpd.conf" ]; then
        cp "$DHCP_DIR/dhcpd.conf" /etc/dhcp/
        echo -e "${GREEN}[✓]${NC} dhcpd.conf copiado"
    fi
    
    if [ -f "$DHCP_DIR/isc-dhcp-server" ]; then
        cp "$DHCP_DIR/isc-dhcp-server" /etc/default/
        echo -e "${GREEN}[✓]${NC} isc-dhcp-server copiado"
    fi
    
    # Verificar configuración
    echo -e "${YELLOW}[*]${NC} Verificando configuración DHCP..."
    if dhcpd -t -cf /etc/dhcp/dhcpd.conf 2>&1 | tee -a "$LOG_FILE"; then
        echo -e "${GREEN}[✓]${NC} Configuración DHCP válida"
        log "Configuración DHCP validada"
    else
        echo -e "${RED}[!]${NC} Error en la configuración DHCP"
        log "ERROR: Configuración DHCP inválida"
        return 1
    fi
    
    # Reiniciar servicio
    echo -e "${YELLOW}[*]${NC} Reiniciando ISC-DHCP-SERVER..."
    if systemctl restart isc-dhcp-server; then
        echo -e "${GREEN}[✓]${NC} ISC-DHCP-SERVER reiniciado"
        log "ISC-DHCP-SERVER reiniciado exitosamente"
        
        if systemctl is-active --quiet isc-dhcp-server; then
            echo -e "${GREEN}[✓]${NC} ISC-DHCP-SERVER está activo"
        fi
    else
        echo -e "${RED}[!]${NC} Error al reiniciar ISC-DHCP-SERVER"
        echo -e "${YELLOW}[!]${NC} Revisa los logs: systemctl status isc-dhcp-server"
        return 1
    fi
    
    return 0
}

# Mostrar estado del sistema
mostrar_estado() {
    echo
    echo -e "${BOLD}=== ESTADO DEL SISTEMA ===${NC}"
    
    # IP Forwarding
    local ipfwd=$(cat /proc/sys/net/ipv4/ip_forward)
    if [ "$ipfwd" = "1" ]; then
        echo -e "${GREEN}[✓]${NC} IP Forwarding: Habilitado"
    else
        echo -e "${RED}[✗]${NC} IP Forwarding: Deshabilitado"
    fi
    
    # Servicios
    echo -e "\n${BOLD}Servicios:${NC}"
    
    if systemctl is-active --quiet bind9 2>/dev/null; then
        echo -e "${GREEN}[✓]${NC} BIND9: Activo"
    else
        echo -e "${YELLOW}[-]${NC} BIND9: Inactivo"
    fi
    
    if systemctl is-active --quiet isc-dhcp-server 2>/dev/null; then
        echo -e "${GREEN}[✓]${NC} DHCP Server: Activo"
    else
        echo -e "${YELLOW}[-]${NC} DHCP Server: Inactivo"
    fi
    
    # Reglas de iptables
    echo -e "\n${BOLD}Reglas de iptables activas:${NC}"
    local reglas=$(iptables -L | grep -c "^Chain")
    echo -e "  Chains configuradas: $reglas"
    
    local nat=$(iptables -t nat -L POSTROUTING | grep -c MASQUERADE)
    if [ "$nat" -gt 0 ]; then
        echo -e "${GREEN}[✓]${NC} NAT/Masquerading: $nat regla(s)"
    else
        echo -e "${YELLOW}[-]${NC} NAT/Masquerading: No configurado"
    fi
}

# Menú principal
menu_principal() {
    while true; do
        mostrar_banner
        echo -e "${BOLD}=== CONFIGURACIÓN DE ROUTER LINUX ===${NC}"
        echo
        echo "[1] Configuración completa (automática)"
        echo "[2] Configurar IP Forwarding"
        echo "[3] Configurar Iptables/Firewall"
        echo "[4] Configurar DNS (BIND9)"
        echo "[5] Configurar DHCP Server"
        echo "[6] Ver estado del sistema"
        echo "[7] Ver logs"
        echo "[8] Salir"
        echo
        
        read -p "$(echo -e ${BOLD}[+] Seleccione una opción: ${NC})" opcion
        
        case $opcion in
            1)
                # Configuración completa
                local adaptador=$(obtener_adaptador_principal)
                if [ $? -eq 0 ]; then
                    listar_adaptadores
                    echo -e "\n${YELLOW}[?]${NC} ¿Usar adaptador $adaptador? [S/n]"
                    read -r respuesta
                    if [[ "$respuesta" =~ ^[Nn]$ ]]; then
                        read -p "$(echo -e ${BOLD}Ingresa el nombre del adaptador: ${NC})" adaptador
                    fi
                    
                    configurar_ip_forward && \
                    configurar_iptables "$adaptador" && \
                    guardar_iptables && \
                    configurar_dns && \
                    configurar_dhcp
                    
                    mostrar_estado
                fi
                read -p "$(echo -e \\n${BOLD}Presiona ENTER para continuar...${NC})"
                ;;
            2)
                configurar_ip_forward
                read -p "$(echo -e \\n${BOLD}Presiona ENTER para continuar...${NC})"
                ;;
            3)
                local adaptador=$(obtener_adaptador_principal)
                if [ $? -eq 0 ]; then
                    configurar_iptables "$adaptador"
                    guardar_iptables
                fi
                read -p "$(echo -e \\n${BOLD}Presiona ENTER para continuar...${NC})"
                ;;
            4)
                configurar_dns
                read -p "$(echo -e \\n${BOLD}Presiona ENTER para continuar...${NC})"
                ;;
            5)
                configurar_dhcp
                read -p "$(echo -e \\n${BOLD}Presiona ENTER para continuar...${NC})"
                ;;
            6)
                mostrar_estado
                read -p "$(echo -e \\n${BOLD}Presiona ENTER para continuar...${NC})"
                ;;
            7)
                if [ -f "$LOG_FILE" ]; then
                    echo
                    echo -e "${BOLD}=== ÚLTIMAS 30 LÍNEAS DEL LOG ===${NC}"
                    tail -n 30 "$LOG_FILE"
                else
                    echo -e "${YELLOW}[!]${NC} No hay archivo de log disponible"
                fi
                read -p "$(echo -e \\n${BOLD}Presiona ENTER para continuar...${NC})"
                ;;
            8)
                clear
                echo
                echo -e "${GREEN}[✓]${NC} ¡Gracias por usar Router Linux Setup!"
                echo
                log "Script finalizado"
                exit 0
                ;;
            *)
                echo -e "${RED}[!]${NC} Opción inválida"
                sleep 1
                ;;
        esac
    done
}

# Función principal
main() {
    verificar_root
    log "===== INICIO DE CONFIGURACIÓN DE ROUTER LINUX ====="
    menu_principal
}

# Ejecutar
main