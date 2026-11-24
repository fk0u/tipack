@echo off
chcp 65001 >nul
title DEVSETUP IF
:: Klik kanan -> Run as administrator. Kalau ada Windows Terminal, buka di sana (tampilan lebih bagus).
where wt >nul 2>nul
if %errorlevel%==0 (
  wt --title "DEVSETUP IF" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*
  pause
)
