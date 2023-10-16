import os
import subprocess

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
    print(f"[+] El adaptador principal conectado a Internet es: {adaptador}")

os.system("echo 1 > /proc/sys/net/ipv4/ip_forward\n")
os.system("sysctl -p /etc/sysctl.conf")
os.system("iptables -L")
os.system("iptables -L -nv -t nat")
os.system(f"iptables --table nat --append POSTROUTING --out-interface {adaptador} -j MASQUERADE")
os.system("apt-geet install iptables-persistent")
os.system("netfilter-persistent save")