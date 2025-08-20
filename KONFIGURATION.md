# ⚙️ Konfigurationsanleitung - SnipeIT Professional Inventory v2.2.0

## 🔧 Konfiguration anpassen

### 1. Basis-Konfiguration (SnipeConfig.json)

Bevor Sie das System produktiv nutzen, müssen Sie folgende Werte in der `SnipeConfig.json` anpassen:

#### 🌐 SnipeIT Server-Verbindung
```json
"Snipe": {
    "Url": "https://ihr-snipeit-server.de/api/v1",     // ← Ihre SnipeIT URL
    "Token": "ihr_api_token_hier",                     // ← Ihr API Token
    "StandardCompanyName": "Ihre Firma GmbH",         // ← Ihr Firmenname
    "StandardCategoryId": 1,                           // ← Standard-Kategorie ID
    "StandardModelFieldsetId": 2                       // ← Standard-Fieldset ID
}
```

#### 🔑 API Token generieren
1. Bei SnipeIT anmelden
2. **Benutzereinstellungen** → **API Tokens**
3. **Neuen Token erstellen**
4. Token kopieren und in Konfiguration einfügen

#### 🏢 Firmen-Anpassung
```json
"StandardCompanyName": "Ihre Firma GmbH",             // Firmenname für neue Assets
"StandardStatusName": "In Verwendung"                 // Standard-Status
```

### 2. Erweiterte Konfiguration

#### 📊 Performance-Einstellungen
```json
"Performance": {
    "MaxRetries": 3,        // Anzahl Wiederholungsversuche
    "BatchSize": 50,        // Assets pro Batch
    "RetryDelay": 2,        // Verzögerung zwischen Versuchen (Sekunden)
    "ApiTimeout": 60        // API-Timeout (Sekunden)
}
```

#### 🔍 Custom Field Mapping
Die Custom Fields müssen in SnipeIT angelegt und hier gemappt werden:
```json
"CustomFieldMapping": {
    "_snipeit_cpu_4": "Processor",
    "_snipeit_ram_gb_5": "Memory",
    "_snipeit_storage_summary_6": "Storage"
    // ... weitere Custom Fields
}
```

### 3. Wartungs-Konfiguration

#### 🛠️ Wartungsintervalle
```json
"Maintenance": {
    "CriticalDays": 7,      // Kritisch: Wartung überfällig
    "WarningDays": 30,      // Warnung: Wartung bald fällig
    "IntervalDays": 365     // Wartungsintervall in Tagen
}
```

### 4. Hersteller-Support (optional)

Die Herstellerdatenbank kann erweitert werden:
```json
"ManufacturerSupport": {
    "IhrHersteller": {
        "Name": "Ihre Firma Support GmbH",
        "SupportUrl": "https://support.ihre-firma.de",
        "SupportPhone": "+49 xxx xxx xxxx",
        "SupportEmail": "support@ihre-firma.de"
    }
}
```

## 🚨 Sicherheitshinweise

### ❗ WICHTIG: Vor Veröffentlichung prüfen
- **Keine echten API-Tokens** in öffentliche Repositories
- **Keine IP-Adressen** oder interne URLs
- **Keine Firmennamen** oder sensible Daten

### 🔒 Sichere Aufbewahrung
- API-Token sicher speichern
- Konfigurationsdatei aus Git-Tracking ausschließen
- Backup der Konfiguration erstellen

### 📋 Template verwenden
Nutzen Sie `SnipeConfig-TEMPLATE.json` als Basis und erstellen Sie Ihre eigene `SnipeConfig.json`

## 🧪 Test vor Produktiveinsatz

### 1. Test-Modus nutzen
```batch
# Immer zuerst testen!
Test-Modus.bat
```

### 2. Simulation aktivieren
```powershell
.\Start-SnipeInventory.ps1 -Mode Test -SimulateHardware
```

### 3. Konfiguration validieren
```powershell
# Konfiguration prüfen ohne API-Aufrufe
.\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging
```

## 🔄 Upgrade-Pfad

Bei Updates von v2.1.0 zu v2.2.0:
1. Backup der aktuellen `SnipeConfig.json`
2. Neue Dateien kopieren
3. Konfiguration übertragen
4. Test-Modus ausführen
5. Bei Erfolg: Produktions-Modus

---

## 💡 Tipps

- **Immer zuerst im Test-Modus** testen
- **API-Limits beachten** (Batch-Size anpassen)
- **Custom Fields in SnipeIT** vor Script-Ausführung anlegen
- **Logs überprüfen** bei Problemen

---

*Entwickelt für SnipeIT Professional Inventory System v2.2.0*
*Stand: 20. August 2025*
