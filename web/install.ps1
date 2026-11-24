# DEVSETUP IF - bootstrap Windows
# Pakai (PowerShell):  irm https://tipack.kousozo.tech/install.ps1 | iex
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$dir = Join-Path $env:USERPROFILE 'devsetup-if'
New-Item -ItemType Directory -Force $dir | Out-Null
Write-Host "Mengunduh DEVSETUP IF ke $dir ..." -ForegroundColor Cyan
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest 'https://tipack.kousozo.tech/windows/setup.ps1' -OutFile (Join-Path $dir 'setup.ps1') -UseBasicParsing
Invoke-WebRequest 'https://tipack.kousozo.tech/windows/JALANKAN.bat' -OutFile (Join-Path $dir 'JALANKAN.bat') -UseBasicParsing
Unblock-File (Join-Path $dir 'setup.ps1')
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$runArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$dir\setup.ps1`""
if ($isAdmin) { & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$dir\setup.ps1" }
else {
  Write-Host 'Membuka jendela Administrator (klik Yes di popup UAC)...' -ForegroundColor Yellow
  if (Get-Command wt -ErrorAction SilentlyContinue) { Start-Process wt -Verb RunAs -ArgumentList "powershell $runArgs" }
  else { Start-Process powershell -Verb RunAs -ArgumentList $runArgs }
}
