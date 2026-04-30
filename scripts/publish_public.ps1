# =============================================================================
# scripts/publish_public.ps1 - VERSIÓN DEFINITIVA (SENIOR)
# Sincronización Segura: GitLab (Completo) -> GitHub (Sanitizado)
# =============================================================================

Write-Host "[*] Iniciando sincronización profesional de Router-Linux..." -ForegroundColor Cyan

# 1. Validaciones Iniciales (Pre-vuelo)
$currentBranch = git rev-parse --abbrev-ref HEAD
if ($currentBranch -ne "main") {
    Write-Host "[!] Error: Debes estar en 'main' para publicar." -ForegroundColor Red
    exit
}

if (git status --porcelain) {
    Write-Host "[!] Tienes cambios sin guardar. Haz commit antes de publicar." -ForegroundColor Yellow
    exit
}

# 2. Limpieza Local Previa (Evitar basura en el commit)
Write-Host "[*] Limpiando archivos temporales y logs..." -ForegroundColor Yellow
Remove-Item -Path "*.log", "*.rules", "iptables_backup_*" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "tmp/*" -Recurse -Force -ErrorAction SilentlyContinue

# 3. Sincronización con Laboratorio Privado (GitLab)
Write-Host "[*] Asegurando estado en el Laboratorio (lab)..." -ForegroundColor Cyan
git pull lab main --rebase
git push lab main

# 4. Estrategia de Rama Pública (Aislamiento de Seguridad)
Write-Host "[*] Creando release sanitizado en rama 'public'..."
git checkout -B public main

# 5. Filtrado de Archivos (Lo que NO va al Portafolio - DevSecOps Sanitization)
Write-Host "[*] Aplicando filtros de seguridad DevSecOps..." -ForegroundColor Cyan

# Justificación: Eliminamos lo que es exclusivo del laboratorio privado o sensible
# - tests/: Validaciones internas y scripts de ataque/test.
# - configs/: Configuraciones reales de infraestructura.
# - scripts/: Herramientas de automatización privada (incluye este script).
# - .gitlab-ci.yml: Lógica de CI interna.

git rm -r --cached tests/ -f 2>$null
git rm -r --cached configs/ -f 2>$null
git rm -r --cached scripts/ -f 2>$null
git rm --cached .gitlab-ci.yml -f 2>$null

# 6. Commit de Lanzamiento y Push al Portafolio (GitHub)
git commit -m "docs: release update to public portfolio (sanitized)" --allow-empty
Write-Host "[*] Subiendo al Portafolio (GitHub)..." -ForegroundColor Green
git push origin public:main --force

# 7. Retorno Seguro al Entorno de Trabajo (Lab)
Write-Host "[*] Volviendo al Laboratorio (lab/main)..."
git checkout main -f
git clean -fd 2>$null

Write-Host "[*] Portafolio (portfolio) actualizado y Laboratorio (lab) protegido" -ForegroundColor Green