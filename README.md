# Router Linux - Dispositivo de Infraestructura Empresarial

![Shell](https://img.shields.io/badge/Shell-Script-green?logo=gnubash&logoColor=white)
![GitLab](https://img.shields.io/badge/GitLab-Laboratorio-orange?logo=gitlab)
![GitHub](https://img.shields.io/badge/GitHub-Portafolio-blue?logo=github)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Status](https://img.shields.io/badge/Status-Estable-brightgreen)

## 📋 Visión del Proyecto

**Router Linux** es un proyecto de nivel avanzado de Infraestructura como Código (IaC) diseñado para transformar distribuciones Linux estándar en routers y firewalls de alto rendimiento y endurecidos. Este proyecto encapsula primitivas de red avanzadas, incluyendo inspección de paquetes con estado **Netfilter/Iptables**, DNS recursivo/autoritativo **BIND9** y direccionamiento automatizado **ISC-DHCP**.

Este repositorio implementa una **Arquitectura Dual DevSecOps**:

- **GitLab (Laboratorio Público):** Contiene todos los archivos del proyecto como entorno completo de desarrollo y experimentación.

- **GitHub (Portafolio Profesional):** Versión optimizada y documentada para exhibición profesional y colaboraciones.

---

## 🏗️ Arquitectura del Repositorio

El proyecto sigue una estructura modular y escalable alineada con las mejores prácticas de DevSecOps:

```text
Router-Linux/
├── src/                # Lógica central de automatización (setup.sh)
├── docs/               # Documentación técnica avanzada
├── diagrams/           # Topologías de red y esquemas lógicos
├── configs/            # Plantillas de configuración de servicios (DHCP, DNS)
├── scripts/            # Herramientas de mantenimiento y DevSecOps
├── tests/              # Scripts de validación y auditoría de seguridad
├── .gitlab-ci.yml      # Pipeline CI/CD multi-etapa
└── README.md           # Documentación principal
```

### Aislamiento Estratégico de Componentes

El repositorio de GitLab contiene todos los componentes funcionales para un entorno de desarrollo completo, mientras que la versión de GitHub se enfoca en la documentación y exhibición arquitectónica.

---

## 🛡️ Flujo DevSecOps: GitLab ➔ GitHub

Este proyecto utiliza un pipeline de sincronización para mantener la coherencia entre el laboratorio completo y el portafolio profesional.

### Flujo de Publicación Automatizado

1. **Desarrollo y Verificación:** Todos los cambios se realizan en la rama `main` de GitLab.
2. **Integración Continua:** Un pipeline multi-etapa (`lint` -> `security` -> `test`) valida cada commit.
3. **Sincronización:** El contenido optimizado se publica automáticamente en GitHub.
4. **Mantenimiento:** La versión de GitHub se mantiene como portafolio profesional actualizado.

> [!NOTE]
> Esta estrategia asegura que el portafolio público permanezca enfocado en la arquitectura y documentación, mientras que el laboratorio mantiene todas las capacidades funcionales.

---

## 🚀 Características Principales

*   **Aprovisionamiento Automatizado:** Configuración idempotente mediante `src/setup.sh`.
*   **Filtrado de Paquetes y Endurecimiento:**
    *   Conjunto de reglas de Inspección de Paquetes con Estado (SPI).
    *   Endurecimiento contra inundaciones TCP SYN y escaneos de puertos sigilosos.
    *   NAT/Mascareado sofisticado para segmentos internos.
*   **Servicios de Infraestructura:**
    *   **DNS:** Resolución local y caché con BIND9.
    *   **DHCP:** Gestión dinámica de leases para aislamiento LAN (10.10.10.0/24).

---

## 🧪 Validación y Ética

### Estándares Profesionales
Todo el código sigue estándares estrictos de scripting en shell (compatible con ShellCheck) y mantiene una clara separación entre lógica y datos.

### Descargo de Responsabilidad Ético
Este proyecto está destinado a investigación educativa y de redes profesionales. Las configuraciones de firewall proporcionadas son estrictas; el uso inadecuado en entornos de producción sin acceso adecuado a la consola podría resultar en bloqueo propio.
