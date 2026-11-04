import customtkinter as ctk
from tkinter import filedialog
import threading
import time
import subprocess
import platform
import os

# Configuración inicial del tema visual
ctk.set_appearance_mode("System")
ctk.set_default_color_theme("blue")

class WESHTApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("WESHT-Py | Suite Avanzada de Auditoría y Redes")
        self.geometry("920x800")
        self.resizable(False, False)

        # Título superior
        self.title_label = ctk.CTkLabel(self, text="WESHT-Py: Auditor, Enumerador y Escáner de Red", font=ctk.CTkFont(size=20, weight="bold"))
        self.title_label.pack(pady=10)

        # Sistema de pestañas (Tabs)
        self.tabview = ctk.CTkTabview(self, width=880, height=680)
        self.tabview.pack(pady=5, padx=20)

        # Agregar pestañas
        self.tab_hardening = self.tabview.add("Hardening del Sistema")
        self.tab_linenum = self.tabview.add("Enumeración Profunda (LinEnum)")
        self.tab_nmap = self.tabview.add("Escáner Nmap")
        self.tab_guide = self.tabview.add("Guía y Ayuda")

        # Configurar cada pestaña
        self.setup_hardening_tab()
        self.setup_linenum_tab()
        self.setup_nmap_tab()
        self.setup_guide_tab()

    def setup_hardening_tab(self):
        self.btn_run_hard = ctk.CTkButton(self.tab_hardening, text="Escanear Hardening a Fondo", fg_color="#28a745", hover_color="#218838", command=self.start_hardening_thread)
        self.btn_run_hard.pack(pady=10)

        self.progress_hard = ctk.CTkProgressBar(self.tab_hardening, width=820)
        self.progress_hard.pack(pady=5)
        self.progress_hard.set(0.0)

        self.text_hard = ctk.CTkTextbox(self.tab_hardening, width=820, height=480, font=("Consolas", 12))
        self.text_hard.pack(pady=5)
        self.text_hard.insert("0.0", "[*] Listo para iniciar auditoría completa de Hardening del sistema...\n")

        self.btn_export_hard = ctk.CTkButton(self.tab_hardening, text="Exportar Reporte Hardening", state="disabled", command=lambda: self.export_report(self.text_hard))
        self.btn_export_hard.pack(pady=5)

    def setup_linenum_tab(self):
        self.btn_run_enum = ctk.CTkButton(self.tab_linenum, text="Ejecutar Enumeración Exhaustiva", fg_color="#d9534f", hover_color="#c9302c", command=self.start_linenum_thread)
        self.btn_run_enum.pack(pady=10)

        self.progress_enum = ctk.CTkProgressBar(self.tab_linenum, width=820)
        self.progress_enum.pack(pady=5)
        self.progress_enum.set(0.0)

        self.text_enum = ctk.CTkTextbox(self.tab_linenum, width=820, height=480, font=("Consolas", 12))
        self.text_enum.pack(pady=5)
        self.text_enum.insert("0.0", "[*] Listo para extraer vectores detallados (Usuarios, Redes, Procesos, Tareas)...\n")

        self.btn_export_enum = ctk.CTkButton(self.tab_linenum, text="Exportar Reporte Enumeración", state="disabled", command=lambda: self.export_report(self.text_enum))
        self.btn_export_enum.pack(pady=5)

    def setup_nmap_tab(self):
        self.frame_nmap_ctrl = ctk.CTkFrame(self.tab_nmap)
        self.frame_nmap_ctrl.pack(pady=10, padx=10, fill="x")

        self.entry_target = ctk.CTkEntry(self.frame_nmap_ctrl, placeholder_text="IP o Dominio objetivo (ej. 127.0.0.1)", width=280)
        self.entry_target.pack(side="left", padx=10, pady=10)
        self.entry_target.insert(0, "127.0.0.1")

        self.scan_types = [
            "Escaneo Rápido de Puertos (-F)",
            "Escaneo Agresivo (SO y Versiones -A)",
            "Detección de Versiones de Servicios (-sV)",
            "Escaneo de Puertos Específicos (Top 100)",
            "Barrido Ping / Descubrimiento de Red (-sn)"
        ]
        self.combo_scan = ctk.CTkComboBox(self.frame_nmap_ctrl, values=self.scan_types, width=270)
        self.combo_scan.pack(side="left", padx=10, pady=10)
        self.combo_scan.set("Escaneo Rápido de Puertos (-F)")

        self.btn_run_nmap = ctk.CTkButton(self.frame_nmap_ctrl, text="Ejecutar Nmap", fg_color="#337ab7", hover_color="#286090", command=self.start_nmap_thread)
        self.btn_run_nmap.pack(side="right", padx=10, pady=10)

        self.progress_nmap = ctk.CTkProgressBar(self.tab_nmap, width=820)
        self.progress_nmap.pack(pady=5)
        self.progress_nmap.set(0.0)

        self.text_nmap = ctk.CTkTextbox(self.tab_nmap, width=820, height=430, font=("Consolas", 12))
        self.text_nmap.pack(pady=5)
        self.text_nmap.insert("0.0", "[*] Módulo Nmap cargado (Utilizando versión portátil integrada en ./nmap/nmap.exe)...\n")

        self.btn_export_nmap = ctk.CTkButton(self.tab_nmap, text="Exportar Reporte Nmap", state="disabled", command=lambda: self.export_report(self.text_nmap))
        self.btn_export_nmap.pack(pady=5)

    def setup_guide_tab(self):
        self.text_guide = ctk.CTkTextbox(self.tab_guide, width=840, height=550, font=("Segoe UI", 13))
        self.text_guide.pack(pady=15, padx=10)
        
        guide_content = """========================================================================
 WESHT-Py | GUÍA DE USO E INSTRUCCIONES DEL SISTEMA
========================================================================

1. HARDENING DEL SISTEMA:
   - ¿Qué hace?: Audita configuraciones críticas de seguridad en Windows.
   - Verificaciones: Revisa el estado del Control de Cuentas de Usuario (UAC), 
     los perfiles del Firewall de Windows, protocolos heredados vulnerables 
     (como SMBv1), el estado de Escritorio Remoto (RDP) y servicios activos 
     de alto riesgo.

2. ENUMERACIÓN PROFUNDA (ESTILO LINENUM):
   - ¿Qué hace?: Extrae información detallada del entorno local de la PC 
     para identificar vectores de escalada de privilegios o auditoría interna.
   - Datos que muestra: Información del sistema operativo, cuentas de usuario 
     locales, miembros del grupo Administradores, conexiones de red activas 
     (puertos en escucha), procesos en ejecución y tareas programadas.

3. ESCÁNER NMAP (VERSIÓN PORTÁTIL INTEGRADA):
   - ¿Qué hace?: Permite realizar escaneos de red utilizando la versión 
     portátil integrada en la carpeta del proyecto.
   
   📁 CONFIGURACIÓN PORTÁTIL:
   - La herramienta busca automáticamente el binario en la ruta local:
     './nmap/nmap.exe' (dentro de la carpeta de tu proyecto).
   - Gracias a esto, no requiere instalación manual en el sistema operativo ni 
     configuración previa de variables de entorno (PATH).

========================================================================
"""
        self.text_guide.insert("0.0", guide_content)
        self.text_guide.configure(state="disabled")

    def log_hard(self, message):
        self.text_hard.insert("end", message + "\n")
        self.text_hard.see("end")

    def log_enum(self, message):
        self.text_enum.insert("end", message + "\n")
        self.text_enum.see("end")

    def log_nmap(self, message):
        self.text_nmap.insert("end", message + "\n")
        self.text_nmap.see("end")

    # --- LÓGICA DE HARDENING ---
    def start_hardening_thread(self):
        self.btn_run_hard.configure(state="disabled")
        self.btn_export_hard.configure(state="disabled")
        self.text_hard.delete("0.0", "end")
        self.progress_hard.set(0.0)
        threading.Thread(target=self.run_comprehensive_hardening, daemon=True).start()

    def run_comprehensive_hardening(self):
        self.log_hard("[*] Iniciando auditoría completa de Hardening local...")
        self.progress_hard.set(0.1)
        time.sleep(0.3)

        try:
            self.log_hard("--------------------------------------------------")
            self.log_hard(" [1] EVALUACIÓN DE CONTROL DE CUENTAS (UAC)")
            self.log_hard("--------------------------------------------------")
            uac_cmd = "(Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System).EnableLUA"
            uac_res = subprocess.run(["powershell", "-Command", uac_cmd], capture_output=True, text=True, timeout=5)
            if uac_res and "1" in uac_res.stdout:
                self.log_hard("[OK] UAC (User Account Control) está HABILITADO.")
            else:
                self.log_hard("[!] ALERTA CRÍTICA: UAC está deshabilitado.")
            self.progress_hard.set(0.3)

            self.log_hard("\n--------------------------------------------------")
            self.log_hard(" [2] ESTADO DEL FIREWALL DE WINDOWS")
            self.log_hard("--------------------------------------------------")
            fw_cmd = "Get-NetFirewallProfile | Select-Object Name, Enabled"
            fw_res = subprocess.run(["powershell", "-Command", fw_cmd], capture_output=True, text=True, timeout=5)
            if fw_res and fw_res.stdout.strip():
                self.log_hard(fw_res.stdout.strip())
            self.progress_hard.set(0.5)

            self.log_hard("\n--------------------------------------------------")
            self.log_hard(" [3] PROTOCOLOS HEREDADOS (SMBv1)")
            self.log_hard("--------------------------------------------------")
            smb_cmd = "Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol"
            smb_res = subprocess.run(["powershell", "-Command", smb_cmd], capture_output=True, text=True, timeout=5)
            if smb_res and "Enabled" in smb_res.stdout:
                self.log_hard("[!] ALERTA CRÍTICA: Protocolo SMBv1 habilitado.")
            else:
                self.log_hard("[OK] SMBv1 está deshabilitado o no instalado.")
            self.progress_hard.set(0.7)

            self.log_hard("\n--------------------------------------------------")
            self.log_hard(" [4] ESTADO DE ESCRITORIO REMOTO (RDP)")
            self.log_hard("--------------------------------------------------")
            rdp_cmd = "(Get-ItemProperty 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server').fDenyTSConnections"
            rdp_res = subprocess.run(["powershell", "-Command", rdp_cmd], capture_output=True, text=True, timeout=5)
            if rdp_res and "0" in rdp_res.stdout:
                self.log_hard("[!] AVISO: Escritorio Remoto (RDP) está PERMITIDO.")
            else:
                self.log_hard("[OK] Escritorio Remoto (RDP) está deshabilitado.")
            self.progress_hard.set(0.85)

            self.log_hard("\n--------------------------------------------------")
            self.log_hard(" [5] SERVICIOS DE ALTO RIESGO ACTIVOS")
            self.log_hard("--------------------------------------------------")
            srv_cmd = "Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object -ExpandProperty Name"
            srv_res = subprocess.run(["powershell", "-Command", srv_cmd], capture_output=True, text=True, timeout=6)
            if srv_res and srv_res.stdout.strip():
                services = srv_res.stdout.splitlines()
                risky_services = ["TlntSvr", "SNMP", "RemoteRegistry", "Messenger"]
                found_risky = [s for s in risky_services if s in services]
                if found_risky:
                    for rs in found_risky:
                        self.log_hard(f"[!] ALERTA: Servicio de alto riesgo activo -> {rs}")
                else:
                    self.log_hard("[OK] No se detectaron servicios de alto riesgo comunes activos.")

        except Exception as e:
            self.log_hard(f"[!] Error en auditoría de Hardening: {e}")

        self.progress_hard.set(1.0)
        self.log_hard("\n==================================================")
        self.log_hard(" AUDITORÍA DE HARDENING FINALIZADA")
        self.log_hard("==================================================")
        self.btn_run_hard.configure(state="normal")
        self.btn_export_hard.configure(state="normal")

    # --- LÓGICA DE ENUMERACIÓN PROFUNDA ---
    def start_linenum_thread(self):
        self.btn_run_enum.configure(state="disabled")
        self.btn_export_enum.configure(state="disabled")
        self.text_enum.delete("0.0", "end")
        self.progress_enum.set(0.0)
        threading.Thread(target=self.run_deep_enumeration, daemon=True).start()

    def run_deep_enumeration(self):
        self.log_enum("[*] Iniciando enumeración profunda del sistema local...")
        self.progress_enum.set(0.1)
        time.sleep(0.3)

        try:
            self.log_enum("==================================================")
            self.log_enum(" [1] INFORMACIÓN GENERAL DEL SISTEMA")
            self.log_enum("==================================================")
            sys_cmd = "Get-CimInstance Win32_OperatingSystem | Select-Object CSName, Caption, Version, OSArchitecture"
            sys_res = subprocess.run(["powershell", "-Command", sys_cmd], capture_output=True, text=True, timeout=6)
            if sys_res and sys_res.stdout.strip():
                self.log_enum(sys_res.stdout.strip())
            self.progress_enum.set(0.25)

            self.log_enum("\n==================================================")
            self.log_enum(" [2] USUARIOS Y GRUPOS LOCALES")
            self.log_enum("==================================================")
            users_cmd = "Get-LocalUser | Select-Object Name, Enabled, PasswordRequired, LastLogon"
            users_res = subprocess.run(["powershell", "-Command", users_cmd], capture_output=True, text=True, timeout=5)
            if users_res and users_res.stdout.strip():
                self.log_enum(users_res.stdout.strip())

            self.log_enum("\n--- Miembros del grupo Administradores ---")
            admins_cmd = "Get-LocalGroupMember -Group 'Administradores' -ErrorAction SilentlyContinue | Select-Object Name, PrincipalSource"
            admins_res = subprocess.run(["powershell", "-Command", admins_cmd], capture_output=True, text=True, timeout=5)
            if admins_res and admins_res.stdout.strip():
                self.log_enum(admins_res.stdout.strip())
            self.progress_enum.set(0.45)

            self.log_enum("\n==================================================")
            self.log_enum(" [3] CONEXIONES DE RED Y PUERTOS EN ESCUCHA")
            self.log_enum("==================================================")
            net_cmd = "Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, OwningProcess | Select-Object -First 10"
            net_res = subprocess.run(["powershell", "-Command", net_cmd], capture_output=True, text=True, timeout=6)
            if net_res and net_res.stdout.strip():
                self.log_enum(net_res.stdout.strip())
            self.progress_enum.set(0.65)

            self.log_enum("\n==================================================")
            self.log_enum(" [4] PROCESOS ACTIVOS EN EJECUCIÓN")
            self.log_enum("==================================================")
            proc_cmd = "Get-Process | Select-Object Name, Id, WorkingSet | Select-Object -First 12"
            proc_res = subprocess.run(["powershell", "-Command", proc_cmd], capture_output=True, text=True, timeout=6)
            if proc_res and proc_res.stdout.strip():
                self.log_enum(proc_res.stdout.strip())
            self.progress_enum.set(0.8)

            self.log_enum("\n==================================================")
            self.log_enum(" [5] TAREAS PROGRAMADAS PERSONALIZADAS")
            self.log_enum("==================================================")
            task_cmd = "Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {$_.TaskPath -ne '\\'} | Select-Object TaskName, State | Select-Object -First 10"
            task_res = subprocess.run(["powershell", "-Command", task_cmd], capture_output=True, text=True, timeout=6)
            if task_res and task_res.stdout.strip():
                self.log_enum(task_res.stdout.strip())

        except Exception as e:
            self.log_enum(f"[!] Error durante la enumeración profunda: {e}")

        self.progress_enum.set(1.0)
        self.log_enum("\n==================================================")
        self.log_enum(" ENUMERACIÓN PROFUNDA FINALIZADA")
        self.log_enum("==================================================")
        self.btn_run_enum.configure(state="normal")
        self.btn_export_enum.configure(state="normal")

    # --- LÓGICA DE NMAP ---
    def start_nmap_thread(self):
        target = self.entry_target.get().strip()
        scan_choice = self.combo_scan.get()

        if not target:
            self.text_nmap.insert("end", "[!] Error: Debe ingresar una IP o dominio objetivo.\n")
            return

        self.btn_run_nmap.configure(state="disabled")
        self.btn_export_nmap.configure(state="disabled")
        self.text_nmap.delete("0.0", "end")
        self.progress_nmap.set(0.0)

        threading.Thread(target=self.run_nmap_scan, args=(target, scan_choice), daemon=True).start()

    def run_nmap_scan(self, target, choice):
        self.log_nmap(f"[*] Iniciando escaneo Nmap en objetivo: {target}")
        self.log_nmap(f"[*] Modo seleccionado: {choice}")
        self.progress_nmap.set(0.2)

        # Buscar binario Nmap portátil integrado en la carpeta local del proyecto
        local_nmap_path = "./nmap/nmap.exe"
        
        if os.path.exists(local_nmap_path):
            nmap_executable = local_nmap_path
            self.log_nmap("[*] Usando binario Nmap portátil integrado en './nmap/nmap.exe'.")
        else:
            nmap_executable = "nmap"
            self.log_nmap("[!] Advertencia: No se encontró './nmap/nmap.exe'. Intentando usar Nmap del PATH del sistema...")

        args = [nmap_executable]
        if "Rápido" in choice:
            args.extend(["-F", target])
        elif "Agresivo" in choice:
            args.extend(["-A", target])
        elif "Versiones" in choice:
            args.extend(["-sV", target])
        elif "Top 100" in choice:
            args.extend(["--top-ports", "100", target])
        elif "Barrido" in choice:
            args.extend(["-sn", target])
        else:
            args.extend(["-F", target])

        self.progress_nmap.set(0.4)
        try:
            self.log_nmap(f"[*] Ejecutando comando...\n")
            process = subprocess.run(args, capture_output=True, text=True, timeout=120)
            
            self.progress_nmap.set(0.9)
            if process.returncode == 0:
                self.log_nmap(process.stdout)
            else:
                self.log_nmap(f"[!] Nmap devolvió un error:\n{process.stderr}")

        except subprocess.TimeoutExpired:
            self.log_nmap("[!] El escaneo de Nmap expiró (Timeout de 120s).")
        except FileNotFoundError:
            self.log_nmap("[!] Error crítico: No se encontró 'nmap.exe' en la ruta portátil ni en el sistema.")
        except Exception as e:
            self.log_nmap(f"[!] Error inesperado al ejecutar Nmap: {e}")

        self.progress_nmap.set(1.0)
        self.log_nmap("\n==================================================")
        self.log_nmap(" ESCANEO NMAP FINALIZADO")
        self.log_nmap("==================================================")
        self.btn_run_nmap.configure(state="normal")
        self.btn_export_nmap.configure(state="normal")

    def export_report(self, textbox_widget):
        file_path = filedialog.asksaveasfilename(defaultextension=".txt", filetypes=[("Archivos de texto", "*.txt")])
        if file_path:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(textbox_widget.get("1.0", "end"))

if __name__ == "__main__":
    app = WESHTApp()
    app.mainloop()