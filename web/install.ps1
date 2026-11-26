# TIPACK - bootstrap Windows
# Pakai (PowerShell):  irm https://tipack.kousozo.tech/install.ps1 | iex
# Langsung pasang aplikasi tertentu (dari pemilih di website):
#   $env:TIPACK_APPS = "chrome,vlc,7zip"; irm https://tipack.kousozo.tech/install.ps1 | iex
#   $env:TIPACK_CONFIG = "https://contoh.com/tipack.json"; irm https://tipack.kousozo.tech/install.ps1 | iex
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$dir = Join-Path $env:USERPROFILE 'devsetup-if'
New-Item -ItemType Directory -Force $dir | Out-Null
Write-Host "Mengunduh TIPACK ke $dir ..." -ForegroundColor Cyan
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest 'https://tipack.kousozo.tech/windows/setup.ps1' -OutFile (Join-Path $dir 'setup.ps1') -UseBasicParsing
Invoke-WebRequest 'https://tipack.kousozo.tech/windows/JALANKAN.bat' -OutFile (Join-Path $dir 'JALANKAN.bat') -UseBasicParsing
Unblock-File (Join-Path $dir 'setup.ps1')

$extra = ''
if ($env:TIPACK_APPS) {
  $apps = ($env:TIPACK_APPS -replace '[^a-z0-9,-]', '')
  if ($apps) { $extra = " -Install $apps"; Write-Host "Aplikasi pilihan: $apps" -ForegroundColor Magenta }
  Remove-Item Env:\TIPACK_APPS -ErrorAction SilentlyContinue
} elseif ($env:TIPACK_CONFIG) {
  $cfg = $env:TIPACK_CONFIG -replace '"', ''
  $extra = " -Config `"$cfg`""; Write-Host "Konfigurasi: $cfg" -ForegroundColor Magenta
  Remove-Item Env:\TIPACK_CONFIG -ErrorAction SilentlyContinue
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$runArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$dir\setup.ps1`"$extra"
if ($isAdmin) {
  $p = Start-Process powershell.exe -ArgumentList $runArgs -NoNewWindow -Wait -PassThru
} else {
  Write-Host 'Membuka jendela Administrator (klik Yes di popup UAC)...' -ForegroundColor Yellow
  if ($extra) { $runArgs = $runArgs.Replace('-File', '-NoExit -File') }   # jendela tetap terbuka supaya ringkasan terbaca
  if (Get-Command wt -ErrorAction SilentlyContinue) { Start-Process wt -Verb RunAs -ArgumentList "powershell $runArgs" }
  else { Start-Process powershell -Verb RunAs -ArgumentList $runArgs }
}
