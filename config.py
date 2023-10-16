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