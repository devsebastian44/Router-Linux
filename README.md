# Router Linux - Enterprise Infrastructure Appliance

![Shell](https://img.shields.io/badge/Shell-Script-green?logo=gnubash&logoColor=white)
![GitLab](https://img.shields.io/badge/GitLab-Repository-orange?logo=gitlab)
![GitHub](https://img.shields.io/badge/GitHub-Portfolio-blue?logo=github)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen)

## 📋 Technical Overview

**Router Linux** is a senior-level Infrastructure as Code (IaC) project designed to transform standard Linux distributions into high-performance, hardened network routers and firewalls. This project encapsulates advanced networking primitives, including **Netfilter/Iptables** stateful packet inspection, **BIND9** recursive/authoritative DNS, and **ISC-DHCP** automated addressing.

This repository implements a **DevSecOps Dual-Tier Architecture**:
- **GitLab (Private Laboratory):** The "Source of Truth" containing full logic, automated testing pipelines, and internal configurations.
- **GitHub (Public Portfolio):** A sanitized, documentation-centric version for professional exhibition.

---

## 🏗️ Repository Architecture

The project follows a modular and scalable structure aligned with DevSecOps best practices:

```text
Router-Linux/
├── src/                # Core automation logic (setup.sh)
├── docs/               # Advanced technical documentation
├── diagrams/           # Network topologies and logical schemas
├── configs/            # [PRIVATE] Service configuration templates (DHCP, DNS)
├── scripts/            # [PRIVATE] Maintenance & DevSecOps tools (publish_public.ps1)
├── tests/              # [PRIVATE] Validation & Security audit scripts
├── .gitlab-ci.yml      # [PRIVATE] Multi-stage CI/CD Pipeline
└── README.md           # Master documentation
```

### Strategic Component Isolation

Folders marked as `[PRIVATE]` are strictly reserved for the GitLab environment to protect internal infrastructure logic and sensitive configuration patterns.

---

## 🛡️ DevSecOps Flow: GitLab ➔ GitHub

This project utilizes a customized sanitization pipeline to maintain the integrity of the public portfolio while preserving the full capabilities of the private lab.

### Automated Publishing Workflow

1. **Development & Verification:** All changes are committed to the `main` branch in GitLab.
2. **Continuous Integration:** A multi-stage pipeline (`lint` -> `security` -> `test`) validates every commit.
3. **Execution of `publish_public.ps1`:** 
   - A dedicated PowerShell script automates the transition.
   - **Sanitization:** Removes all sensitive components (`tests/`, `configs/`, private `scripts/`, CI logic).
   - **Tagging:** Prepares a sanitized `public` branch.
4. **Synchronized Push:** Forces the sanitized state to the GitHub `main` branch.

> [!NOTE]
> This strategy ensures that the public version remains high-level and focused on architecture, while the private version remains fully functional and secure.

---

## 🚀 Key Features

*   **Automated Provisioning:** Idempotent setup via `src/setup.sh`.
*   **Packet Filtering & Hardening:**
    *   Stateful Packet Inspection (SPI) ruleset.
    *   Hardening against TCP SYN floods and stealth port scans.
    *   Sophisticated NAT/Masquerading for internal segments.
*   **Infrastructure Services:**
    *   **DNS:** Local resolution and caching with BIND9.
    *   **DHCP:** Dynamic lease management for LAN isolation (10.10.10.0/24).

---

## 🧪 Validation & Ethics

### Professional Standards
All code follows strict shell-scripting standards (ShellCheck compliant) and maintains a clear separation between logic and data.

### Ethical Disclaimer
This project is intended for educational and professional networking research. The firewall configurations provided are strict; improper use in production environments without proper console access could result in self-lockout.

---

## ⚖️ License

Distributed under the MIT License. See `LICENSE` for more information.
