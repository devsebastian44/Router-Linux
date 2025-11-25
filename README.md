## Router Linux

<p align="center">
  <img src="./Img/Logo.png" height="300px" width="350px">
</p>

Un **router Linux** es un enrutador de red que utiliza una distribución de Linux como base para su sistema operativo.  
Este proyecto te permite configurar **Ubuntu Server 20.04** como un router funcional, con múltiples servicios de red integrados.

---

## 🧠 ¿Qué puede hacer un router Linux?

Ubuntu Server puede cumplir varias funciones como router, dependiendo de tu configuración:

- **Enrutamiento:** Dirige el tráfico entre redes o subredes usando `iptables` o `nftables`.
- **Firewall:** Protege tu red con reglas de filtrado de paquetes.
- **NAT (Network Address Translation):** Permite que múltiples dispositivos compartan una IP pública.
- **Proxy:** Actúa como intermediario entre tu red interna e Internet.
- **VPN:** Permite conexiones seguras desde dispositivos remotos.
- **Balanceo de carga:** Distribuye tráfico entre múltiples conexiones o servidores.
- **Monitoreo de tráfico:** Usa herramientas como `Wireshark` o `tcpdump`.
- **QoS (Quality of Service):** Prioriza tipos de tráfico para garantizar rendimiento óptimo.

<p align="center">
  <img src="./Img/Topologia.png">
</p>

---

## ⚙️ Requisitos

- Ubuntu Server 20.04
- Dos interfaces de red (ej. `enp0s3` y `enp0s8`)
- Conexión a Internet
- Permisos de administrador (`sudo`)

---

## 🛠️ Configuración manual

Edita el archivo de red:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Ejemplo de configuración:

```yaml
network:
  ethernets:
    enp0s3:
      addresses: [192.168.1.2/24]
      gateway4: 192.168.1.1
    enp0s8:
      addresses: [10.10.10.1/24]
      nameservers:
        addresses: [10.10.10.1]
  version: 2
```

Configura el archivo del servicio DHCP:

```bash
sudo nano /etc/default/isc-dhcp-server
```

Y define la interfaz:

```text
INTERFACESv4="enp0s8"
```

---

## 🚀 Instalación automática

Clona el repositorio y ejecuta el script:

```bash
git clone https://github.com/Devsebastian31/Router-Linux.git
cd Router-Linux
sudo chmod +x config.sh
sudo bash config.sh
```

---

## 📂 Estructura del proyecto

```
Router-Linux/
│── config.sh                  # Script principal de configuración automática
│── DHCP/                      # Archivos de configuración del servidor DHCP
│   │── dhcpd.conf             # Reglas de asignación de IPs
│   │── isc-dhcp-server        # Interfaz configurada para el servicio DHCP
│── DNS/                       # Archivos de configuración del servidor DNS (Bind9)
│   │── db.10.10.10            # Zona inversa para red interna
│   │── db.router.local        # Zona directa para dominio local
│   │── named                  # Archivo base de configuración
│   │── named.conf.local       # Definición de zonas locales
│   │── named.conf.options     # Opciones generales del servidor DNS
|   |── resolv.conf            # Configuración de resolución DNS
```

---

## 📜 Licencia

Este proyecto está bajo la licencia MIT.  
Puedes usarlo libremente con fines educativos y de investigación.