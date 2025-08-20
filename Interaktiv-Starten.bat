@echo off
title SnipeIT Interaktiv
echo ===================================
echo  SnipeIT Inventory - Interaktiv
echo ===================================
echo.
echo Startet das SnipeIT Inventory Script im interaktiven Modus
echo Sie koennen zwischen Test- und Produktions-Modus waehlen
echo.
pause
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Start-SnipeInventory.ps1" -Mode Interactive
pause
