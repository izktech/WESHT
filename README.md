# 🛡️ WESHT — Windows Enterprise Security Hardening Toolkit

**Framework en PowerShell para automatizar la remediación de hallazgos de cumplimiento CIS en Windows**, a partir de reportes de auditoría (por ejemplo, de Wazuh SCA). Diseñado como pieza de portafolio para demostrar fundamentos de *blue team* / hardening: mapeo de controles CIS, motor de remediación extensible, logging, generación de reportes HTML y buenas prácticas de PowerShell.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-En%20desarrollo%20activo-yellow)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)

---

## 📋 ¿Qué hace?

1. **Importa** un reporte de cumplimiento en CSV (pensado para la salida de Wazuh SCA, pero funciona con cualquier CSV que tenga una columna de estado tipo `Status`/`Result`).
2. **Clasifica** cada control en `PASSED`, `FAILED`, `WARNING` o `NOT APPLICABLE`, y calcula un porcentaje de cumplimiento.
3. **Mapea** cada control fallido (por su ID, ej. `1.1.1`) contra un catálogo de remediaciones definido en `Config/CISMappings.json`.
4. **Ejecuta automáticamente** la función de remediación correspondiente (por ejemplo, forzar longitud mínima de contraseña, activar el firewall de dominio, activar la protección en la nube de Defender).
5. **Genera un reporte HTML** con el resumen de la ejecución (controles procesados, exitosos, fallidos) para dejar evidencia de la auditoría/remediación.
6. Todo queda registrado en un **log diario** (`Logs/WESHT_YYYYMMDD.log`).

---

## ⚠️ Uso responsable — LEE ESTO ANTES DE EJECUTAR

> Este toolkit **modifica configuración real del sistema operativo** (políticas de contraseña, bloqueo de cuentas, perfiles de firewall, preferencias de Windows Defender). No es un simulador.
>
> - **Ejecuta primero en una máquina virtual o entorno de laboratorio**, nunca directamente en producción sin haberlo probado.
> - Requiere ejecutarse **como Administrador** (el propio script lo valida y se detiene si no lo es).
> - Antes de aplicar una remediación, los módulos hacen un **backup** de la configuración relevante (ver `Backup-PasswordPolicy` como ejemplo), pero el motor de **rollback automático todavía está en desarrollo** (ver Roadmap) — por ahora el respaldo queda disponible para revertir manualmente si hace falta.
> - Usa esta herramienta únicamente en sistemas sobre los que tengas autorización explícita para hacer cambios.

---

## 🏗️ Estructura del proyecto

```
WESHT/
├── Main.ps1                     # Punto de entrada
├── Config/
│   ├── Config.ps1                # Configuración global (rutas, flags)
│   └── CISMappings.json          # Catálogo: Control CIS → Módulo/Función
├── Core/
│   ├── Logger.ps1                # Logging centralizado (consola + archivo)
│   ├── Helpers.ps1                # Validación de admin, inicialización de carpetas
│   ├── Dashboard.ps1              # Panel con info del sistema al iniciar
│   ├── Parser.ps1                 # Importa y clasifica el CSV de Wazuh
│   ├── RemediationEngine.ps1      # Motor: resuelve Control ID → función a ejecutar
│   ├── ExecutionManager.ps1       # Orquesta la ejecución masiva + estadísticas
│   ├── HTMLReport.ps1             # Generador de reporte HTML
│   └── Menu.ps1                   # Menú interactivo de consola
├── Modules/
│   ├── PasswordPolicy.ps1         # CIS 1.1.x — Política de contraseñas
│   ├── AccountPolicy.ps1          # CIS 1.2.x — Bloqueo de cuentas
│   ├── Firewall.ps1               # CIS 9.1.x — Perfiles de firewall
│   └── Defender.ps1               # CIS 18.10.x — Windows Defender
├── Samples/
│   └── sample-wazuh-report.csv    # CSV de ejemplo para probar el flujo completo
├── Logs/                          # Se genera en tiempo de ejecución
├── Reports/                       # Se genera en tiempo de ejecución
└── Rollback/                      # Reservado para el motor de rollback (WIP)
```

---

## 🚀 Cómo probarlo

```powershell
git clone https://github.com/izktech/WESHT.git
cd WESHT

# Ejecutar como Administrador (clic derecho en PowerShell > "Ejecutar como administrador")
.\Main.ps1
```

Dentro del menú:

1. **Load Wazuh Report** → apunta al archivo `Samples\sample-wazuh-report.csv` para probar sin necesitar un agente Wazuh real.
2. **Apply CIS Remediation** → ejecuta las remediaciones mapeadas para los controles marcados como `FAILED`.
3. **Generate HTML Report** → genera el reporte en la carpeta `Reports\`.

---

## 🔌 Cómo agregar un nuevo control CIS

El diseño es extensible a propósito. Para agregar soporte a un nuevo control:

**1.** Agrega la entrada en `Config/CISMappings.json`:
```json
"2.3.1": {
    "Module": "AuditPolicy",
    "Function": "Invoke-AuditPolicyRemediation",
    "Description": "Configure audit logon events",
    "Severity": "Medium"
}
```

**2.** Crea `Modules/AuditPolicy.ps1` siguiendo el patrón usado en los módulos existentes (`Get-* / Set-* / Test-* / Invoke-*Remediation`).

**3.** Registra el archivo en la lista `$RemediationModules` dentro de `Main.ps1`.

El `RemediationEngine` se encarga de detectar el Control ID del CSV, buscar su mapeo, y llamar automáticamente a la función correspondiente — no hay que tocar el motor central.

---

## 🗺️ Roadmap

- [ ] Motor de **rollback automático** (restaurar desde los backups que ya se generan).
- [ ] Módulo de **verificación de cumplimiento** post-remediación (opción 4 del menú).
- [ ] Exportar resultados también a CSV, no solo HTML.
- [ ] Más controles CIS: políticas de auditoría, restricciones de red, servicios innecesarios.
- [ ] Modo `-WhatIf` para simular remediaciones sin aplicarlas (dry-run).
- [ ] Pester tests para los módulos de parsing y mapeo.

---

## 📄 Licencia

Este proyecto está bajo licencia **MIT** — ver [LICENSE](LICENSE). Libre para usar, copiar, modificar y distribuir, incluso con fines comerciales, manteniendo el aviso de copyright.

---

## ✍️ Autor

**Luis Fonseca (izktech)**
Proyecto educativo / de portafolio en ciberseguridad, hardening de sistemas y automatización con PowerShell.
