# 🚀 Schnellstart-Anleitung

## Einfacher Start

### Option 1: Batch-Dateien (Einfachste Methode)
1. **Test-Modus.bat** - Doppelklick für sicheren Test-Modus
2. **Produktions-Modus.bat** - Doppelklick für Live-Modus (nach erfolgreichem Test!)
3. **Interaktiv-Starten.bat** - Doppelklick für interaktive Auswahl

### Option 2: PowerShell Starter
```powershell
# Interaktiv (empfohlen für erste Nutzung)
.\Start-SnipeInventory.ps1

# Direkt Test-Modus
.\Start-SnipeInventory.ps1 -Mode Test -SimulateHardware

# Direkt Produktions-Modus (Vorsicht!)
.\Start-SnipeInventory.ps1 -Mode Production
```

### Option 3: VS Code Tasks
1. Öffnen Sie `workspace.code-workspace` in VS Code
2. Drücken Sie `Ctrl+Shift+P`
3. Tippen Sie "Tasks: Run Task"
4. Wählen Sie:
   - 🧪 Test Mode - Simulation
   - 🚀 Production Mode - Live
   - 💬 Interactive Mode

## ⚠️ Wichtige Sicherheitshinweise

### Vor dem ersten Start:
1. ✅ Konfiguration in `SnipeConfig.json` anpassen
2. ✅ **IMMER** zuerst im Test-Modus testen!
3. ✅ SnipeIT-Datenbank sichern (Backup!)
4. ✅ API-Token und URL überprüfen

### Test-Modus Checkliste:
- [ ] Script startet ohne Fehler
- [ ] Konfiguration wird richtig geladen
- [ ] Hardware wird korrekt erkannt
- [ ] Keine API-Fehler im Log
- [ ] Simulierte Daten sehen korrekt aus

### Produktions-Modus nur nach:
- [ ] Erfolgreichem Test-Modus
- [ ] Backup der SnipeIT-Datenbank
- [ ] Überprüfung der Konfiguration
- [ ] Bestätigung der API-Verbindung

## 🔧 Konfiguration

### Wichtigste Einstellungen in SnipeConfig.json:
```json
{
    "TestMode": { "IsPresent": false },           // false für Produktion
    "SimulateHardware": { "IsPresent": false },   // true für Tests
    "VerboseLogging": { "IsPresent": true },      // immer true empfohlen
    "Snipe": {
        "URL": "https://ihre-snipeit-url.com",    // Ihre SnipeIT URL
        "Token": "IHR-API-TOKEN-HIER"             // Ihr API Token
    }
}
```

## 📊 Überwachung

### Log-Dateien:
- `snipeit-inventory.log` - Hauptprotokoll
- Console Output - Live-Status

### Erfolgsindikatoren:
- ✅ "Script completed successfully"
- ✅ "Assets synchronized: X"
- ✅ Keine Fehlermeldungen im Log

### Problembehebung:
1. Überprüfen Sie die Log-Datei
2. Führen Sie PSScriptAnalyzer aus
3. Testen Sie im Test-Modus
4. Überprüfen Sie die Netzwerkverbindung

## 📞 Support

### Bei Problemen:
1. 📋 Log-Datei überprüfen
2. 🧪 Im Test-Modus testen
3. 📊 PSScriptAnalyzer laufen lassen
4. 🔧 Konfiguration validieren

### Häufige Fehler:
- **API-Token ungültig**: Token in SnipeConfig.json überprüfen
- **URL nicht erreichbar**: Netzwerkverbindung und URL testen
- **Berechtigung fehlt**: PowerShell als Administrator ausführen
- **Konfigurationsfehler**: JSON-Syntax überprüfen
