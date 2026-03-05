# Router Linux - Proyecto de Appliance de Red

![Shell](https://img.shields.io/badge/Shell-Script-green?logo=gnubash&logoColor=white)
![GitLab](https://img.shields.io/badge/GitLab-Repository-orange?logo=gitlab)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen)

## 📋 Descripción General

**Router Linux** es un proyecto profesional de infraestructura como código (IaC) diseñado para transformar un servidor Ubuntu estándar en un enrutador de red, firewall y puerta de enlace de alto rendimiento. Este proyecto demuestra capacidades avanzadas de redes en Linux, incluyendo la gestión de **Netfilter/Iptables**, servicios DNS **BIND9** y despliegue de servidor **ISC-DHCP**.

Este repositorio sirve tanto como un **portafolio público** demostrando habilidades en DevSecOps e Ingeniería de Redes, como un entorno de **laboratorio privado** para probar configuraciones de seguridad de red.

---

## 🏗️ Arquitectura

El proyecto está estructurado para diferenciar entre gestión de configuración, código fuente y documentación:

```
Router-Linux/
├── src/                # Scripts principales de automatización (setup.sh)
├── configs/            # Plantillas de configuración
│   ├── dhcp/           # Configuraciones de ISC-DHCP-Server
│   └── dns/            # Archivos de Zona y Opciones de BIND9
├── diagrams/           # Topologías de red y esquemas
├── tests/              # Scripts de validación
├── .gitlab-ci.yml      # Definición de Pipeline CI/CD
└── README.md           # Documentación del proyecto
```

### Topología de Red

El sistema está diseñado para operar con una arquitectura de red de doble interfaz:
- **Interfaz WAN:** Conecta al ISP/Red Externa.
- **Interfaz LAN:** Sirve a los clientes internos (10.10.10.0/24).

*(Ver `diagrams/topology.png` para una representación visual)*

---

## 🚀 Características

- **Aprovisionamiento Automatizado:** `src/setup.sh` automatiza todo el proceso de instalación.
- **Fortalecimiento del Firewall:**
  - Inspección de estado de paquetes (SPI).
  - Protección contra inundaciones SYN y escaneo de puertos.
  - Enmascaramiento (NAT) para compartir internet.
- **Servicios DNS:** Resolución DNS local con BIND9, soportando zonas internas.
- **Servicios DHCP:** Asignación dinámica de IP para el segmento LAN.

---

## 🛠️ Uso

### Pre-requisitos

- Ubuntu Server 20.04 LTS (o SO compatible basado en Debian).
- Privilegios de root (`sudo`).
- Dos interfaces de red.

## 🚀 Instalación y Acceso

> [!IMPORTANT]
> El repositorio completo con todo el código funcional está disponible en **GitLab** para acceso completo.

https://gitlab.com/group-programming-lab/Router-Linux

### Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/Devsebastian31/Router-Linux.git
   cd Router-Linux
   ```

2. **Ejecutar el script de configuración:**
   ```bash
   sudo bash src/setup.sh
   ```

3. **Seguir el asistente interactivo:**
   - Seleccionar tus interfaces WAN/LAN.
   - Confirmar pasos de configuración.

---

## 🧪 Pruebas y Validación

### Pruebas Automatizadas

Este proyecto usa **GitLab CI/CD** para validar la sintaxis e integridad de la configuración.
Para ejecutar pruebas localmente:
```bash
bash tests/syntax_check.sh
```

### Verificación Manual

- **Verificar Estado:** Usar opción `[6]` en el menú para verificar estado de servicios.
- **Logs:** Logs de instalación disponibles en `router_setup.log`.

---

## ⚠️ Advertencia de Seguridad

Este proyecto incluye configuraciones de firewall que modifican deliberadamente el flujo de tráfico de red. 
- **No ejecutar en un servidor de producción** sin entender las implicaciones.
- Las reglas de `iptables` son estrictas; asegurar acceso físico a consola o IP de gestión fuera de banda para evitar bloqueos vía SSH.
