@echo off
title SnipeIT Test-Modus
echo ===================================
echo  SnipeIT Inventory - TEST-MODUS
echo ===================================
echo.
echo Startet das SnipeIT Inventory Script im sicheren Test-Modus
echo Keine echten API-Aufrufe werden durchgefuehrt!
echo.
pause
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Start-SnipeInventory.ps1" -Mode Test -SimulateHardware -VerboseLogging
pause
