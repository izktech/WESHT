import sqlite3

def init_db():
    conn = sqlite3.connect("cve_database.db")
    cursor = conn.cursor()
    
    # Crear tabla de vulnerabilidades
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS cves (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cve_id TEXT UNIQUE,
            severity TEXT,
            description TEXT,
            affected_component TEXT
        )
    """)
    
    # Insertar datos de ejemplo si la tabla está vacía
    sample_data = [
        ("CVE-2023-38831", "HIGH", "WinRAR Remote Code Execution Vulnerability", "WinRAR"),
        ("CVE-2021-44228", "CRITICAL", "Apache Log4j2 JNDI injection vulnerability", "Log4j"),
        ("CVE-2024-21338", "HIGH", "Windows Print Spooler Elevation of Privilege Vulnerability", "Windows Kernel"),
        ("CVE-2023-21715", "MEDIUM", "Microsoft Publisher Security Feature Bypass Vulnerability", "Office")
    ]
    
    cursor.executemany("""
        INSERT OR IGNORE INTO cves (cve_id, severity, description, affected_component)
        VALUES (?, ?, ?, ?)
    """, sample_data)
    
    conn.commit()
    conn.close()

if __name__ == "__main__":
    init_db()
    print("[+] Base de datos SQLite inicializada correctamente.")