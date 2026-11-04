# WESHT-Py | Suite Avanzada de Auditoría, Hardening y Redes

**WESHT-Py** es una herramienta de escritorio desarrollada en Python con una interfaz moderna basada en **CustomTkinter**, diseñada para realizar auditorías de seguridad en sistemas locales Windows, enumeración de vectores de escalada de privilegios y análisis de redes mediante Nmap.

---

## 🚀 Características Principales

1. **Hardening del Sistema:**
   - Auditoría de políticas críticas en Windows.
   - Verificación del Control de Cuentas de Usuario (UAC).
   - Comprobación de perfiles del Firewall de Windows.
   - Detección de protocolos heredados vulnerables (ej. SMBv1).
   - Revisión del estado de Escritorio Remoto (RDP) y servicios activos de alto riesgo.

2. **Enumeración Profunda (Estilo LinEnum):**
   - Extracción automatizada de información general del sistema.
   - Listado de usuarios locales y cuentas activas.
   - Verificación de miembros del grupo de Administradores.
   - Escaneo de puertos en escucha y conexiones de red activas.
   - Auditoría de procesos en ejecución y tareas programadas personalizadas.

3. **Escáner Nmap (Versión Portátil Integrada):**
   - Interfaz gráfica para perfiles de Nmap (Escaneo rápido, agresivo, versiones, etc.).
   - **Soporte Portable:** No requiere instalación manual ni configuración previa de variables de entorno en Windows; utiliza de forma transparente el binario incluido en la carpeta del proyecto (`./nmap/nmap.exe`).

4. **Guía y Ayuda Integrada:**
   - Panel explicativo dentro de la misma aplicación para orientar al operador sobre cada módulo.

---

## 📁 Estructura del Proyecto

```text
WESHT Python/
├── app.py                # Script principal de la aplicación (GUI)
├── requirements.txt      # Dependencias del proyecto
├── README.md             # Documentación del repositorio
└── nmap/                 # Carpeta contenedora del binario portátil
    └── nmap.exe          # Ejecutable de Nmap y librerías de soporte