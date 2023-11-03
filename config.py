import os
import subprocess



print("\033[34m__________               __                 .____    .__                      \033[0m") 
print("\033[34m\______   \ ____  __ ___/  |_  ___________  |    |   |__| ____  __ _____  ___ \033[0m")
print("\033[34m |       _//  _ \|  |  \   __\/ __ \_  __ \ |    |   |  |/    \|  |  \  \/  / \033[0m")
print("\033[34m |    |   (  <_> )  |  /|  | \  ___/|  | \/ |    |___|  |   |  \  |  />    <  \033[0m")
print("\033[34m |____|_  /\____/|____/ |__|  \___  >__|    |_______ \__|___|  /____//__/\_ \ \033[0m")
print("\033[34m        \/                        \/                \/       \/            \/ \033[0m")



def obtener_adaptador_principal():
    try:
        # Ejecutar el comando 'ip route' y capturar la salida
        resultado = subprocess.check_output(["ip", "route"]).decode("utf-8")

        # Dividir la salida en líneas
        lineas = resultado.split('\n')

        # Buscar la línea que contiene "default via" para encontrar el adaptador principal
        for linea in lineas:
            if "default via" in linea:
                partes = linea.split()
                adaptador = partes[4]
                return adaptador

        # Si no se encontró la línea con "default via", informar que no se pudo determinar
        return "No se pudo determinar el adaptador principal"

    except Exception as e:
        return f"Error al obtener el adaptador principal: {str(e)}"

if __name__ == "__main__":
    adaptador = obtener_adaptador_principal()
    print(f"\n[+] El adaptador principal conectado a Internet es: {adaptador}")

os.system("echo 1 > /proc/sys/net/ipv4/ip_forward\n")
os.system("sysctl -p /etc/sysctl.conf")
os.system("iptables -L")
os.system("iptables -L -nv -t nat")
os.system(f"iptables --table nat --append POSTROUTING --out-interface {adaptador} -j MASQUERADE")
os.system("apt-get install iptables-persistent")
os.system("netfilter-persistent save")
# Protección contra ataques SYN flood
os.system("iptables -A INPUT -p tcp --syn -m limit -- 5/s -j ACCEPT")
os.system("iptables -A INPUT -p tcp --syn -j DROP")
# Evitar escaneo de puertos
os.system("iptables -N SCANNER_PROTECTION")
os.system("iptables -A SCANNER_PROTECTION -p tcp --tcp-flags ALL NONE -j DROP")
os.system("iptables -A SCANNER_PROTECTION -p tcp --tcp-flags SYN,FIN -j DROP")
# Permitir el tráfico relacionado y establecido
os.system("iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT")
os.system("iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT")
# Permitir el tráfico de loopback (comunicación interna)
os.system("iptables -A INPUT -i lo -j ACCEPT")
os.system("iptables -A OUTPUT -o lo -j ACCEPT")
# Bloquear el tráfico no deseado
os.system("iptables -A INPUT -p icmp --icmp-type echo-request -j DROP")

# Instalar bind9 y bind9-utils
os.system("sudo apt install bind9 bind9-utils -y")

# Configuraciones del servidor DNS
os.system("sudo rm -r /etc/bind/named.conf.options")
os.system("sudo cp /DNS/named.conf.options /etc/bind/")
os.system("sudo rm -r /etc/default/named")
os.system("sudo cp /DNS/named /etc/default/")
os.system("sudo systemctl restart bind9")
os.system("sudo rm -r /etc/bind/named.conf.local")
os.system("sudo cp /DNS/named.conf.local /etc/bind/")
os.system("sudo mkdir /etc/bind/zonas")
os.system("sudo cp /DNS/db.router.local /etc/bind/zonas/")
os.system("sudo cp /DNS/db.10.10.10 /etc/bind/zonas/")
os.system("sudo systemctl restart bind9")

# Configuraciones del servidor DHCP
os.system("sudo apt-get install isc-dhcp-server")
os.system("sudo rm -r /etc/dhcp/dhcpd.conf")
os.system("sudo cp /DHCP/dhcpd.conf /etc/dhcp/")
os.system("sudo rm -r /etc/default/isc-dhcp-server")
os.system("sudo cp /DHCP/isc-dhcp-server /etc/default/")
os.system("sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf")
os.system("sudo service isc-dhcp-server restart")
