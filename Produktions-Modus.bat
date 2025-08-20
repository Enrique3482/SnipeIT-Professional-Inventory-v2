@echo off
title SnipeIT Produktions-Modus
color 0C
echo ========================================
echo  SnipeIT Inventory - PRODUKTIONS-MODUS
echo ========================================
echo.
echo WARNUNG: Dies wird echte Aenderungen an Ihrer SnipeIT-Datenbank vornehmen!
echo.
echo Stellen Sie sicher, dass:
echo 1. Der Test-Modus erfolgreich durchgefuehrt wurde
echo 2. Die Konfiguration korrekt ist
echo 3. Sie ein Backup Ihrer SnipeIT-Datenbank haben
echo.
set /p confirm="Sind Sie sicher, dass Sie fortfahren moechten? (ja/nein): "
if /i "%confirm%"=="ja" goto start
if /i "%confirm%"=="j" goto start
if /i "%confirm%"=="yes" goto start
if /i "%confirm%"=="y" goto start
echo Abgebrochen.
pause
exit

:start
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Start-SnipeInventory.ps1" -Mode Production -VerboseLogging
pause
