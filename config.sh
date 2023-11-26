#!/bin/bash


echo -e "\033[34m __________               __                 .____    .__                      \033[0m"
echo -e "\033[34m \______   \ ____  __ ___/  |_  ___________  |    |   |__| ____  __ _____  ___ \033[0m"
echo -e "\033[34m  |       _//  _ \|  |  \   __\/ __ \_  __ \ |    |   |  |/    \|  |  \  \/  / \033[0m"
echo -e "\033[34m  |    |   (  <_> )  |  /|  | \  ___/|  | \/ |    |___|  |   |  \  |  />    <  \033[0m"
echo -e "\033[34m  |____|_  /\____/|____/ |__|  \___  >__|    |_______ \__|___|  /____//__/\_ \ \033[0m"
echo -e "\033[34m        \/                        \/                \/       \/            \/  \033[0m"


function obtener_adaptador_principal() {
    # Ejecutar el comando 'ip route' y capturar la salida
    resultado=$(ip route)

    # Dividir la salida en líneas
    IFS=$'\n' read -ra lineas <<< "$resultado"

    # Buscar la línea que contiene "default via" para encontrar el adaptador principal
    for linea in "${lineas[@]}"; do
        if [[ "$linea" == *"default via"* ]]; then
            partes=($linea)
            adaptador=${partes[4]}
            echo $adaptador
            return
        fi
    done

    # Si no se encontró la línea con "default via", informar que no se puede determinar
    echo "No se puede determinar el adaptador principal"
    exit 1
}

# Obtener el adaptador principal
adaptador=$(obtener_adaptador_principal)
echo -e "\n[+] El adaptador principal conectado a Internet es: $adaptador"

# Configuraciones de iptables
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -p /etc/sysctl.conf
iptables -L
iptables -L -nv -t nat
iptables --table nat --append POSTROUTING --out-interface $adaptador -j MASQUERADE
apt-get install iptables-persistent
netfilter-persistent save
# Protección contra ataques SYN flood
iptables -A INPUT -p tcp --syn -m limit -- 5/s -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP
# Evitar escaneo de puertos
iptables -N SCANNER_PROTECTION
iptables -A SCANNER_PROTECTION -p tcp --tcp-flags ALL NONE -j DROP
iptables -A SCANNER_PROTECTION -p tcp --tcp-flags SYN,FIN -j DROP
# Permitir el tráfico relacionado y establecido
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
# Permitir el tráfico de loopback (comunicación interna)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# Bloquear el tráfico no deseado
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# Instalar bind9 y bind9-utils
apt install bind9 bind9-utils -y

# Configuraciones del servidor DNS
rm -r /etc/bind/named.conf.options
cp /DNS/named.conf.options /etc/bind/
rm -r /etc/default/named
cp /DNS/named /etc/default/
systemctl restart bind9
rm -r /etc/bind/named.conf.local
cp /DNS/named.conf.local /etc/bind/
mkdir /etc/bind/zonas
cp /DNS/db.router.local /etc/bind/zonas/
cp /DNS/db.10.10.10 /etc/bind/zonas/
systemctl restart bind9

# Configuraciones del servidor DHCP
apt-get install isc-dhcp-server
rm -r /etc/dhcp/dhcpd.conf
cp /DHCP/dhcpd.conf /etc/dhcp/
rm -r /etc/default/isc-dhcp-server
cp /DHCP/isc-dhcp-server /etc/default/
dhcpd -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart

