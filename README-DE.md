# SnipeIT Professional Inventory System - README (DE)

![Version](https://img.shields.io/badge/Version-2.2.0-blue.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)

## 🎯 Überblick

Das **SnipeIT Professional Inventory System** ist eine enterprise-grade Lösung für die automatisierte Hardware-Inventarisierung mit vollständiger Snipe-IT Integration. Version 2.2.0 führt eine komplette VS Code Workspace-Integration und benutzerfreundliche One-Click-Deployment-Optionen ein.

### 🌟 Hauptmerkmale

- **🔄 Automatische Hardware-Erkennung**: Vollständige Systemanalyse mit intelligenter Komponenten-Identifikation
- **🔗 Nahtlose Snipe-IT Integration**: Direkte API-Synchronisation mit erweiterten Custom Fields
- **🖥️ VS Code Workspace**: Professionelle Entwicklungsumgebung mit integrierten Tasks und Debugging
- **🚀 One-Click Deployment**: Batch-Dateien für sofortige Ausführung ohne Kommandozeilen-Kenntnisse
- **🛡️ Test-/Produktionsmodus**: Sichere Testumgebung mit vollständiger API-Simulation
- **📊 Erweiterte Berichterstattung**: Detaillierte Logs und Ausführungsberichte
- **🔧 Automatische Wartungsverfolgung**: Intelligent Asset-Lifecycle-Management

## 📦 Schnellstart

### Option 1: One-Click für Endbenutzer
```bash
# 1. Doppelklick auf eine der Batch-Dateien:
Test-Modus.bat           # Für sichere Tests ohne API-Aufrufe
Produktions-Modus.bat    # Für Live-Umgebung mit echten API-Aufrufen
Interaktiv-Starten.bat   # Für geführte Ausführung mit Menü
```

### Option 2: PowerShell für Power-User
```powershell
# Intelligenter Starter mit interaktivem Menü
.\Start-SnipeInventory.ps1

# Direkte Ausführung mit Parametern
.\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging
```

### Option 3: VS Code für Entwickler
```bash
# Workspace öffnen
code workspace.code-workspace

# Integrierte Tasks verwenden:
# Strg+Shift+P → "Tasks: Run Task" → Gewünschten Modus auswählen
```

## 🛠️ Installation

### Systemanforderungen
- **Betriebssystem**: Windows 10/11 oder Windows Server 2016+
- **PowerShell**: Version 5.1 oder höher
- **Netzwerk**: Zugriff auf Ihren Snipe-IT Server
- **Optional**: Visual Studio Code für Entwicklung

### Installationsschritte

1. **Repository klonen oder herunterladen**
   ```bash
   git clone https://github.com/Enrique3482/SnipeIT-Professional-Inventory.git
   cd SnipeIT-Professional-Inventory
   ```

2. **Konfiguration anpassen**
   ```powershell
   # SnipeConfig.json bearbeiten
   notepad SnipeConfig.json
   ```
   
   Wichtige Einstellungen:
   ```json
   {
     "Snipe": {
       "Url": "http://ihr-snipeit-server.de/api/v1",
       "Token": "Ihr-API-Token-hier",
       "StandardCompanyName": "Ihre Firma GmbH"
     }
   }
   ```

3. **Ersten Test durchführen**
   ```bash
   # Doppelklick auf Test-Modus.bat
   # ODER
   .\Start-SnipeInventory.ps1
   ```

## 🎮 Verwendung

### Für Endbenutzer (Einfachste Methode)

**Test-Modus.bat**
- Führt vollständige Simulation durch
- Keine echten API-Aufrufe
- Sicher für Tests und Validierung

**Produktions-Modus.bat**  
- Echte API-Aufrufe an Snipe-IT
- Erstellt/aktualisiert tatsächliche Assets
- Erfordert Bestätigung vor Ausführung

**Interaktiv-Starten.bat**
- Geführtes Menü für Modusauswahl
- Integrierte Hilfe und Erklärungen
- Ideal für neue Benutzer

### Für Power-User (PowerShell)

```powershell
# Alle verfügbaren Parameter anzeigen
Get-Help .\SnipeIT-Professional-Inventory.ps1 -Full

# Test-Modus mit ausführlicher Protokollierung
.\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging

# Produktions-Modus für spezifischen Kunden
.\SnipeIT-Professional-Inventory.ps1 -CustomerName "ACME Corp" -VerboseLogging

# Mit simulierter Hardware für Testzwecke
.\SnipeIT-Professional-Inventory.ps1 -TestMode -SimulateHardware -VerboseLogging
```

### Für Entwickler (VS Code)

1. **Workspace öffnen**
   ```bash
   code workspace.code-workspace
   ```

2. **Empfohlene Extensions installieren** (automatisch vorgeschlagen)
   - PowerShell Extension
   - GitLens
   - Error Lens

3. **Integrierte Tasks verwenden**
   - `Strg+Shift+P` → "Tasks: Run Task"
   - Verfügbare Tasks:
     - 🧪 Test Mode (Safe)
     - 🚀 Production Mode  
     - 💬 Interactive Mode
     - 📊 Code Analysis

4. **Debugging**
   - Breakpoints setzen
   - `F5` für Debug-Start
   - Variable-Inspektion in Echtzeit

## 🔧 Konfiguration

### SnipeConfig.json Struktur

```json
{
  "Snipe": {
    "Url": "http://ihr-snipeit-server/api/v1",
    "Token": "YOUR_API_TOKEN_HERE...",
    "StandardCompanyName": "Ihre Firma GmbH",
    "StandardStatusName": "In Use",
    "StandardModelFieldsetId": 2,
    "StandardCategoryId": 1
  },
  "CustomFieldMapping": {
    "_snipeit_mac_address_1": "MacAddress",
    "_snipeit_os_version_2": "OperatingSystem",
    "_snipeit_cpu_4": "Processor",
    "_snipeit_ram_gb_5": "Memory"
  },
  "Performance": {
    "ApiTimeout": 60,
    "MaxRetries": 3,
    "RetryDelay": 2
  }
}
```

### Erweiterte Konfiguration

**Custom Fields automatisch erstellen**
```powershell
# Das Skript erstellt automatisch alle benötigten Custom Fields
# Mapping kann in SnipeConfig.json angepasst werden
```

**Wartungsintervalle anpassen**
```json
{
  "Maintenance": {
    "IntervalDays": 365,    // Wartung alle 365 Tage
    "WarningDays": 30,      // Warnung 30 Tage vorher
    "CriticalDays": 7       // Kritisch 7 Tage vorher
  }
}
```

## 📊 Features im Detail

### Hardware-Erkennung
- **CPU**: Detaillierte Prozessor-Informationen mit Kernen und Threads
- **RAM**: Speichermodule mit Kapazität und Anzahl
- **Storage**: Interne und externe Speichergeräte mit Typ-Erkennung
- **Netzwerk**: IP-Adressen, MAC-Adressen, aktive Adapter
- **GPU**: Grafikkarten-Identifikation
- **Monitor**: Externe Monitor-Erkennung (optional)
- **Docking-Stations**: USB-Hub und Docking-Station-Erkennung

### Asset-Management
- **Automatische Kategorie-Zuordnung**: Basierend auf Hardware-Typ
- **Intelligente Status-Vergabe**: "Deployable" oder "In Use" je nach Benutzer-Matching
- **Custom Fields-Management**: Automatische Erstellung und Zuordnung
- **Asset-Checkout**: Automatischer Checkout bei Benutzer-Computer-Übereinstimmung

### Wartung und Überwachung
- **System-Alter-Berechnung**: Automatische Bestimmung basierend auf Installation
- **Wartungs-Status**: OVERDUE/CRITICAL/WARNING/OK
- **Performance-Metriken**: Ausführungszeit-Tracking
- **Detaillierte Logs**: Mehrere Log-Ebenen für verschiedene Zwecke

## 🚀 Erweiterte Funktionen

### Test-Modus (Sicherheit)
```powershell
# Vollständige Simulation ohne echte API-Aufrufe
.\SnipeIT-Professional-Inventory.ps1 -TestMode
```
- Simuliert alle API-Antworten
- Keine Änderungen an Snipe-IT
- Perfekt für Tests und Entwicklung
- Vollständige Funktionalität zur Validierung

### Produktions-Modus (Live)
```powershell
# Echte API-Aufrufe mit Live-Daten
.\SnipeIT-Professional-Inventory.ps1 -CustomerName "ACME Corp"
```
- Echte Asset-Erstellung/Updates
- Custom Fields werden erstellt
- Automatic Checkout bei Matching
- Vollständige Synchronisation

### Simulierte Hardware
```powershell
# Zusätzliche Hardware für Testzwecke simulieren
.\SnipeIT-Professional-Inventory.ps1 -TestMode -SimulateHardware
```
- Zusätzliche Monitore
- Docking-Stations
- Erweiterte Spezifikationen
- Ideal für Demo und Training

## 📁 Projektstruktur

```
SnipeIT-Professional-Inventory/
│
├── 📄 SnipeIT-Professional-Inventory.ps1    # Hauptskript
├── 🚀 Start-SnipeInventory.ps1              # Intelligenter Starter
├── ⚙️ SnipeConfig.json                       # Konfiguration
├── 🏢 workspace.code-workspace               # VS Code Workspace
├── 📋 PSScriptAnalyzerSettings.psd1         # Code-Qualitäts-Regeln
│
├── 🎯 Launcher/
│   ├── Test-Modus.bat                       # Test-Starter
│   ├── Produktions-Modus.bat                # Produktions-Starter
│   └── Interaktiv-Starten.bat               # Interaktiver Starter
│
├── 📚 Documentation/
│   ├── README-DE.md                         # Deutsche Dokumentation
│   ├── README-EN.md                         # Englische Dokumentation
│   ├── SCHNELLSTART-DE.md                   # Deutsche Schnellstartanleitung
│   ├── QUICKSTART-EN.md                     # Englische Schnellstartanleitung
│   ├── CHANGELOG-v2.2.0-DE.md              # Deutsche Changelog
│   └── CHANGELOG-v2.2.0-EN.md              # Englische Changelog
│
└── 📊 Logs/ (wird automatisch erstellt)
    ├── SnipeIT-Inventory.log               # Haupt-Log
    ├── SnipeIT-Errors.log                  # Fehler-Log
    └── Backups/                             # Automatische Backups
```

## 🔍 Problembehandlung

### Häufige Probleme

**1. PowerShell Execution Policy Fehler**
```powershell
# Temporäre Lösung (wird von Batch-Dateien automatisch gemacht)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Permanente Lösung (erfordert Admin-Rechte)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

**2. API-Verbindungsfehler**
```powershell
# Test der API-Verbindung
Invoke-RestMethod -Uri "http://ihr-server/api/v1/models" -Headers @{'Authorization'='Bearer IHR-TOKEN'}
```

**3. Fehlende Custom Fields**
```powershell
# Skript erstellt automatisch fehlende Fields
# Bei Problemen: TestMode verwenden zur Validierung
.\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging
```

### Debug-Informationen

**Verbose Logging aktivieren**
```powershell
.\SnipeIT-Professional-Inventory.ps1 -VerboseLogging
```

**Log-Dateien prüfen**
```powershell
# Hauptlog
Get-Content "C:\ProgramData\SnipeIT\Inventory\SnipeIT-Inventory.log" -Tail 50

# Fehlerlog
Get-Content "C:\ProgramData\SnipeIT\Errorlog\SnipeIT-Errors.log" -Tail 20
```

## 📈 Performance und Optimierung

### Optimierung für große Umgebungen

**Batch-Größe anpassen**
```json
{
  "Performance": {
    "BatchSize": 100,        // Größere Batches für mehr Effizienz
    "ApiTimeout": 120,       // Längere Timeouts für große Datensätze
    "MaxRetries": 5          // Mehr Wiederholungen für Stabilität
  }
}
```

**Caching nutzen**
- Entity-Cache reduziert API-Aufrufe
- Automatische Zwischenspeicherung von Herstellern, Modellen, etc.
- Cache wird pro Sitzung zurückgesetzt

### Monitoring

**Performance-Metriken**
```
Hardware Detection Time: 00:12.500
API Synchronization Time: 00:08.200  
Field Management Time: 00:03.100
Total Execution Time: 00:23.800
```

**Ausführungsstatistiken**
- Anzahl verarbeiteter Assets
- API-Aufrufe gezählt
- Fehler und Warnungen protokolliert
- Success/Failure Rate

## 🔐 Sicherheit

### Best Practices

**API-Token Sicherheit**
```powershell
# Token in sicherer Datei speichern (nicht im Script)
$config = Get-Content "secure-config.json" | ConvertFrom-Json
```

**Execution Policy**
```powershell
# Minimale Berechtigung verwenden
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Test-First Ansatz**
```powershell
# Immer zuerst im Test-Modus validieren
.\SnipeIT-Professional-Inventory.ps1 -TestMode
```

### Audit und Compliance

**Vollständige Protokollierung**
- Alle API-Aufrufe werden geloggt
- Fehler mit Zeilennummern
- Ausführungszeit und Benutzer
- Änderungen an Assets dokumentiert

**Rollback-Fähigkeiten**
- Automatische Backups vor Änderungen
- Wiederherstellungs-Funktionen
- Versionskontrolle über Git

## 🤝 Beitrag und Support

### Community

- **GitHub Issues**: [Probleme melden](https://github.com/Enrique3482/SnipeIT-Professional-Inventory/issues)
- **Feature Requests**: Neue Funktionen vorschlagen
- **Pull Requests**: Code-Beiträge willkommen
- **Wiki**: Community-Dokumentation

### Entwicklung

**Lokale Entwicklung**
```bash
git clone https://github.com/Enrique3482/SnipeIT-Professional-Inventory.git
cd SnipeIT-Professional-Inventory
code workspace.code-workspace
```

**Code-Qualität**
- PSScriptAnalyzer Integration
- Automatische Tests verfügbar
- Code-Formatierung standardisiert
- Dokumentation erforderlich

### Roadmap

**Version 2.3.0 (geplant)**
- Active Directory Integration
- Web-basiertes Dashboard  
- Automatische Updates
- Multi-Tenant Support
- REST API für externe Integration

**Version 3.0.0 (Zukunft)**
- Cross-Platform Support (Linux/macOS)
- Container-basierte Bereitstellung
- Machine Learning für Asset-Vorhersagen
- Erweiterte Berichtsfunktionen

## 📄 Lizenz

Dieses Projekt steht unter der [MIT Lizenz](LICENSE.md).

```
MIT License

Copyright (c) 2025 Henrique Sebastiao

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 🙏 Danksagungen

- **Snipe-IT Community**: Für die großartige Asset-Management-Plattform
- **PowerShell Team**: Für das robuste Scripting-Framework  
- **VS Code Team**: Für die exzellente Entwicklungsumgebung
- **Community Contributors**: Für Feedback und Verbesserungen

---

**Entwickelt mit ❤️ für professionelle IT-Asset-Verwaltung**

*Letzte Aktualisierung: 20. August 2025 | Version 2.2.0*
