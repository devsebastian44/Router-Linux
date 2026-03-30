# Router Linux

![Ubuntu](https://img.shields.io/badge/Ubuntu_Server-20.04-E95420?style=flat&logo=ubuntu&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat&logo=gnubash&logoColor=white)
![iptables](https://img.shields.io/badge/Firewall-iptables-003366?style=flat&logo=linux&logoColor=white)
![BIND9](https://img.shields.io/badge/DNS-BIND9-0078D4?style=flat&logo=cloudflare&logoColor=white)
![DHCP](https://img.shields.io/badge/DHCP-isc--dhcp--server-FF6600?style=flat&logo=icloud&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-brightgreen?style=flat)


## 🧠 Overview

Este proyecto convierte una máquina con **Ubuntu Server 20.04** en un **router Linux completamente funcional** mediante un script de automatización en Bash y un conjunto de archivos de configuración de servicios de red. A partir del análisis del código y la estructura del repositorio, el sistema implementa enrutamiento de paquetes entre dos interfaces de red (`enp0s3` — WAN e `enp0s8` — LAN), habilitando NAT (Network Address Translation) con `iptables` para que los clientes de la red interna accedan a Internet a través de una sola IP pública.

El proyecto está orientado a entornos educativos, laboratorios de redes y administración de sistemas donde se requiere una solución de enrutamiento personalizable sobre hardware genérico, sin depender de dispositivos de red propietarios.

---

## ⚙️ Features

- **Enrutamiento IP con NAT** — Activa el IP forwarding en el kernel y configura reglas MASQUERADE en `iptables` para enrutar tráfico desde la red interna hacia Internet.
- **Servidor DHCP (isc-dhcp-server)** — Asigna automáticamente direcciones IP, máscara de subred, gateway y DNS a los clientes conectados a la interfaz LAN (`enp0s8`), configurado desde `dhcpd.conf`.
- **Servidor DNS local (BIND9)** — Resuelve nombres de dominio internos mediante zonas directa (`db.router.local`) e inversa (`db.10.10.10`), con opciones globales definidas en `named.conf.options` y zonas locales en `named.conf.local`.
- **Configuración de red con Netplan** — Define IPs estáticas para ambas interfaces mediante el formato YAML de Netplan (`/etc/netplan/`).
- **Automatización completa** — El script `config.sh` orquesta la instalación de paquetes, copia de archivos de configuración, activación de servicios y aplicación de reglas de firewall sin intervención manual.
- **Topología de red definida** — La red interna opera en el segmento `10.10.10.0/24`, con el router actuando como gateway en `10.10.10.1`.

---

## 🛠️ Tech Stack

| Componente | Tecnología |
|---|---|
| Sistema Operativo | Ubuntu Server 20.04 LTS |
| Lenguaje de scripting | Bash / Shell |
| Firewall y NAT | iptables / iptables-persistent |
| Servidor DHCP | isc-dhcp-server |
| Servidor DNS | BIND9 (named) |
| Configuración de red | Netplan (YAML) |
| Control de versiones | Git |

---

## 📦 Installation

### Requisitos previos

- Ubuntu Server 20.04 instalado
- Dos interfaces de red activas (ej. `enp0s3` para WAN y `enp0s8` para LAN)
- Conexión a Internet en la interfaz WAN
- Privilegios de superusuario (`sudo`)

### Instalación automática

```bash
# 1. Clonar el repositorio
git clone https://github.com/devsebastian44/Router-Linux.git
cd Router-Linux

# 2. Dar permisos de ejecución al script principal
sudo chmod +x config.sh

# 3. Ejecutar el script de configuración automática
sudo bash config.sh
```

> ⚠️ El script instalará paquetes, copiará archivos de configuración a rutas del sistema y activará servicios. Ejecutar únicamente en entornos dedicados o máquinas virtuales.

### Configuración manual de red (Netplan)

Si se requiere ajustar las IPs antes de ejecutar el script:

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

Aplicar cambios:

```bash
sudo netplan apply
```

---

## ▶️ Usage

Una vez ejecutado `config.sh`, el sistema queda operativo como router. Para verificar el estado de los servicios:

```bash
# Verificar estado del servidor DHCP
sudo systemctl status isc-dhcp-server

# Verificar estado del servidor DNS (BIND9)
sudo systemctl status named

# Ver reglas de iptables activas
sudo iptables -t nat -L -v --line-numbers

# Comprobar forwarding de IP activo
cat /proc/sys/net/ipv4/ip_forward
# Debe retornar: 1

# Ver leases DHCP asignados
cat /var/lib/dhcp/dhcpd.leases
```

Para que los clientes de la LAN obtengan conectividad, deben apuntar su gateway a `10.10.10.1` (automáticamente si reciben IP por DHCP).

---

## 📁 Project Structure

```
Router-Linux/
│
├── config.sh                  # Script principal de automatización:
│                              # instala paquetes, copia configs,
│                              # activa NAT y servicios de red
│
├── DHCP/
│   ├── dhcpd.conf             # Define pool de IPs, gateway y DNS
│   │                          # para la red interna 10.10.10.0/24
│   └── isc-dhcp-server        # Especifica la interfaz de escucha
│                              # del daemon DHCP (enp0s8)
│
├── DNS/
│   ├── db.10.10.10            # Zona inversa: resuelve IPs → nombres
│   │                          # para el segmento 10.10.10.x
│   ├── db.router.local        # Zona directa: resuelve nombres → IPs
│   │                          # para el dominio router.local
│   ├── named                  # Archivo de arranque del servicio BIND9
│   ├── named.conf.local       # Declaración de zonas DNS locales
│   ├── named.conf.options     # Opciones globales: forwarders,
│   │                          # allow-query, recursión
│   └── resolv.conf            # Configuración de resolución DNS
│                              # del propio router
│
├── Img/
│   ├── Logo.png               # Logo del proyecto
│   └── Topologia.png          # Diagrama de topología de red
│
├── LICENSE                    # Licencia MIT
└── README.md                  # Documentación del repositorio
```

---

## 🔐 Security

Este proyecto implementa componentes sensibles de infraestructura de red. Se recomienda tener en cuenta las siguientes consideraciones:

- **Reglas de iptables**: El script activa NAT con `MASQUERADE`. Para entornos productivos, se recomienda añadir reglas de filtrado en la cadena `FORWARD` para controlar qué tráfico puede pasar entre segmentos.
- **Servidor DHCP expuesto**: `isc-dhcp-server` escucha únicamente en la interfaz LAN (`enp0s8`). No debe exponerse en la interfaz WAN para evitar asignaciones no autorizadas.
- **BIND9 y recursión DNS**: Verificar que `named.conf.options` restrinja `allow-query` y `allow-recursion` únicamente a la red interna (`10.10.10.0/24`), evitando convertir el servidor en un open resolver.
- **iptables-persistent**: Las reglas de firewall deben persistirse correctamente para sobrevivir reinicios del sistema.
- **Uso responsable**: Este proyecto está diseñado para **entornos educativos, laboratorios y redes controladas**. El despliegue en redes de producción requiere un análisis de seguridad adicional y el endurecimiento de cada servicio.

> ⚠️ No ejecutar este script en servidores en producción sin revisar y adaptar previamente cada archivo de configuración a la topología específica de la red.

---

## 🌐 Repository Architecture

Este proyecto sigue una arquitectura distribuida:

- **GitHub**: Documentación pública, presentación del proyecto y referencia rápida
- **GitLab**: Implementación completa, laboratorio de configuración y archivos de entorno de pruebas

### 🔗 Full Source Code

👉 Código completo disponible en GitLab: [https://gitlab.com/group-programming-lab/Router-Linux](https://gitlab.com/group-programming-lab/Router-Linux)

---

## 🚀 Roadmap

Posibles mejoras identificadas a partir del análisis del código y la estructura actual:

- [ ] **Soporte IPv6** — Ampliar las zonas DNS y reglas de `iptables` para manejar tráfico IPv6 (ip6tables).
- [ ] **Script de desinstalación** — Añadir un `uninstall.sh` que revierta los cambios del sistema de forma segura.
- [ ] **Validación de interfaces** — Agregar detección automática de interfaces de red en `config.sh` en lugar de nombres hardcodeados.
- [ ] **Firewall avanzado** — Implementar reglas de filtrado de paquetes en la cadena `FORWARD` con políticas de denegación por defecto.
- [ ] **Monitoreo de tráfico** — Integrar herramientas como `vnstat` o `iftop` para visibilidad del uso de red.
- [ ] **Soporte para múltiples subredes** — Extender la configuración DHCP y DNS para gestionar más de un segmento de red interno.
- [ ] **Variables de configuración centralizadas** — Crear un archivo `.env` o de configuración que centralice IPs, nombres de interfaz y rangos DHCP.

---

## 📄 License

Este proyecto está bajo la licencia **MIT**.

```
MIT License — Copyright (c) devsebastian44
Se permite el uso, copia, modificación y distribución con fines educativos y de investigación.
```

---

## 👨‍💻 Author

**Sebastian**
[GitHub: @devsebastian44](https://github.com/devsebastian44)

> Proyecto desarrollado con fines educativos para la configuración de infraestructura de red en Ubuntu Server 20.04..