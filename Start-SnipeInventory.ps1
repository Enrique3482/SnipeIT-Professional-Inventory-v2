#Requires -Version 5.1
<#
.SYNOPSIS
    SnipeIT Professional Inventory - Starter Script
.DESCRIPTION
    Einfache Startdatei für das SnipeIT Professional Inventory System
    mit klarer Trennung zwischen Test- und Produktionsmodus.
    
.NOTES
    Version: 2.2.0
    Author: Henrique Sebastiao
    Last Modified: 2025-08-20
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Test", "Production", "Interactive")]
    [string]$Mode = "Interactive",
    
    [Parameter(Mandatory = $false)]
    [string]$CustomerName = "Enterprise Organization",
    
    [Parameter(Mandatory = $false)]
    [switch]$SimulateHardware,
    
    [Parameter(Mandatory = $false)]
    [switch]$VerboseLogging
)

# Farben für die Konsole
function Write-ColoredText {
    param(
        [string]$Text,
        [ConsoleColor]$Color = 'White'
    )
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Text
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

function Show-Banner {
    Clear-Host
    Write-ColoredText "╔══════════════════════════════════════════════════════════════════╗" -Color Cyan
    Write-ColoredText "║                    SnipeIT Professional Inventory                ║" -Color Cyan
    Write-ColoredText "║                          Version 2.2.0                          ║" -Color Cyan
    Write-ColoredText "╚══════════════════════════════════════════════════════════════════╝" -Color Cyan
    Write-Host ""
}

function Show-ModeSelection {
    Write-ColoredText "Bitte wählen Sie den Ausführungsmodus:" -Color Yellow
    Write-Host ""
    Write-ColoredText "1. " -Color White -NoNewline
    Write-ColoredText "TEST-MODUS (Simulation)" -Color Green
    Write-ColoredText "   → Sicher: Keine echten API-Aufrufe" -Color Gray
    Write-ColoredText "   → Simuliert alle Operationen" -Color Gray
    Write-ColoredText "   → Ideal für erste Tests und Validierung" -Color Gray
    Write-Host ""
    
    Write-ColoredText "2. " -Color White -NoNewline
    Write-ColoredText "PRODUKTIONS-MODUS (Live)" -Color Red
    Write-ColoredText "   → Live: Echte API-Aufrufe an SnipeIT" -Color Gray
    Write-ColoredText "   → Aktualisiert tatsächlich die Asset-Datenbank" -Color Gray
    Write-ColoredText "   → Nur verwenden wenn Test-Modus erfolgreich war!" -Color Gray
    Write-Host ""
    
    Write-ColoredText "3. " -Color White -NoNewline
    Write-ColoredText "ABBRECHEN" -Color Yellow
    Write-Host ""
}

function Get-UserChoice {
    do {
        $choice = Read-Host "Ihre Wahl (1-3)"
        switch ($choice) {
            "1" { return "Test" }
            "2" { 
                Write-ColoredText "⚠️  WARNUNG: Sie haben den PRODUKTIONS-MODUS gewählt!" -Color Red
                Write-ColoredText "   Dies wird echte Änderungen an Ihrer SnipeIT-Datenbank vornehmen." -Color Red
                Write-Host ""
                $confirm = Read-Host "Sind Sie sicher? (ja/nein)"
                if ($confirm -eq "ja" -or $confirm -eq "j" -or $confirm -eq "yes" -or $confirm -eq "y") {
                    return "Production"
                } else {
                    Write-ColoredText "Produktions-Modus abgebrochen. Zurück zur Auswahl..." -Color Yellow
                    Write-Host ""
                }
            }
            "3" { 
                Write-ColoredText "Script beendet." -Color Yellow
                exit 0 
            }
            default { 
                Write-ColoredText "Ungültige Eingabe. Bitte wählen Sie 1, 2 oder 3." -Color Red 
            }
        }
    } while ($true)
}

function Start-InventoryScript {
    param(
        [string]$SelectedMode,
        [string]$Customer,
        [switch]$Simulate,
        [switch]$Verbose
    )
    
    $scriptPath = Join-Path $PSScriptRoot "SnipeIT-Professional-Inventory.ps1"
    
    if (-not (Test-Path $scriptPath)) {
        Write-ColoredText "❌ Fehler: SnipeIT-Professional-Inventory.ps1 nicht gefunden!" -Color Red
        Write-ColoredText "   Erwartet in: $scriptPath" -Color Gray
        exit 1
    }
    
    $arguments = @()
    
    if ($SelectedMode -eq "Test") {
        Write-ColoredText "🧪 Starte TEST-MODUS..." -Color Green
        $arguments += "-TestMode"
        if ($Simulate) {
            $arguments += "-SimulateHardware"
        }
    } else {
        Write-ColoredText "🚀 Starte PRODUKTIONS-MODUS..." -Color Red
        Write-ColoredText "   ⚠️  Echte API-Aufrufe werden durchgeführt!" -Color Yellow
    }
    
    if ($Verbose) {
        $arguments += "-VerboseLogging"
    }
    
    if ($Customer) {
        $arguments += "-CustomerName", "`"$Customer`""
    }
    
    Write-Host ""
    Write-ColoredText "Ausführungsparameter:" -Color Cyan
    Write-ColoredText "  Script: $scriptPath" -Color Gray
    Write-ColoredText "  Modus: $SelectedMode" -Color Gray
    Write-ColoredText "  Parameter: $($arguments -join ' ')" -Color Gray
    Write-Host ""
    
    # 3-Sekunden-Countdown
    for ($i = 3; $i -gt 0; $i--) {
        Write-ColoredText "Start in $i Sekunden... (Strg+C zum Abbrechen)" -Color Yellow
        Start-Sleep -Seconds 1
    }
    
    Write-ColoredText "▶️  Script wird gestartet..." -Color Green
    Write-Host ""
    
    try {
        & $scriptPath @arguments
    } catch {
        Write-ColoredText "❌ Fehler beim Ausführen des Scripts:" -Color Red
        Write-ColoredText "   $_" -Color Red
        exit 1
    }
}

# Hauptlogik
Show-Banner

switch ($Mode) {
    "Interactive" {
        Show-ModeSelection
        $selectedMode = Get-UserChoice
        Start-InventoryScript -SelectedMode $selectedMode -Customer $CustomerName -Simulate:$SimulateHardware -Verbose:$true
    }
    "Test" {
        Write-ColoredText "🧪 Automatischer Start im TEST-MODUS" -Color Green
        Start-InventoryScript -SelectedMode "Test" -Customer $CustomerName -Simulate:$SimulateHardware -Verbose:$true
    }
    "Production" {
        Write-ColoredText "🚀 Automatischer Start im PRODUKTIONS-MODUS" -Color Red
        Start-InventoryScript -SelectedMode "Production" -Customer $CustomerName -Simulate:$SimulateHardware -Verbose:$true
    }
}
