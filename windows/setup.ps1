#Requires -Version 5.1
<#
  DEVSETUP IF v2 - Installer interaktif untuk Mahasiswa Teknik Informatika & Abang IT (Windows 10/11)
  Navigasi: panah atas/bawah, Spasi = centang, Enter = lanjut, Esc = kembali.

  Jalankan:  klik kanan JALANKAN.bat -> Run as administrator
  atau:      powershell -ExecutionPolicy Bypass -File setup.ps1 [-Preset starter] [-NoAnim]
#>
param([string]$Preset = "", [switch]$NoAnim)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8; $OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$Host.UI.RawUI.WindowTitle = 'DEVSETUP IF - Installer Mahasiswa Informatika'
$Root = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$LogFile = Join-Path $Root ("devsetup-log-{0:yyyyMMdd-HHmmss}.txt" -f (Get-Date))
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# =====================================================================================
#  KATALOG   key | Kategori | ID (winget / wsl:x / feat:x / info:url) | Nama | Rek(1/0) | Tooltip
# =====================================================================================
$CatalogRaw = @'
chrome|Browser|Google.Chrome|Google Chrome|1|Browser paling umum dengan DevTools terlengkap. Wajib untuk debugging web. Rekomendasi utama.
firefox|Browser|Mozilla.Firefox|Mozilla Firefox|0|Open source dan lebih menjaga privasi. DevTools untuk CSS Grid/Flexbox paling enak. Cocok jadi browser kedua untuk tes kompatibilitas.
firefoxdev|Browser|Mozilla.Firefox.DeveloperEdition|Firefox Developer Edition|0|Firefox khusus developer dengan fitur DevTools eksperimental.
brave|Browser|Brave.Brave|Brave|0|Berbasis Chromium dengan adblock bawaan. Lebih hemat RAM dari Chrome, ekstensi Chrome tetap jalan.
operagx|Browser|Opera.OperaGX|Opera GX|0|Browser "gaming" dengan pembatas RAM/CPU. Cocok untuk laptop RAM 8GB yang suka buka banyak tab.
7zip|Arsip & File|7zip.7zip|7-Zip|1|Gratis dan open source. Bisa buka zip/rar/7z/iso/tar. Paling aman dan ringan. REKOMENDASI.
winrar|Arsip & File|RARLab.WinRAR|WinRAR|0|Populer dan bisa MEMBUAT file .rar. Berbayar, tapi masa trialnya "abadi" (cuma muncul popup). Pilih kalau sering kirim file .rar.
nanazip|Arsip & File|M2Team.NanaZip|NanaZip|0|Fork 7-Zip dengan tampilan modern dan menu klik kanan Windows 11. Pilihan terbaik untuk Win11.
peazip|Arsip & File|Giorgiotani.Peazip|PeaZip|0|Open source, mendukung 200+ format, ada enkripsi kuat dan secure delete.
everything|Arsip & File|voidtools.Everything|Everything|1|Cari file di seluruh disk dalam hitungan milidetik. Wajib untuk yang file tugasnya berantakan.
wt|Terminal & Shell|Microsoft.WindowsTerminal|Windows Terminal|1|Terminal modern bertab: PowerShell, CMD, WSL dan Git Bash dalam satu jendela. Sudah bawaan Windows 11.
pwsh|Terminal & Shell|Microsoft.PowerShell|PowerShell 7|1|Versi PowerShell terbaru. Lebih cepat dan cross-platform dibanding PowerShell 5 bawaan.
ohmyposh|Terminal & Shell|JanDeDobbeleer.OhMyPosh|Oh My Posh|0|Tema prompt keren: tampilkan branch git, versi bahasa, waktu eksekusi. Butuh Nerd Font.
nerdfont|Terminal & Shell|DEVCOM.JetBrainsMonoNerdFont|JetBrains Mono Nerd Font|0|Font coding dengan ligature dan ikon, dipakai Oh My Posh dan terminal modern.
vscode|Editor Kode|Microsoft.VisualStudioCode|Visual Studio Code|1|Editor paling populer: ringan dan ekstensinya melimpah. Standar mahasiswa IF.
cursor|Editor Kode|Anysphere.Cursor|Cursor|0|Fork VS Code dengan AI terintegrasi (chat, autocomplete multi-baris). Ada tier gratis.
antigravity|Editor Kode|info:https://antigravity.google|Google Antigravity|0|IDE agentic dari Google (berbasis VS Code). Download manual dari situs resminya.
zed|Editor Kode|ZedIndustries.Zed|Zed|0|Editor super cepat (ditulis dengan Rust) dengan kolaborasi realtime.
sublime|Editor Kode|SublimeHQ.SublimeText.4|Sublime Text 4|0|Editor ringan dan sangat cepat. Cocok untuk laptop spek rendah.
notepadpp|Editor Kode|Notepad++.Notepad++|Notepad++|1|Editor teks ringan untuk edit cepat file config/log. Pengganti Notepad.
neovim|Editor Kode|Neovim.Neovim|Neovim|0|Editor di terminal untuk yang mau jadi "keyboard warrior". Kurva belajarnya tinggi.
intellij|IDE|JetBrains.IntelliJIDEA.Community|IntelliJ IDEA Community|0|IDE terbaik untuk Java/Kotlin. Wajib kalau ada matkul PBO. Mahasiswa bisa dapat Ultimate gratis lewat JetBrains Student Pack.
pycharm|IDE|JetBrains.PyCharm.Community|PyCharm Community|0|IDE khusus Python dengan debugger dan pengelola virtualenv yang nyaman.
toolbox|IDE|JetBrains.Toolbox|JetBrains Toolbox|0|Satu aplikasi untuk install/update semua IDE JetBrains. Rekomendasi kalau punya lisensi Student.
vs2022|IDE|Microsoft.VisualStudio.2022.Community|Visual Studio 2022 Community|0|IDE berat (8GB+) untuk C#, .NET, C++ Windows dan Unity. Pilih kalau ada matkul C#/.NET.
netbeans|IDE|Apache.NetBeans|Apache NetBeans|0|IDE Java yang masih sering dipakai dosen untuk Java Swing/GUI.
codeblocks|IDE|CodeBlocks.CodeBlocks|Code::Blocks|0|IDE C/C++ klasik, sering dipakai di praktikum Algoritma semester 1.
devcpp|IDE|Embarcadero.Dev-C++|Embarcadero Dev-C++|0|IDE C++ sederhana yang sering dipakai di praktikum Dasar Pemrograman.
mingw|Bahasa & Runtime|BrechtSanders.WinLibs.POSIX.UCRT|WinLibs MinGW-w64 (GCC/G++)|1|Compiler C/C++ (gcc, g++, gdb). Wajib untuk Algoritma dan Struktur Data.
msys2|Bahasa & Runtime|MSYS2.MSYS2|MSYS2|0|Lingkungan mirip Unix + pacman untuk toolchain GCC/Clang. Alternatif MinGW yang lebih fleksibel.
cmake|Bahasa & Runtime|Kitware.CMake|CMake|0|Build system untuk proyek C/C++ besar.
python|Bahasa & Runtime|Python.Python.3.12|Python 3.12|1|Bahasa wajib untuk algoritma, data science, AI dan scripting. PATH diatur otomatis.
uv|Bahasa & Runtime|astral-sh.uv|uv (Python package manager)|0|Pengganti pip + venv yang 10-100x lebih cepat. Modern, cocok untuk proyek baru.
miniconda|Bahasa & Runtime|Anaconda.Miniconda3|Miniconda|0|Manajer environment Python untuk data science/ML. Lebih ringan dari Anaconda full.
nodejs|Bahasa & Runtime|OpenJS.NodeJS.LTS|Node.js LTS|1|Runtime JavaScript + npm. Wajib untuk web dev (React, Vue, Express). JANGAN dipasang bareng NVM.
nvm|Bahasa & Runtime|CoreyButler.NVMforWindows|NVM for Windows|0|Untuk gonta-ganti versi Node.js. Pilih ini ATAU Node.js LTS, jangan dua-duanya.
bun|Bahasa & Runtime|Oven-sh.Bun|Bun|0|Runtime JS super cepat sekaligus package manager. Alternatif modern npm.
jdk|Bahasa & Runtime|EclipseAdoptium.Temurin.21.JDK|Java JDK 21 (Temurin)|1|JDK LTS gratis. Wajib untuk PBO/Java dan Android.
jdk17|Bahasa & Runtime|EclipseAdoptium.Temurin.17.JDK|Java JDK 17 (Temurin)|0|Versi LTS lama, kadang diminta dosen atau proyek lama.
go|Bahasa & Runtime|GoLang.Go|Go|0|Bahasa backend modern: cepat dan simpel. Banyak dipakai startup.
rust|Bahasa & Runtime|Rustlang.Rustup|Rust (rustup)|0|Bahasa sistem yang aman memori. Butuh Visual C++ Build Tools.
php|Bahasa & Runtime|PHP.PHP.8.3|PHP 8.3 (standalone)|0|PHP CLI tanpa XAMPP. Tidak perlu kalau sudah pakai XAMPP/Laragon.
composer|Bahasa & Runtime|Composer.Composer|Composer|0|Package manager PHP, wajib untuk Laravel.
dotnet|Bahasa & Runtime|Microsoft.DotNet.SDK.8|.NET SDK 8|0|Untuk C#, ASP.NET dan Blazor.
r|Bahasa & Runtime|RProject.R|R|0|Bahasa statistik, sering dipakai di matkul Statistika/Data Mining.
xampp|Web Server & Database|ApacheFriends.Xampp.8.2|XAMPP 8.2|1|Apache + MariaDB + PHP + phpMyAdmin dalam satu paket. Standar praktikum Pemrograman Web.
laragon|Web Server & Database|LeNgocKhoa.Laragon|Laragon|0|Alternatif XAMPP yang lebih ringan dan cepat, dengan virtual host otomatis (proyek.test). Favorit anak Laravel.
mysql|Web Server & Database|Oracle.MySQL|MySQL Server|0|MySQL resmi versi standalone. Jangan dipasang bareng XAMPP karena bentrok port 3306.
postgres|Web Server & Database|PostgreSQL.PostgreSQL.16|PostgreSQL 16|0|Database relasional open source paling canggih, banyak dipakai industri.
mongodb|Web Server & Database|MongoDB.Server|MongoDB Community Server|0|Database NoSQL berbasis dokumen, populer di stack MERN.
sqlite|Web Server & Database|SQLite.SQLite|SQLite CLI|0|Database satu file, cocok untuk aplikasi kecil dan mobile.
dbeaver|Web Server & Database|dbeaver.dbeaver|DBeaver Community|1|Satu aplikasi untuk SEMUA database (MySQL, Postgres, SQLite, Oracle...). Bisa bikin ERD otomatis.
heidisql|Web Server & Database|HeidiSQL.HeidiSQL|HeidiSQL|0|Client MySQL/MariaDB yang super ringan.
workbench|Web Server & Database|Oracle.MySQLWorkbench|MySQL Workbench|0|Tool resmi MySQL. Kuat untuk desain ERD dan forward engineering.
compass|Web Server & Database|MongoDB.Compass.Full|MongoDB Compass|0|GUI untuk MongoDB.
tableplus|Web Server & Database|TablePlus.TablePlus|TablePlus|0|Client database dengan UI paling cantik. Versi gratis dibatasi 2 tab.
git|Git & API|Git.Git|Git|1|Version control wajib, sudah termasuk Git Bash.
ghdesktop|Git & API|GitHub.GitHubDesktop|GitHub Desktop|1|Git versi GUI, cocok untuk pemula sebelum lancar command line.
ghcli|Git & API|GitHub.cli|GitHub CLI (gh)|1|Login GitHub, clone, bikin repo dan PR langsung dari terminal. 'gh auth login' cara autentikasi paling mudah.
lazygit|Git & API|JesseDuffield.lazygit|lazygit|0|UI Git di terminal. Cepat untuk staging, commit dan rebase.
postman|Git & API|Postman.Postman|Postman|1|Tes REST API. Standar industri untuk matkul Web Service/Backend.
bruno|Git & API|Bruno.Bruno|Bruno|0|Alternatif Postman yang open source dan offline. Koleksinya disimpan sebagai file sehingga bisa masuk git.
docker|DevOps & Cloud|Docker.DockerDesktop|Docker Desktop|0|Container untuk menjalankan database/app tanpa install manual. Butuh WSL2 dan RAM 8GB+.
kubectl|DevOps & Cloud|Kubernetes.kubectl|kubectl|0|CLI untuk Kubernetes.
terraform|DevOps & Cloud|Hashicorp.Terraform|Terraform|0|Infrastructure as Code.
awscli|DevOps & Cloud|Amazon.AWSCLI|AWS CLI|0|CLI Amazon Web Services. Mahasiswa bisa ikut AWS Academy.
gcloud|DevOps & Cloud|Google.CloudSDK|Google Cloud SDK|0|CLI Google Cloud.
azcli|DevOps & Cloud|Microsoft.AzureCLI|Azure CLI|0|CLI Microsoft Azure. Mahasiswa dapat kredit gratis lewat Azure for Students.
ngrok|DevOps & Cloud|Ngrok.Ngrok|ngrok|0|Membuat localhost bisa diakses publik. Berguna untuk demo ke dosen atau tes webhook.
ollama|AI & Data|Ollama.Ollama|Ollama|0|Jalankan LLM (Llama, Gemma, Qwen) secara lokal dan offline. Nyaman di RAM 16GB.
lmstudio|AI & Data|ElementLabs.LMStudio|LM Studio|0|GUI untuk download dan chat dengan LLM lokal.
claude|AI & Data|Anthropic.Claude|Claude Desktop|0|Aplikasi desktop Claude.
rstudio|AI & Data|Posit.RStudio|RStudio|0|IDE untuk R (R harus terinstall).
androidstudio|Mobile & Game|Google.AndroidStudio|Android Studio|0|IDE resmi Android + emulator. Berat: RAM minimal 8GB, nyaman 16GB.
flutter|Mobile & Game|info:https://docs.flutter.dev/get-started/install/windows|Flutter SDK|0|Framework mobile cross-platform. Install manual, atau lewat ekstensi VS Code "Flutter" yang bisa download SDK otomatis.
wsa|Mobile & Game|info:https://learn.microsoft.com/windows/android/wsa/|Windows Subsystem for Android (WSA)|0|SUDAH DIHENTIKAN Microsoft sejak 5 Maret 2025 dan tidak bisa diinstall lagi. Alternatif: Android Studio Emulator, BlueStacks, atau Google Play Games.
bluestacks|Mobile & Game|BlueStack.BlueStacks|BlueStacks|0|Emulator Android untuk menjalankan APK di Windows. Pengganti WSA.
unity|Mobile & Game|Unity.UnityHub|Unity Hub|0|Engine game 2D/3D paling populer, pakai C#.
godot|Mobile & Game|GodotEngine.GodotEngine|Godot Engine|0|Engine game open source, ringan, cocok untuk pemula.
blender|Mobile & Game|BlenderFoundation.Blender|Blender|0|Modeling dan animasi 3D gratis.
arduino|Mobile & Game|ArduinoSA.IDE.stable|Arduino IDE|0|Untuk matkul IoT/Sistem Embedded.
packettracer|Jaringan & Keamanan|info:https://www.netacad.com/resources/lab-downloads|Cisco Packet Tracer|0|Simulasi jaringan Cisco untuk matkul Jaringan Komputer. Download manual (butuh akun NetAcad gratis).
wireshark|Jaringan & Keamanan|WiresharkFoundation.Wireshark|Wireshark|0|Analisis paket jaringan. Wajib untuk matkul Jarkom/Keamanan.
nmap|Jaringan & Keamanan|Insecure.Nmap|Nmap|0|Port scanner. Pakai hanya di jaringan milik sendiri atau yang sudah diizinkan.
putty|Jaringan & Keamanan|PuTTY.PuTTY|PuTTY|0|Klien SSH/Telnet/Serial klasik. Windows sudah punya ssh bawaan.
mobaxterm|Jaringan & Keamanan|Mobatek.MobaXterm|MobaXterm|0|Terminal SSH all-in-one dengan SFTP browser dan X11. Favorit abang server.
winscp|Jaringan & Keamanan|WinSCP.WinSCP|WinSCP|0|Transfer file ke server lewat SFTP/SCP dengan GUI.
filezilla|Jaringan & Keamanan|TimKosse.FileZilla.Client|FileZilla|0|Klien FTP/SFTP untuk upload ke hosting.
advancedip|Jaringan & Keamanan|Famatech.AdvancedIPScanner|Advanced IP Scanner|0|Scan perangkat di jaringan lokal dan cek IP yang terpakai.
burp|Jaringan & Keamanan|PortSwigger.BurpSuite.Community|Burp Suite Community|0|Proxy untuk pentest aplikasi web. Gunakan secara etis.
wireguard|Jaringan & Keamanan|WireGuard.WireGuard|WireGuard|0|VPN modern yang cepat.
wslcore|Virtualisasi & Linux|wsl:core|WSL2 (Windows Subsystem for Linux)|1|Linux asli di Windows tanpa dual boot. Dibutuhkan Docker dan banyak tool dev. Virtualisasi di BIOS harus aktif, lalu restart.
wsl-ubuntu|Virtualisasi & Linux|wsl:Ubuntu|Ubuntu (WSL)|1|Distro paling populer dan paling banyak tutorialnya. Rekomendasi untuk pemula.
wsl-debian|Virtualisasi & Linux|wsl:Debian|Debian (WSL)|0|Distro yang stabil dan ringan.
wsl-kali|Virtualisasi & Linux|wsl:kali-linux|Kali Linux (WSL)|0|Distro untuk belajar keamanan siber/pentest.
sandbox|Virtualisasi & Linux|feat:Containers-DisposableClientVM|Windows Sandbox|0|Windows "sekali pakai" untuk tes aplikasi mencurigakan. Hanya Windows Pro/Education.
virtualbox|Virtualisasi & Linux|Oracle.VirtualBox|VirtualBox|0|Mesin virtual gratis untuk install Linux/Windows lain (matkul Sistem Operasi).
figma|Desain & Multimedia|Figma.Figma|Figma|1|Desain UI/UX dan prototipe. Ada Figma Education gratis.
drawio|Desain & Multimedia|JGraph.Draw|draw.io Desktop|1|Flowchart, UML, ERD dan DFD secara offline. Wajib untuk matkul RPL/Analisis Sistem.
gimp|Desain & Multimedia|GIMP.GIMP.3|GIMP|0|Edit foto gratis, alternatif Photoshop.
inkscape|Desain & Multimedia|Inkscape.Inkscape|Inkscape|0|Desain vektor gratis, alternatif Illustrator.
obs|Desain & Multimedia|OBSProject.OBSStudio|OBS Studio|0|Rekam layar/presentasi dan live streaming. Berguna untuk video demo tugas.
sharex|Desain & Multimedia|ShareX.ShareX|ShareX|1|Screenshot, rekam layar, GIF dan OCR. Jauh lebih lengkap dari Snipping Tool.
vlc|Desain & Multimedia|VideoLAN.VLC|VLC Media Player|1|Pemutar semua format video.
discord|Komunikasi|Discord.Discord|Discord|1|Grup kelas, komunitas programmer, voice call kerja kelompok.
zoom|Komunikasi|Zoom.Zoom|Zoom|1|Kuliah online dan sidang.
telegram|Komunikasi|Telegram.TelegramDesktop|Telegram|0|Banyak grup/komunitas IT dan bot.
slack|Komunikasi|SlackTechnologies.Slack|Slack|0|Komunikasi tim ala industri, sering dipakai saat magang.
teams|Komunikasi|Microsoft.Teams|Microsoft Teams|0|Dipakai beberapa kampus untuk kelas online.
notion|Kuliah & Produktivitas|Notion.Notion|Notion|0|Catatan, task manager dan wiki. Ada plan Education gratis.
obsidian|Kuliah & Produktivitas|Obsidian.Obsidian|Obsidian|0|Catatan Markdown offline dengan graph view. Cocok jadi second brain.
zotero|Kuliah & Produktivitas|DigitalScholar.Zotero|Zotero|0|Manajer referensi dan sitasi otomatis untuk skripsi/jurnal.
office|Kuliah & Produktivitas|info:https://www.office.com|Microsoft 365 (email kampus)|0|Biasanya GRATIS pakai email kampus. Login di office.com lalu klik Install Apps.
libreoffice|Kuliah & Produktivitas|TheDocumentFoundation.LibreOffice|LibreOffice|0|Office gratis. Tidak perlu kalau sudah punya Microsoft 365 dari kampus.
sumatra|Kuliah & Produktivitas|SumatraPDF.SumatraPDF|SumatraPDF|1|Pembaca PDF super ringan, modul kuliah terbuka instan.
acrobat|Kuliah & Produktivitas|Adobe.Acrobat.Reader.64-bit|Adobe Acrobat Reader|0|Pembaca PDF standar dengan fitur tanda tangan dan form.
gdrive|Kuliah & Produktivitas|Google.GoogleDrive|Google Drive|0|Sinkronisasi file tugas ke cloud secara otomatis.
powertoys|Utilitas Sistem|Microsoft.PowerToys|Microsoft PowerToys|1|Kumpulan tool: PowerToys Run (launcher), FancyZones, Color Picker, Text Extractor (OCR).
vcredist|Utilitas Sistem|Microsoft.VCRedist.2015+.x64|Visual C++ Redistributable|1|Library runtime yang dibutuhkan banyak aplikasi dan game. Install saja.
localsend|Utilitas Sistem|LocalSend.LocalSend|LocalSend|1|Kirim file HP ke laptop lewat WiFi tanpa kabel/internet, mirip AirDrop.
revo|Utilitas Sistem|RevoUninstaller.RevoUninstaller|Revo Uninstaller|0|Uninstall aplikasi sampai bersih ke sisa registri.
cpuz|Utilitas Sistem|CPUID.CPU-Z|CPU-Z|0|Lihat detail CPU, RAM dan motherboard.
hwinfo|Utilitas Sistem|REALiX.HWiNFO|HWiNFO|0|Monitor suhu dan sensor hardware secara lengkap.
crystaldisk|Utilitas Sistem|CrystalDewWorld.CrystalDiskInfo|CrystalDiskInfo|0|Cek kesehatan SSD/HDD.
rufus|Utilitas Sistem|Rufus.Rufus|Rufus|0|Bikin flashdisk bootable untuk install Windows/Linux.
ventoy|Utilitas Sistem|Ventoy.Ventoy|Ventoy|0|Satu flashdisk untuk banyak ISO sekaligus. Wajib untuk abang IT.
anydesk|Utilitas Sistem|AnyDesk.AnyDesk|AnyDesk|0|Remote desktop untuk bantu teman dari jauh.
rustdesk|Utilitas Sistem|RustDesk.RustDesk|RustDesk|0|Remote desktop open source, alternatif AnyDesk.
'@

$Catalog = foreach ($line in ($CatalogRaw -split "`r?`n")) {
  if (-not $line.Trim()) { continue }
  $p = $line.Trim() -split '\|', 6
  $kind = if ($p[2] -like 'wsl:*') { 'wsl' } elseif ($p[2] -like 'feat:*') { 'feat' } elseif ($p[2] -like 'info:*') { 'info' } else { 'winget' }
  [pscustomobject]@{ Key = $p[0]; Cat = $p[1]; Id = $p[2]; Name = $p[3]; Rec = ($p[4] -eq '1'); Tip = $p[5]; Kind = $kind; Installed = $false }
}
$C = @{}; foreach ($c in $Catalog) { $C[$c.Key] = $c }
$CatOrder = @(); foreach ($c in $Catalog) { if ($CatOrder -notcontains $c.Cat) { $CatOrder += $c.Cat } }
$Heavy = @('docker', 'androidstudio', 'vs2022', 'unity', 'ollama', 'lmstudio', 'virtualbox', 'bluestacks')
# Probe tambahan: aplikasi yang mungkin diinstall manual (bukan lewat winget)
$CmdProbe = @{ git = 'git'; vscode = 'code'; python = 'python'; nodejs = 'node'; jdk = 'java'; mingw = 'g++'; go = 'go'; rust = 'rustc';
  php = 'php'; dotnet = 'dotnet'; cursor = 'cursor'; antigravity = 'antigravity'; docker = 'docker'; ghcli = 'gh'; pwsh = 'pwsh'; uv = 'uv'; bun = 'bun'; cmake = 'cmake' }
$PathProbe = @{ xampp = 'C:\xampp\xampp-control.exe'; laragon = 'C:\laragon\laragon.exe'; mingw = 'C:\mingw64\bin\g++.exe';
  antigravity = "$env:LOCALAPPDATA\Programs\Antigravity\Antigravity.exe"; vscode = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe" }

$Profiles = @(
  @{ K = 'starter'; N = 'Starter Pack Mahasiswa IF (Semester 1-2)'; T = 'Paket aman untuk semua mahasiswa IF baru: browser, editor, compiler C/C++, Python, Java, Node, Git, XAMPP, tool diagram, komunikasi kuliah dan WSL Ubuntu.'
     L = 'chrome,7zip,everything,wt,pwsh,vscode,notepadpp,mingw,python,jdk,nodejs,git,ghdesktop,ghcli,xampp,dbeaver,postman,drawio,figma,discord,zoom,sumatra,sharex,vlc,powertoys,vcredist,localsend,wslcore,wsl-ubuntu' }
  @{ K = 'cpp'; N = 'C/C++ & Algoritma'; T = 'Untuk praktikum Dasar Pemrograman, Algoritma dan Struktur Data.'; L = 'mingw,cmake,codeblocks,devcpp,vscode,git' }
  @{ K = 'java'; N = 'Java & PBO'; T = 'Untuk matkul Pemrograman Berorientasi Objek.'; L = 'jdk,intellij,netbeans,vscode,git' }
  @{ K = 'web'; N = 'Web Developer (Fullstack)'; T = 'Laravel/PHP, Node.js/React, database, API testing, Docker dan tunneling untuk demo.'
     L = 'chrome,firefoxdev,vscode,nodejs,bun,git,ghcli,laragon,composer,dbeaver,postgres,postman,docker,wslcore,wsl-ubuntu,figma,ngrok' }
  @{ K = 'mobile'; N = 'Mobile Developer (Android/Flutter)'; T = 'Android Studio + emulator, JDK, Flutter dan emulator pengganti WSA.'; L = 'androidstudio,jdk,flutter,vscode,git,ghcli,figma,bluestacks,postman' }
  @{ K = 'data'; N = 'Data Science & AI'; T = 'Python + uv/conda, R/RStudio, database, LLM lokal (Ollama, LM Studio).'; L = 'python,uv,miniconda,r,rstudio,vscode,git,dbeaver,postgres,ollama,lmstudio,wslcore,wsl-ubuntu' }
  @{ K = 'net'; N = 'Jaringan & Keamanan Siber'; T = 'Packet Tracer, Wireshark, Nmap, SSH tools, Burp, VM dan Kali Linux WSL.'; L = 'packettracer,wireshark,nmap,putty,mobaxterm,winscp,advancedip,burp,virtualbox,wslcore,wsl-kali,wireguard' }
  @{ K = 'devops'; N = 'DevOps & Cloud'; T = 'Docker, Kubernetes, Terraform dan CLI ketiga cloud besar.'; L = 'docker,kubectl,terraform,awscli,gcloud,azcli,wslcore,wsl-ubuntu,git,ghcli,lazygit,vscode,mobaxterm' }
  @{ K = 'game'; N = 'Game Developer'; T = 'Unity, Godot, Blender, Visual Studio dan tool aset.'; L = 'unity,godot,blender,vs2022,vscode,gimp,inkscape,git,obs' }
  @{ K = 'design'; N = 'UI/UX & Konten Kreator'; T = 'Figma, desain vektor/raster, rekam layar.'; L = 'figma,drawio,gimp,inkscape,obs,sharex,vlc,blender' }
  @{ K = 'tech'; N = 'Abang IT / Teknisi Laptop'; T = 'Toolkit servis: cek hardware, flashdisk bootable, remote desktop, uninstaller.'
     L = '7zip,everything,powertoys,revo,cpuz,hwinfo,crystaldisk,rufus,ventoy,anydesk,rustdesk,advancedip,localsend,vcredist,sumatra,vlc' }
)

$Wizard = @(
  @{ Q = 'Browser utama?'; M = $false; L = 'chrome,brave,firefox,operagx'; T = 'Edge sudah bawaan Windows. Chrome = DevTools paling lengkap, Brave = hemat RAM + adblock, Firefox = privasi.' }
  @{ Q = 'Aplikasi kompres/ekstrak arsip?'; M = $false; L = '7zip,winrar,nanazip,peazip'; T = '7-Zip gratis dan open source (rekomendasi). WinRAR kalau perlu MEMBUAT .rar. NanaZip = 7-Zip versi Win11.' }
  @{ Q = 'Editor kode? (boleh lebih dari satu)'; M = $true; L = 'vscode,cursor,antigravity,zed,sublime,notepadpp,neovim'; T = 'VS Code cukup untuk 90% matkul. Cursor/Antigravity kalau mau coding dibantu AI.' }
  @{ Q = 'IDE tambahan sesuai matkul?'; M = $true; L = 'intellij,pycharm,toolbox,vs2022,netbeans,codeblocks,devcpp'; T = 'Java/PBO -> IntelliJ atau NetBeans. C# -> Visual Studio. Praktikum C -> Code::Blocks/Dev-C++ kalau diminta dosen.' }
  @{ Q = 'Bahasa pemrograman & runtime?'; M = $true; L = 'mingw,python,uv,nodejs,nvm,bun,jdk,jdk17,go,rust,php,composer,dotnet,r,cmake,msys2'; T = 'Minimal untuk mahasiswa IF: GCC (MinGW), Python, Java JDK dan Node.js.' }
  @{ Q = 'Web server lokal (PHP/MySQL)?'; M = $false; L = 'xampp,laragon,docker'; T = 'XAMPP = standar praktikum kampus. Laragon = lebih cepat untuk Laravel. Docker = cara industri (butuh WSL2).' }
  @{ Q = 'Database & client database?'; M = $true; L = 'dbeaver,heidisql,workbench,tableplus,mysql,postgres,mongodb,compass,sqlite'; T = 'DBeaver bisa untuk semua jenis database. Jangan pasang MySQL Server kalau sudah pakai XAMPP/Laragon.' }
  @{ Q = 'Git & API tools?'; M = $true; L = 'git,ghdesktop,ghcli,lazygit,postman,bruno'; T = 'Git wajib. GitHub Desktop membantu pemula. Postman untuk tes API backend.' }
  @{ Q = 'Terminal & tampilan shell?'; M = $true; L = 'wt,pwsh,ohmyposh,nerdfont'; T = 'Windows Terminal + PowerShell 7 = kombinasi terbaik. Oh My Posh + Nerd Font supaya terminal kece.' }
  @{ Q = 'Mau WSL (Linux di Windows)?'; M = $true; L = 'wslcore,wsl-ubuntu,wsl-debian,wsl-kali'; T = 'WSL dibutuhkan Docker dan sangat membantu matkul Sistem Operasi. Perlu restart. Virtualisasi BIOS: __VIRT__' }
  @{ Q = 'WSA / jalanin aplikasi Android?'; M = $false; L = 'androidstudio,bluestacks,wsa'; T = 'WSA sudah dihentikan Microsoft (Maret 2025). Untuk develop pilih Android Studio (emulator resmi). Untuk sekadar main APK pilih BlueStacks.' }
  @{ Q = 'Virtual machine?'; M = $true; L = 'virtualbox,sandbox'; T = 'VirtualBox untuk install Linux/OS lain (matkul SO). Windows Sandbox hanya ada di Windows Pro/Education.' }
  @{ Q = 'Jaringan & keamanan?'; M = $true; L = 'packettracer,wireshark,nmap,putty,mobaxterm,winscp,filezilla,advancedip,burp,wireguard'; T = 'Untuk matkul Jaringan Komputer dan Keamanan Informasi. Gunakan tool security secara etis.' }
  @{ Q = 'DevOps & Cloud?'; M = $true; L = 'kubectl,terraform,awscli,gcloud,azcli,ngrok'; T = 'Opsional. Ngrok berguna untuk demo localhost ke dosen.' }
  @{ Q = 'AI di laptop?'; M = $true; L = 'ollama,lmstudio,claude'; T = 'LLM lokal butuh RAM 16GB+ supaya nyaman. RAM laptop ini: __RAM__ GB.' }
  @{ Q = 'Mobile & game development?'; M = $true; L = 'flutter,unity,godot,blender,arduino'; T = 'Flutter untuk aplikasi mobile, Unity/Godot untuk game, Arduino untuk IoT.' }
  @{ Q = 'Desain & multimedia?'; M = $true; L = 'figma,drawio,gimp,inkscape,obs,sharex,vlc'; T = 'draw.io wajib untuk UML/ERD/flowchart. Figma untuk tugas UI/UX.' }
  @{ Q = 'Komunikasi?'; M = $true; L = 'discord,zoom,telegram,slack,teams'; T = 'Sesuaikan dengan platform yang dipakai kelas dan dosen.' }
  @{ Q = 'Kuliah & produktivitas?'; M = $true; L = 'notion,obsidian,zotero,office,libreoffice,sumatra,acrobat,gdrive'; T = 'Microsoft 365 biasanya gratis dari email kampus. Zotero menyelamatkan saat skripsi.' }
  @{ Q = 'Utilitas sistem?'; M = $true; L = 'powertoys,vcredist,localsend,everything,revo,cpuz,hwinfo,crystaldisk,rufus,ventoy,anydesk,rustdesk'; T = 'PowerToys + Everything + LocalSend = trio wajib. Sisanya untuk abang IT.' }
)

$VSExt = @(
  'ms-vscode.cpptools-extension-pack|C/C++ Extension Pack|1|IntelliSense, debugging dan CMake untuk C/C++.'
  'formulahendry.code-runner|Code Runner|1|Tombol Run untuk menjalankan file C/C++/Python/Java/JS dengan sekali klik.'
  'ms-python.python|Python|1|Dukungan Python lengkap: Pylance, debugger, venv.'
  'ms-toolsai.jupyter|Jupyter|0|Notebook .ipynb di VS Code untuk data science.'
  'vscjava.vscode-java-pack|Extension Pack for Java|1|Java: Maven/Gradle, debugger, test runner.'
  'esbenp.prettier-vscode|Prettier|1|Format otomatis JS/TS/HTML/CSS/JSON.'
  'dbaeumer.vscode-eslint|ESLint|0|Linting JavaScript/TypeScript.'
  'ritwickdey.LiveServer|Live Server|1|Preview HTML dengan auto-reload di browser.'
  'formulahendry.auto-rename-tag|Auto Rename Tag|0|Ganti tag pembuka, tag penutup ikut berubah otomatis.'
  'bradlc.vscode-tailwindcss|Tailwind CSS IntelliSense|0|Autocomplete class Tailwind.'
  'dsznajder.es7-react-js-snippets|ES7+ React Snippets|0|Snippet React (rafce, useState...).'
  'bmewburn.vscode-intelephense-client|PHP Intelephense|0|IntelliSense PHP terbaik, cocok untuk Laravel.'
  'eamodio.gitlens|GitLens|1|Lihat siapa mengubah baris mana (blame) dan riwayat commit.'
  'mhutchie.git-graph|Git Graph|1|Visualisasi branch dan commit dalam bentuk grafik.'
  'ms-azuretools.vscode-docker|Docker|0|Kelola container dan Dockerfile.'
  'ms-vscode-remote.remote-wsl|WSL|1|Buka folder di dalam WSL Linux langsung dari VS Code.'
  'ms-vscode-remote.remote-ssh|Remote - SSH|0|Coding langsung di server lewat SSH.'
  'mtxr.sqltools|SQLTools|0|Query database dari VS Code.'
  'humao.rest-client|REST Client|0|Tes API dari file .http, alternatif ringan Postman.'
  'usernamehw.errorlens|Error Lens|1|Error dan warning ditampilkan langsung di baris kode.'
  'christian-kohler.path-intellisense|Path Intellisense|1|Autocomplete nama file/path.'
  'streetsidesoftware.code-spell-checker|Code Spell Checker|0|Cek typo di kode dan komentar.'
  'yzhang.markdown-all-in-one|Markdown All in One|0|Shortcut dan preview untuk README.md.'
  'hediet.vscode-drawio|Draw.io Integration|0|Edit diagram draw.io di dalam VS Code.'
  'Dart-Code.flutter|Flutter|0|Dukungan Flutter/Dart, bisa download Flutter SDK otomatis.'
  'MS-vsliveshare.vsliveshare|Live Share|0|Ngoding bareng teman secara realtime (kerja kelompok).'
  'GitHub.copilot|GitHub Copilot|0|AI autocomplete. Gratis untuk mahasiswa lewat GitHub Student Developer Pack.'
  'PKief.material-icon-theme|Material Icon Theme|1|Ikon file yang cantik dan mudah dibedakan.'
  'zhuangtongfa.material-theme|One Dark Pro|0|Tema gelap paling populer.'
  'GitHub.github-vscode-theme|GitHub Theme|0|Tema resmi GitHub (light/dark).'
)

$Cart = New-Object System.Collections.Specialized.OrderedDictionary
$Notes = New-Object System.Collections.Generic.List[string]
$Sys = @{}

# =====================================================================================
#  UTILITAS UI
# =====================================================================================
function Log([string]$m) { Add-Content -Path $LogFile -Value ("[{0:HH:mm:ss}] {1}" -f (Get-Date), $m) }

function Wrap([string]$Text, [int]$Width) {
  $out = New-Object System.Collections.Generic.List[string]
  foreach ($para in ($Text -split "`n")) {
    $line = ''
    foreach ($word in ($para -split ' ')) {
      if ($line.Length -and ($line.Length + 1 + $word.Length) -gt $Width) { $out.Add($line); $line = $word }
      elseif ($line.Length) { $line += ' ' + $word } else { $line = $word }
    }
    $out.Add($line)
  }
  return ,$out
}

# Render satu layar penuh. Setiap baris memakai markup warna: "{Cyan}teks {Gray}teks"
function Paint([System.Collections.Generic.List[string]]$Rows) {
  $w = [Console]::WindowWidth - 1; $h = [Console]::WindowHeight
  [Console]::SetCursorPosition(0, 0)
  $n = 0
  foreach ($row in $Rows) {
    if ($n -ge $h - 1) { break }
    $parts = [regex]::Split($row, '\{(\w+)\}')
    $color = 'Gray'; $len = 0
    for ($i = 0; $i -lt $parts.Count; $i++) {
      if ($i % 2 -eq 1) { $color = $parts[$i]; continue }
      $t = $parts[$i]
      if (-not $t -or $len -ge $w) { continue }
      if ($len + $t.Length -gt $w) { $t = $t.Substring(0, $w - $len) }
      Write-Host $t -NoNewline -ForegroundColor $color; $len += $t.Length
    }
    Write-Host (' ' * [Math]::Max(0, $w - $len)); $n++
  }
  while ($n -lt $h - 1) { Write-Host (' ' * $w); $n++ }
}

$Banner = @(
  '██████╗ ███████╗██╗   ██╗███████╗███████╗████████╗██╗   ██╗██████╗ '
  '██╔══██╗██╔════╝██║   ██║██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗'
  '██║  ██║█████╗  ██║   ██║███████╗█████╗     ██║   ██║   ██║██████╔╝'
  '██║  ██║██╔══╝  ╚██╗ ██╔╝╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ '
  '██████╔╝███████╗ ╚████╔╝ ███████║███████╗   ██║   ╚██████╔╝██║     '
  '╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     '
)
$BannerColors = @('Magenta', 'Magenta', 'Cyan', 'Cyan', 'Blue', 'DarkBlue')

function MkItem($Label, $Tip = '', $Value = $null, $Badge = '', [bool]$Checked = $false, [bool]$Lock = $false, [bool]$Rec = $false, [bool]$Sep = $false) {
  [pscustomobject]@{ Label = $Label; Tip = $Tip; Value = $Value; Badge = $Badge; Checked = $Checked; Lock = $Lock; Rec = $Rec; Sep = $Sep }
}

function CatItem([string]$k) {
  $c = $C[$k]
  $b = ''
  if ($c.Installed) { $b += '{Green}√ terpasang  ' }
  elseif ($Cart.Contains($k)) { $b += '{Cyan}+ keranjang  ' }
  if ($c.Rec) { $b += '{Yellow}♦ rekomendasi  ' }
  if ($c.Kind -eq 'info') { $b += '{DarkYellow}i manual  ' }
  if ($c.Kind -eq 'wsl' -or $c.Kind -eq 'feat') { $b += '{DarkCyan}fitur Windows  ' }
  if ($Heavy -contains $k -and $Sys.Ram -and $Sys.Ram -lt 12) { $b += '{Red}! berat untuk RAM ' + $Sys.Ram + 'GB' }
  $src = switch ($c.Kind) { 'winget' { "winget: $($c.Id)" } 'wsl' { 'wsl --install' } 'feat' { 'Windows Optional Feature' } 'info' { 'Download manual: ' + $c.Id.Substring(5) } }
  $st = if ($c.Installed) { 'Status: SUDAH TERPASANG di laptop ini.' } else { 'Status: belum terpasang.' }
  MkItem $c.Name ("$($c.Tip)`n$st  |  $src") $k $b $Cart.Contains($k) $c.Installed $c.Rec
}

# Widget utama: daftar interaktif dengan panel tooltip
function Select-List {
  param([string]$Title, [string]$Sub = '', [object[]]$Items, [switch]$Multi, [switch]$Radio, [int]$Start = -1, [string[]]$Header = @(), [string]$EnterText = 'pilih')
  $idx = if ($Start -ge 0) { $Start } else { 0 }
  while ($idx -lt $Items.Count - 1 -and $Items[$idx].Sep) { $idx++ }
  $top = 0
  Clear-Host; [Console]::CursorVisible = $false
  while ($true) {
    $h = [Console]::WindowHeight; $w = [Console]::WindowWidth - 1
    $rows = New-Object System.Collections.Generic.List[string]
    foreach ($hr in $Header) { $rows.Add($hr) }
    $rows.Add("{Magenta}▓▒░ {White}DEVSETUP IF {DarkGray}│ {Cyan}$Title" + $(if ($Cart.Count) { "{DarkGray}   │ {Green}Keranjang: $($Cart.Count) item" } else { '' }))
    $rows.Add('{DarkGray}' + ('─' * $w))
    foreach ($l in (Wrap $Sub ($w - 2))) { if ($l) { $rows.Add("{Gray} $l") } }
    $fixed = $rows.Count + 11
    $view = [Math]::Max(3, $h - $fixed)
    if ($idx -lt $top) { $top = $idx }
    if ($idx -ge $top + $view) { $top = $idx - $view + 1 }
    $rows.Add($(if ($top -gt 0) { "{DarkGray}     ▲ $top lagi di atas" } else { '' }))
    $end = [Math]::Min($Items.Count, $top + $view)
    for ($i = $top; $i -lt $end; $i++) {
      $it = $Items[$i]
      if ($it.Sep) { $rows.Add("{DarkYellow}   ── {Yellow}$($it.Label) {DarkYellow}" + ('─' * [Math]::Max(0, 50 - $it.Label.Length))); continue }
      $cur = ($i -eq $idx)
      $ptr = if ($cur) { '{Yellow} ► ' } else { '   ' }
      $box = ''
      if ($Multi) { $box = if ($it.Lock) { '{Green}√ ' } elseif ($it.Checked) { '{Green}■ ' } else { '{DarkGray}□ ' } }
      elseif ($Radio) { $box = if ($it.Checked) { '{Green}● ' } else { '{DarkGray}○ ' } }
      $nc = if ($cur) { 'White' } elseif ($it.Lock) { 'DarkGray' } else { 'Gray' }
      $rows.Add("$ptr$box{$nc}$($it.Label.PadRight(38)) $($it.Badge)")
    }
    for ($i = $end - $top; $i -lt $view; $i++) { $rows.Add('') }
    $rows.Add($(if ($end -lt $Items.Count) { "{DarkGray}     ▼ $($Items.Count - $end) lagi di bawah" } else { '' }))
    # Panel tooltip
    $curIt = $Items[$idx]; $tw = $w - 4
    $titleBar = " $($curIt.Label) "
    $rows.Add('{DarkCyan}┌─{White}' + $titleBar + '{DarkCyan}' + ('─' * [Math]::Max(0, $tw - $titleBar.Length)) + '─┐')
    $tl = Wrap ([string]$curIt.Tip) $tw
    for ($i = 0; $i -lt 5; $i++) {
      $t = if ($i -lt $tl.Count) { $tl[$i] } else { '' }
      if ($t.Length -gt $tw) { $t = $t.Substring(0, $tw) }
      $col = if ($t -like 'Status: SUDAH*') { 'Green' } elseif ($t -like 'Status:*') { 'DarkGray' } else { 'Gray' }
      $rows.Add('{DarkCyan}│ {' + $col + '}' + $t.PadRight($tw) + ' {DarkCyan}│')
    }
    $rows.Add('{DarkCyan}└' + ('─' * ($tw + 2)) + '┘')
    $keys = if ($Multi) { '{White}↑↓{DarkGray} gerak  {White}Spasi{DarkGray} centang  {White}A{DarkGray} semua  {White}N{DarkGray} kosongkan  {White}R{DarkGray} rekomendasi  {White}Enter{DarkGray} ' + $EnterText + '  {White}Esc{DarkGray} kembali' }
            else { '{White}↑↓{DarkGray} gerak  {White}Enter{DarkGray} ' + $EnterText + '  {White}Esc{DarkGray} kembali' }
    $rows.Add(" $keys")
    Paint $rows

    $k = [Console]::ReadKey($true)
    $ch = ([string]$k.KeyChar).ToLower()
    $move = 0
    switch ($k.Key) {
      'UpArrow' { $move = -1 } 'DownArrow' { $move = 1 }
      'PageUp' { $move = -$view } 'PageDown' { $move = $view }
      'Home' { $idx = 0; $move = 1; $idx = -1 } 'End' { $idx = $Items.Count; $move = -1 }
      'Escape' { return [pscustomobject]@{ Ok = $false } }
      'Backspace' { return [pscustomobject]@{ Ok = $false } }
      'Enter' {
        if ($Multi) { return [pscustomobject]@{ Ok = $true; Values = @($Items | Where-Object { $_.Checked -and -not $_.Sep } | ForEach-Object { $_.Value }) } }
        return [pscustomobject]@{ Ok = $true; Value = $curIt.Value }
      }
      'Spacebar' { if ($Multi -and -not $curIt.Lock) { $curIt.Checked = -not $curIt.Checked } }
    }
    if ($ch -eq 'k') { $move = -1 } elseif ($ch -eq 'j') { $move = 1 }
    if ($Multi) {
      if ($ch -eq 'a') { foreach ($it in $Items) { if (-not $it.Lock -and -not $it.Sep) { $it.Checked = $true } } }
      if ($ch -eq 'n') { foreach ($it in $Items) { if (-not $it.Lock) { $it.Checked = $false } } }
      if ($ch -eq 'r') { foreach ($it in $Items) { if (-not $it.Lock -and -not $it.Sep) { $it.Checked = [bool]$it.Rec } } }
    }
    if ($move -ne 0) {
      $step = [Math]::Sign($move); $target = $idx + $move
      if ([Math]::Abs($move) -gt 1) { $target = [Math]::Max(0, [Math]::Min($Items.Count - 1, $target)) }
      elseif ($target -lt 0) { $target = $Items.Count - 1 } elseif ($target -ge $Items.Count) { $target = 0 }
      $guard = 0
      while ($Items[$target].Sep -and $guard -lt $Items.Count) { $target += $step; if ($target -lt 0) { $target = $Items.Count - 1 }; if ($target -ge $Items.Count) { $target = 0 }; $guard++ }
      $idx = $target
    }
  }
}

function Ask([string]$Q, [string]$Def = '') {
  [Console]::CursorVisible = $true
  Write-Host "  ? " -NoNewline -ForegroundColor Magenta; Write-Host $Q -NoNewline -ForegroundColor White
  if ($Def) { Write-Host " [$Def]" -NoNewline -ForegroundColor DarkGray }
  Write-Host ': ' -NoNewline
  $a = Read-Host
  if (-not $a) { $a = $Def }
  return $a
}
function YesNo([string]$Q, [bool]$Def = $true) {
  $a = Ask "$Q (y/n)" $(if ($Def) { 'y' } else { 'n' })
  return ($a -match '^(y|ya|yes)$')
}
function Pause-Key { Write-Host "`n  Tekan tombol apa saja untuk kembali..." -ForegroundColor DarkGray; [void][Console]::ReadKey($true) }
function Line([string]$t, [string]$c = 'Gray') { Write-Host $t -ForegroundColor $c }
function Bar([int]$Done, [int]$Total, [int]$Width = 34) {
  $f = if ($Total) { [int][Math]::Round($Width * $Done / $Total) } else { 0 }
  return ('█' * $f) + ('░' * ($Width - $f)) + (' {0,3}%' -f $(if ($Total) { [int](100 * $Done / $Total) } else { 0 }))
}

function Invoke-Spin([string]$File, [string]$ArgStr, [string]$Label) {
  $o = Join-Path $env:TEMP 'devsetup_out.txt'; $e = Join-Path $env:TEMP 'devsetup_err.txt'
  $p = Start-Process -FilePath $File -ArgumentList $ArgStr -NoNewWindow -PassThru -RedirectStandardOutput $o -RedirectStandardError $e
  $null = $p.Handle
  $fr = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
  if ($Host.Name -eq 'ConsoleHost' -and -not $env:WT_SESSION) { $fr = @('|', '/', '-', '\') }  # conhost lama tidak punya font braille
  $sw = [Diagnostics.Stopwatch]::StartNew(); $i = 0
  while (-not $p.HasExited) {
    Write-Host ("`r   {0} {1}  {2:mm\:ss}   " -f $fr[$i % $fr.Count], $Label, $sw.Elapsed) -NoNewline -ForegroundColor Cyan
    $i++; Start-Sleep -Milliseconds 100
  }
  $p.WaitForExit()
  Log "=== $File $ArgStr (exit $($p.ExitCode))"
  Get-Content $o, $e -ErrorAction SilentlyContinue | ForEach-Object { Add-Content $LogFile $_ }
  return [pscustomobject]@{ Code = $p.ExitCode; Secs = [int]$sw.Elapsed.TotalSeconds }
}

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

# =====================================================================================
#  DETEKSI SISTEM & APLIKASI TERPASANG
# =====================================================================================
function Get-SysInfo {
  try {
    $os = Get-CimInstance Win32_OperatingSystem; $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $cs = Get-CimInstance Win32_ComputerSystem
    $Sys.OS = "$($os.Caption) (build $($os.BuildNumber))"
    $Sys.CPU = ($cpu.Name -replace '\s+', ' ').Trim(); $Sys.Cores = "$($cpu.NumberOfCores) core / $($cpu.NumberOfLogicalProcessors) thread"
    $Sys.Ram = [int][Math]::Round($cs.TotalPhysicalMemory / 1GB)
    $Sys.Model = "$($cs.Manufacturer) $($cs.Model)"
    $Sys.Virt = if ($cs.HypervisorPresent) { 'AKTIF (hypervisor berjalan)' } elseif ($cpu.VirtualizationFirmwareEnabled) { 'AKTIF di BIOS' } else { 'TIDAK AKTIF - nyalakan Intel VT-x/AMD-V (SVM) di BIOS' }
    $d = Get-PSDrive C; $Sys.Disk = '{0:N0} GB kosong dari {1:N0} GB' -f ($d.Free / 1GB), (($d.Used + $d.Free) / 1GB)
    $Sys.DiskFree = [int]($d.Free / 1GB)
  } catch { $Sys.OS = 'Windows'; $Sys.Virt = 'tidak diketahui' }
  $Sys.Winget = try { (winget --version) 2>$null } catch { $null }
  $Sys.Net = try { [void][Net.Dns]::GetHostAddresses('github.com'); $true } catch { $false }
  $Sys.User = $env:USERNAME
}

function Scan-Installed([switch]$Quiet) {
  $ids = @{}
  if ($Sys.Winget) {
    $f = Join-Path $env:TEMP 'devsetup_export.json'
    Remove-Item $f -ErrorAction SilentlyContinue
    if ($Quiet) { winget export -o $f --accept-source-agreements --disable-interactivity *> $null }
    else { $null = Invoke-Spin 'winget' "export -o `"$f`" --accept-source-agreements --disable-interactivity" 'Memindai aplikasi terpasang (winget)...' }
    if (Test-Path $f) {
      try { (Get-Content $f -Raw | ConvertFrom-Json).Sources | ForEach-Object { $_.Packages } | ForEach-Object { $ids[$_.PackageIdentifier.ToLower()] = 1 } } catch {}
    }
  }
  Refresh-Path
  $env:WSL_UTF8 = '1'
  $distros = @()
  $wslOk = $false
  if (Test-Path "$env:windir\System32\wsl.exe") {
    $st = (& wsl.exe --status 2>&1 | Out-String) -replace "`0", ''
    $wslOk = ($LASTEXITCODE -eq 0) -and ($st -notmatch 'not installed|tidak diinstal|--install')
    $distros = (& wsl.exe -l -q 2>$null | Out-String) -replace "`0", '' -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  }
  foreach ($c in $Catalog) {
    $hit = $false
    switch ($c.Kind) {
      'winget' { $hit = $ids.ContainsKey($c.Id.ToLower()) }
      'wsl' { $hit = if ($c.Id -eq 'wsl:core') { $wslOk } else { [bool]($distros | Where-Object { $_ -like "$($c.Id.Substring(4))*" }) } }
      'feat' { if ($IsAdmin) { try { $hit = (Get-WindowsOptionalFeature -Online -FeatureName $c.Id.Substring(5) -ErrorAction Stop).State -eq 'Enabled' } catch {} } }
    }
    if (-not $hit -and $CmdProbe.ContainsKey($c.Key)) {
      $cmd = Get-Command $CmdProbe[$c.Key] -ErrorAction SilentlyContinue | Where-Object { $_.Source -notlike '*WindowsApps*' } | Select-Object -First 1
      $hit = [bool]$cmd
    }
    if (-not $hit -and $PathProbe.ContainsKey($c.Key)) { $hit = Test-Path $PathProbe[$c.Key] }
    $c.Installed = $hit
    if ($hit -and $Cart.Contains($c.Key)) { $Cart.Remove($c.Key) }
  }
}

# =====================================================================================
#  LAYAR-LAYAR
# =====================================================================================
function Show-Boot {
  Clear-Host; [Console]::CursorVisible = $false
  Write-Host ''
  for ($i = 0; $i -lt $Banner.Count; $i++) {
    Write-Host ('  ' + $Banner[$i]) -ForegroundColor $BannerColors[$i]
    if (-not $NoAnim) { Start-Sleep -Milliseconds 70 }
  }
  $tag = '      I F   ·   Installer Toolkit Mahasiswa Teknik Informatika & Abang IT   ·   v2.0'
  Write-Host ''
  if ($NoAnim) { Write-Host $tag -ForegroundColor DarkGray }
  else { foreach ($ch in $tag.ToCharArray()) { Write-Host $ch -NoNewline -ForegroundColor DarkGray; Start-Sleep -Milliseconds 6 }; Write-Host '' }
  Write-Host ''
  $checks = @(
    @{ L = 'Membaca informasi sistem'; A = { Get-SysInfo; $true } }
    @{ L = 'Hak akses Administrator'; A = { $IsAdmin } }
    @{ L = 'Package manager winget'; A = { [bool]$Sys.Winget } }
    @{ L = 'Koneksi internet'; A = { $Sys.Net } }
  )
  foreach ($c in $checks) {
    Write-Host ('  [ .... ] ' + $c.L) -NoNewline -ForegroundColor DarkGray
    $ok = & $c.A
    if (-not $NoAnim) { Start-Sleep -Milliseconds 120 }
    if ($ok) { Write-Host "`r  [  OK  ] " -NoNewline -ForegroundColor Green } else { Write-Host "`r  [ WARN ] " -NoNewline -ForegroundColor Yellow }
    Write-Host $c.L -ForegroundColor Gray
  }
  Write-Host ''
  Line "     Laptop : $($Sys.Model)" DarkCyan
  Line "     OS     : $($Sys.OS)" DarkCyan
  Line "     CPU    : $($Sys.CPU)  ($($Sys.Cores))" DarkCyan
  Line "     RAM    : $($Sys.Ram) GB      Disk C: $($Sys.Disk)" DarkCyan
  Line "     Virt.  : $($Sys.Virt)" DarkCyan
  Write-Host ''
  if (-not $Sys.Winget) {
    Line '  winget tidak ditemukan! Install/update "App Installer" dari Microsoft Store:' Red
    Line '  https://apps.microsoft.com/detail/9NBLGGH4NNS1   lalu jalankan ulang script ini.' Yellow
    Start-Process 'ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1' -ErrorAction SilentlyContinue
    Pause-Key; exit 1
  }
  if (-not $Sys.Net) { Line '  Tidak ada internet. Instalasi butuh koneksi, cek WiFi dulu ya.' Yellow }
  if ($Sys.DiskFree -and $Sys.DiskFree -lt 20) { Line "  Disk C tinggal $($Sys.DiskFree) GB. Paket berat seperti Android Studio/VS bisa gagal." Yellow }
  if (-not $IsAdmin) {
    Line '  Script tidak berjalan sebagai Administrator: akan banyak popup UAC dan WSL/fitur Windows tidak bisa dipasang.' Yellow
    if (YesNo 'Jalankan ulang sebagai Administrator sekarang?' $true) {
      $a = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""; if ($Preset) { $a += " -Preset $Preset" }
      Start-Process powershell -Verb RunAs -ArgumentList $a; exit
    }
  }
  [Console]::CursorVisible = $false
  winget source update --disable-interactivity *> $null
  Scan-Installed
  $n = @($Catalog | Where-Object Installed).Count
  Write-Host "`r   √ Pemindaian selesai: $n dari $($Catalog.Count) aplikasi di katalog sudah terpasang.               " -ForegroundColor Green
  if (-not $NoAnim) { Start-Sleep -Milliseconds 900 }
}

function Sync-Cart([string[]]$Keys, [string[]]$Chosen) {
  foreach ($k in $Keys) {
    if ($Chosen -contains $k -and -not $C[$k].Installed) { if (-not $Cart.Contains($k)) { $Cart.Add($k, $true) } }
    elseif ($Cart.Contains($k)) { $Cart.Remove($k) }
  }
}

function Run-Wizard {
  $i = 0
  while ($i -lt $Wizard.Count) {
    $q = $Wizard[$i]; $keys = $q.L -split ','
    $tip = $q.T -replace '__VIRT__', $Sys.Virt -replace '__RAM__', $Sys.Ram
    $items = @($keys | ForEach-Object { CatItem $_ })
    $prog = "Pertanyaan $($i + 1)/$($Wizard.Count)  " + ('●' * ($i + 1)) + ('○' * ($Wizard.Count - $i - 1))
    if ($q.M) {
      $r = Select-List -Title "Wizard │ $prog" -Sub "$($q.Q)`n$tip" -Items $items -Multi -EnterText 'simpan & lanjut'
    } else {
      foreach ($it in $items) { $it.Checked = $Cart.Contains($it.Value) -or $C[$it.Value].Installed }
      $items += MkItem 'Lewati / tidak perlu' 'Tidak memilih apa pun untuk pertanyaan ini.' '__skip'
      $start = 0; for ($j = 0; $j -lt $items.Count; $j++) { if ($items[$j].Checked) { $start = $j; break } elseif ($items[$j].Rec -and $start -eq 0) { $start = $j } }
      $r = Select-List -Title "Wizard │ $prog" -Sub "$($q.Q)`n$tip" -Items $items -Radio -Start $start -EnterText 'pilih & lanjut'
    }
    if (-not $r.Ok) { if ($i -eq 0) { return } else { $i--; continue } }
    if ($q.M) { Sync-Cart $keys $r.Values } else { Sync-Cart $keys @($r.Value) }
    $i++
  }
  Review-Install
}

function Pick-Profile {
  while ($true) {
    $items = foreach ($p in $Profiles) {
      $ks = $p.L -split ','; $done = @($ks | Where-Object { $C[$_].Installed }).Count
      $names = ($ks | ForEach-Object { $C[$_].Name }) -join ', '
      MkItem $p.N "$($p.T)`nIsi: $names" $p.K ("{DarkGray}$($ks.Count) aplikasi  " + $(if ($done) { "{Green}$done sudah ada" } else { '' }))
    }
    $r = Select-List -Title 'Profil Siap Pakai' -Sub 'Pilih profil sesuai minat/peminatan. Isinya masih bisa kamu centang/hapus sebelum dimasukkan keranjang.' -Items $items
    if (-not $r.Ok) { return }
    $p = $Profiles | Where-Object { $_.K -eq $r.Value }
    $ks = $p.L -split ','
    $its = @($ks | ForEach-Object { $x = CatItem $_; if (-not $x.Lock) { $x.Checked = $true }; $x })
    $r2 = Select-List -Title "Profil │ $($p.N)" -Sub 'Semua sudah dicentang. Hapus centang yang tidak perlu, lalu Enter untuk memasukkan ke keranjang.' -Items $its -Multi -EnterText 'masukkan keranjang'
    if ($r2.Ok) { Sync-Cart $ks $r2.Values; if (YesNo 'Langsung ke keranjang & install sekarang?' $true) { Review-Install; return } }
  }
}

function Browse-Category {
  while ($true) {
    $items = foreach ($cat in $CatOrder) {
      $all = @($Catalog | Where-Object Cat -eq $cat)
      $ins = @($all | Where-Object Installed).Count; $inCart = @($all | Where-Object { $Cart.Contains($_.Key) }).Count
      MkItem $cat (($all | ForEach-Object { $_.Name }) -join ', ') $cat ("{DarkGray}$($all.Count) app  {Green}$ins terpasang  " + $(if ($inCart) { "{Cyan}$inCart di keranjang" } else { '' }))
    }
    $items += MkItem '» Semua aplikasi (satu daftar panjang)' 'Tampilkan seluruh katalog sekaligus, dikelompokkan per kategori.' '__all'
    $r = Select-List -Title 'Pilih Manual per Kategori' -Sub 'Pilih kategori untuk melihat isinya. Yang sudah terpasang ditandai √ dan tidak bisa dicentang.' -Items $items
    if (-not $r.Ok) { return }
    if ($r.Value -eq '__all') { Show-All; continue }
    $keys = @($Catalog | Where-Object Cat -eq $r.Value | ForEach-Object Key)
    $r2 = Select-List -Title "Kategori │ $($r.Value)" -Items @($keys | ForEach-Object { CatItem $_ }) -Multi -EnterText 'simpan'
    if ($r2.Ok) { Sync-Cart $keys $r2.Values }
  }
}

function Show-All {
  $items = New-Object System.Collections.Generic.List[object]
  foreach ($cat in $CatOrder) {
    $all = @($Catalog | Where-Object Cat -eq $cat)
    $items.Add((MkItem "$cat  ($(@($all | Where-Object Installed).Count)/$($all.Count))" '' $null '' $false $true $false $true))
    foreach ($c in $all) { $items.Add((CatItem $c.Key)) }
  }
  $n = @($Catalog | Where-Object Installed).Count
  $r = Select-List -Title "Cek Status │ $n/$($Catalog.Count) terpasang" -Sub 'Semua aplikasi di katalog beserta statusnya. Centang yang belum ada untuk dimasukkan keranjang.' -Items $items.ToArray() -Multi -EnterText 'simpan ke keranjang'
  if ($r.Ok) { Sync-Cart @($Catalog | ForEach-Object Key) $r.Values }
  # Simpan laporan status
  $rep = Join-Path $Root 'laporan-status.txt'
  $txt = @("LAPORAN DEVSETUP IF - $(Get-Date)", "Laptop: $($Sys.Model) | $($Sys.OS) | RAM $($Sys.Ram) GB", '')
  foreach ($cat in $CatOrder) { $txt += "[$cat]"; foreach ($c in ($Catalog | Where-Object Cat -eq $cat)) { $txt += ('  {0} {1}' -f $(if ($c.Installed) { '[v]' } else { '[ ]' }), $c.Name) } }
  $txt | Set-Content $rep -Encoding UTF8
}

function Review-Install {
  if (-not $Cart.Count) { Clear-Host; Line "`n  Keranjang masih kosong. Pilih aplikasi lewat Wizard, Profil, atau Kategori dulu." Yellow; Pause-Key; return }
  $keys = @($Cart.Keys)
  $items = @($keys | ForEach-Object { $x = CatItem $_; $x.Checked = $true; $x })
  $heavy = @($keys | Where-Object { $Heavy -contains $_ })
  $sub = "$($keys.Count) aplikasi siap dipasang. Hapus centang untuk membatalkan item. Enter = MULAI INSTALL."
  if ($heavy.Count) { $sub += "`nPaket berat: " + (($heavy | ForEach-Object { $C[$_].Name }) -join ', ') + ' (download besar, butuh waktu).' }
  if ($keys -contains 'nodejs' -and $keys -contains 'nvm') { $sub += "`nPERINGATAN: Node.js LTS dan NVM sebaiknya tidak dipasang bersamaan." }
  if ($keys -contains 'mysql' -and ($keys -contains 'xampp' -or $C['xampp'].Installed)) { $sub += "`nPERINGATAN: MySQL Server bisa bentrok port 3306 dengan XAMPP." }
  $r = Select-List -Title 'Keranjang Instalasi' -Sub $sub -Items $items -Multi -EnterText 'MULAI INSTALL'
  if (-not $r.Ok) { return }
  Sync-Cart $keys $r.Values
  if ($Cart.Count) { Install-Cart }
}

function Install-Cart {
  $list = @($Cart.Keys | ForEach-Object { $C[$_] })
  # urutan: fitur Windows dulu, lalu winget, lalu info manual
  $list = @($list | Sort-Object { switch ($_.Kind) { 'feat' { 0 } 'wsl' { 1 } 'winget' { 2 } 'info' { 3 } } })
  Clear-Host; [Console]::CursorVisible = $false
  Write-Host ''
  for ($i = 0; $i -lt $Banner.Count; $i++) { Write-Host ('  ' + $Banner[$i]) -ForegroundColor $BannerColors[$i] }
  Write-Host "`n  ═══ INSTALASI DIMULAI · $($list.Count) item · log: $LogFile`n" -ForegroundColor Magenta
  $res = @{ ok = 0; skip = 0; fail = 0; info = 0 }; $failed = @(); $reboot = $false
  $n = 0; $total = $list.Count; $swAll = [Diagnostics.Stopwatch]::StartNew()
  foreach ($c in $list) {
    $n++
    Write-Host ('  ' + (Bar ($n - 1) $total) + "  [$n/$total] ") -NoNewline -ForegroundColor DarkMagenta
    Write-Host $c.Cat -ForegroundColor DarkGray
    $status = 'fail'; $msg = ''; $secs = 0
    switch ($c.Kind) {
      'winget' {
        $r = Invoke-Spin 'winget' "install --id $($c.Id) --exact --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --source winget" "Menginstall $($c.Name)"
        $secs = $r.Secs
        switch ($r.Code) {
          0 { $status = 'ok' }
          -1978335189 { $status = 'skip'; $msg = 'sudah versi terbaru' }
          -1978335135 { $status = 'skip'; $msg = 'sudah terpasang' }
          { $_ -in 3010, 1641, -1978335215 } { $status = 'ok'; $reboot = $true; $msg = 'perlu restart' }
          -1978335212 { $msg = 'paket tidak ditemukan di winget' }
          default { $msg = 'kode {0} (0x{0:X8})' -f $r.Code }
        }
      }
      'wsl' {
        if (-not $IsAdmin) { $msg = 'butuh Administrator' }
        else {
          $a = if ($c.Id -eq 'wsl:core') { '--install --no-distribution' } else { "--install -d $($c.Id.Substring(4)) --no-launch" }
          $r = Invoke-Spin 'wsl.exe' $a "Memasang $($c.Name)"; $secs = $r.Secs
          if ($r.Code -eq 0) { $status = 'ok'; $reboot = $true; $msg = 'aktif setelah restart' } else { $msg = "kode $($r.Code) (cek virtualisasi BIOS / restart lalu ulangi)" }
        }
      }
      'feat' {
        if (-not $IsAdmin) { $msg = 'butuh Administrator' }
        else {
          Write-Host "   ... Mengaktifkan $($c.Name)" -NoNewline -ForegroundColor Cyan
          try { $f = Enable-WindowsOptionalFeature -Online -FeatureName $c.Id.Substring(5) -All -NoRestart -ErrorAction Stop; $status = 'ok'; if ($f.RestartNeeded) { $reboot = $true; $msg = 'perlu restart' } }
          catch { $msg = 'tidak tersedia di edisi Windows ini (butuh Pro/Education)' }
        }
      }
      'info' { $status = 'info'; $Notes.Add("$($c.Name): $($c.Id.Substring(5))") }
    }
    $res[$status]++
    $pad = ' ' * 30
    switch ($status) {
      'ok' { Write-Host ("`r   √ {0}  ({1}s) {2}{3}" -f $c.Name, $secs, $msg, $pad) -ForegroundColor Green; $c.Installed = $true }
      'skip' { Write-Host ("`r   = {0}  ({1}){2}" -f $c.Name, $msg, $pad) -ForegroundColor DarkGray; $c.Installed = $true }
      'info' { Write-Host ("`r   i {0}  -> perlu download manual (lihat catatan di akhir){1}" -f $c.Name, $pad) -ForegroundColor DarkYellow }
      'fail' { Write-Host ("`r   × {0}  GAGAL: {1}{2}" -f $c.Name, $msg, $pad) -ForegroundColor Red; $failed += $c.Name }
    }
    Log "$($c.Key): $status $msg"
    if ($status -ne 'fail') { $Cart.Remove($c.Key) }
  }
  Refresh-Path
  Write-Host ('  ' + (Bar $total $total)) -ForegroundColor Magenta
  $mins = [int]$swAll.Elapsed.TotalMinutes
  Write-Host ''
  Line '  ╔══════════════════════════════════════════════════════════╗' Magenta
  Line ('  ║  RINGKASAN  ·  waktu total ~{0,-3} menit                     ║' -f $mins) Magenta
  Line '  ╠══════════════════════════════════════════════════════════╣' Magenta
  Line ('  ║   √ Berhasil        : {0,-4}                               ║' -f $res.ok) Green
  Line ('  ║   = Sudah ada       : {0,-4}                               ║' -f $res.skip) DarkGray
  Line ('  ║   i Manual/catatan  : {0,-4}                               ║' -f $res.info) DarkYellow
  Line ('  ║   × Gagal           : {0,-4}                               ║' -f $res.fail) $(if ($res.fail) { 'Red' } else { 'DarkGray' })
  Line '  ╚══════════════════════════════════════════════════════════╝' Magenta
  if ($failed) { Line ("  Gagal: " + ($failed -join ', ') + "`n  Item yang gagal tetap di keranjang, bisa dicoba lagi. Detail ada di log.") Red }
  if ($Notes.Count) {
    Line "`n  Perlu download manual:" Yellow
    foreach ($nt in $Notes) { Line "   • $nt" Gray }
    if (YesNo 'Buka semua link download di browser?' $true) { foreach ($nt in $Notes) { if ($nt -match '(https?://\S+)') { Start-Process $Matches[1] } } }
    $Notes.Clear()
  }
  Line "`n  Tip: tutup lalu buka lagi terminal/VS Code supaya PATH baru terbaca." DarkCyan
  if ($reboot) {
    Line '  Beberapa komponen (WSL/fitur Windows) butuh RESTART.' Yellow
    if (YesNo 'Restart sekarang? (simpan pekerjaan dulu)' $false) { Restart-Computer -Force }
  }
  Pause-Key
}

function Setup-VSCodeExt {
  Refresh-Path
  $code = (Get-Command code -ErrorAction SilentlyContinue).Source
  if (-not $code) { foreach ($p in @("$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd", "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd")) { if (Test-Path $p) { $code = $p } } }
  if (-not $code) { Clear-Host; Line "`n  VS Code belum terpasang. Install dulu lewat menu lain." Red; Pause-Key; return }
  Clear-Host; Write-Host "`n   Membaca ekstensi yang sudah terpasang..." -ForegroundColor DarkGray
  $have = @(& $code --list-extensions 2>$null | ForEach-Object { $_.ToLower() })
  $items = foreach ($e in $VSExt) {
    $p = $e -split '\|', 4; $ins = $have -contains $p[0].ToLower()
    $b = $(if ($ins) { '{Green}√ terpasang  ' } else { '' }) + $(if ($p[2] -eq '1') { '{Yellow}♦ rekomendasi' } else { '' })
    MkItem $p[1] "$($p[3])`nID: $($p[0])" $p[0] $b $false $ins ($p[2] -eq '1')
  }
  foreach ($it in $items) { if ($it.Rec -and -not $it.Lock) { $it.Checked = $true } }
  $r = Select-List -Title 'Ekstensi VS Code' -Sub 'Yang rekomendasi sudah dicentang. Enter untuk memasang.' -Items $items -Multi -EnterText 'pasang'
  if (-not $r.Ok -or -not $r.Values.Count) { return }
  Clear-Host; Write-Host ''
  $i = 0
  foreach ($e in $r.Values) {
    $i++; $x = Invoke-Spin $code "--install-extension $e --force" "[$i/$($r.Values.Count)] $e"
    if ($x.Code -eq 0) { Write-Host "`r   √ $e                                   " -ForegroundColor Green } else { Write-Host "`r   × $e (gagal)                           " -ForegroundColor Red }
  }
  Pause-Key
}

function Setup-Git {
  Clear-Host; Refresh-Path
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Line "`n  Git belum terpasang." Red; Pause-Key; return }
  Line "`n  ═══ SETUP GIT & SSH KEY ═══`n" Magenta
  $curN = git config --global user.name; $curE = git config --global user.email
  Line "  Konfigurasi sekarang: $(if ($curN) { "$curN <$curE>" } else { '(belum ada)' })`n" DarkGray
  $name = Ask 'Nama lengkap (tampil di commit)' $curN
  $mail = Ask 'Email (SAMA dengan email akun GitHub)' $curE
  git config --global user.name "$name"; git config --global user.email "$mail"
  git config --global init.defaultBranch main
  git config --global core.autocrlf true
  git config --global pull.rebase false
  git config --global core.editor 'code --wait'
  Line '  √ user.name, user.email, defaultBranch=main, autocrlf=true, editor=VS Code' Green
  $key = "$HOME\.ssh\id_ed25519"
  if (-not (Test-Path $key)) {
    if (YesNo 'Buat SSH key baru (ed25519) untuk GitHub?' $true) {
      New-Item -ItemType Directory -Force "$HOME\.ssh" | Out-Null
      & ssh-keygen -t ed25519 -C "$mail" -f $key -N '""' -q
    }
  } else { Line '  SSH key sudah ada, dipakai ulang.' DarkGray }
  if (Test-Path "$key.pub") {
    Get-Content "$key.pub" | Set-Clipboard
    Line "`n  SSH public key (sudah DICOPY ke clipboard):" Green
    Line ('  ' + (Get-Content "$key.pub")) White
    Line "`n  1. Buka https://github.com/settings/ssh/new  2. Paste (Ctrl+V)  3. Add SSH key" Yellow
    if (YesNo 'Buka halaman GitHub SSH sekarang?' $true) { Start-Process 'https://github.com/settings/ssh/new' }
    if ($IsAdmin -and (YesNo 'Aktifkan ssh-agent otomatis (supaya tidak perlu input key terus)?' $true)) {
      Set-Service ssh-agent -StartupType Automatic -ErrorAction SilentlyContinue; Start-Service ssh-agent -ErrorAction SilentlyContinue; & ssh-add $key 2>$null
    }
    if (YesNo 'Tes koneksi ke GitHub (setelah key ditambahkan)?' $false) { & ssh -T -o StrictHostKeyChecking=accept-new git@github.com }
  }
  if ((Get-Command gh -ErrorAction SilentlyContinue) -and (YesNo 'Login GitHub CLI (gh auth login) juga?' $false)) { & gh auth login }
  Line "`n  Bonus: daftar GitHub Student Developer Pack (Copilot, JetBrains, domain gratis): https://education.github.com/pack" Cyan
  Pause-Key
}

function Setup-Tweaks {
  $adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
  $th = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
  $get = { param($p, $n) try { (Get-ItemProperty -Path $p -Name $n -ErrorAction Stop).$n } catch { $null } }
  $tw = @(
    @{ K = 'ext'; N = 'Tampilkan ekstensi file (.exe, .py, .java)'; T = 'WAJIB untuk programmer: supaya tidak tertipu file "tugas.pdf.exe" dan bisa rename ekstensi.'; On = ((& $get $adv 'HideFileExt') -eq 0); A = $false }
    @{ K = 'hid'; N = 'Tampilkan file & folder tersembunyi'; T = 'Supaya folder seperti .git, .vscode, .env dan AppData terlihat.'; On = ((& $get $adv 'Hidden') -eq 1); A = $false }
    @{ K = 'dark'; N = 'Mode gelap (dark mode)'; T = 'Tema gelap untuk Windows dan aplikasi. Lebih nyaman di mata saat ngoding malam.'; On = ((& $get $th 'AppsUseLightTheme') -eq 0); A = $false }
    @{ K = 'long'; N = 'Aktifkan Long Paths (> 260 karakter)'; T = 'Mencegah error "path too long" pada node_modules dan proyek bersarang dalam. Butuh Administrator.'; On = ((& $get 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled') -eq 1); A = $true }
    @{ K = 'dev'; N = 'Aktifkan Developer Mode'; T = 'Izinkan symlink tanpa admin dan sideload aplikasi. Berguna untuk tool dev tertentu. Butuh Administrator.'; On = ((& $get 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' 'AllowDevelopmentWithoutDevLicense') -eq 1); A = $true }
    @{ K = 'pol'; N = 'ExecutionPolicy RemoteSigned (CurrentUser)'; T = 'Supaya script npm/yarn/venv Activate.ps1 bisa jalan di PowerShell (mengatasi error "running scripts is disabled").'; On = ((Get-ExecutionPolicy -Scope CurrentUser) -eq 'RemoteSigned'); A = $false }
    @{ K = 'gitlong'; N = 'Git core.longpaths = true'; T = 'Pasangan Long Paths untuk Git di Windows.'; On = ((git config --global core.longpaths 2>$null) -eq 'true'); A = $false }
  )
  $items = foreach ($t in $tw) {
    $b = $(if ($t.On) { '{Green}√ sudah aktif  ' } else { '' }) + $(if ($t.A -and -not $IsAdmin) { '{Red}butuh admin' } else { '' })
    MkItem $t.N $t.T $t.K $b (-not $t.On) $t.On $true
  }
  $r = Select-List -Title 'Tweak Windows untuk Developer' -Sub 'Pengaturan yang bikin Windows lebih ramah programmer. Yang belum aktif sudah dicentang.' -Items $items -Multi -EnterText 'terapkan'
  if (-not $r.Ok) { return }
  Clear-Host; Write-Host ''
  foreach ($k in $r.Values) {
    try {
      switch ($k) {
        'ext' { Set-ItemProperty $adv HideFileExt 0 }
        'hid' { Set-ItemProperty $adv Hidden 1 }
        'dark' { Set-ItemProperty $th AppsUseLightTheme 0; Set-ItemProperty $th SystemUsesLightTheme 0 }
        'long' { Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' LongPathsEnabled 1 -ErrorAction Stop }
        'dev' { New-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Force -ErrorAction Stop | Out-Null; Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' AllowDevelopmentWithoutDevLicense 1 -ErrorAction Stop }
        'pol' { Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force }
        'gitlong' { git config --global core.longpaths true }
      }
      Line "   √ $(($tw | Where-Object { $_.K -eq $k }).N)" Green
    } catch { Line "   × $(($tw | Where-Object { $_.K -eq $k }).N) - butuh Administrator" Red }
  }
  if ($r.Values | Where-Object { $_ -in 'ext', 'hid', 'dark' }) { Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue; Line '   Explorer di-restart supaya perubahan terlihat.' DarkGray }
  Pause-Key
}

function Update-All {
  Clear-Host; Line "`n  ═══ UPDATE SEMUA APLIKASI (winget upgrade --all) ═══`n" Magenta
  [Console]::CursorVisible = $true
  winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
  if (Get-Command wsl.exe -ErrorAction SilentlyContinue) { Line "`n  Update kernel WSL..." DarkCyan; wsl.exe --update }
  Scan-Installed -Quiet
  Pause-Key
}

function Show-SysInfo {
  $n = @($Catalog | Where-Object Installed).Count
  $items = @(
    MkItem "Laptop  : $($Sys.Model)" 'Merek dan model laptop.'
    MkItem "OS      : $($Sys.OS)" 'Versi Windows. Windows 11 / Windows 10 22H2 direkomendasikan.'
    MkItem "CPU     : $($Sys.CPU)" "$($Sys.Cores)"
    MkItem "RAM     : $($Sys.Ram) GB" $(if ($Sys.Ram -lt 8) { 'RAM di bawah 8GB: hindari Docker/Android Studio, pakai editor ringan.' } elseif ($Sys.Ram -lt 16) { 'RAM 8-12GB: cukup untuk kuliah. Android Studio + emulator akan terasa berat.' } else { 'RAM 16GB+: aman untuk Docker, Android Studio dan LLM lokal kecil.' })
    MkItem "Disk C  : $($Sys.Disk)" 'Sisakan minimal 30GB untuk tool dev + proyek.'
    MkItem "Virtual.: $($Sys.Virt)" 'Dibutuhkan WSL2, Docker, Android Emulator dan VirtualBox. Kalau tidak aktif: masuk BIOS (F2/Del/F10 saat boot) lalu aktifkan Intel VT-x / AMD SVM.'
    MkItem "Admin   : $(if ($IsAdmin) { 'Ya' } else { 'Tidak' })" 'Jalankan sebagai Administrator agar WSL dan fitur Windows bisa dipasang.'
    MkItem "winget  : $($Sys.Winget)" 'Package manager resmi Windows yang dipakai script ini.'
    MkItem "Katalog : $n/$($Catalog.Count) aplikasi terpasang" 'Lihat menu Cek Status untuk detailnya.'
  )
  [void](Select-List -Title 'Info Sistem' -Items $items -EnterText 'kembali')
}

function Main-Menu {
  while ($true) {
    $n = @($Catalog | Where-Object Installed).Count
    $hdr = @()
    if ([Console]::WindowHeight -ge 40) { for ($i = 0; $i -lt $Banner.Count; $i++) { $hdr += "{$($BannerColors[$i])}  $($Banner[$i])" }; $hdr += "{DarkGray}      I F  ·  $($Sys.User)@$($Sys.Model)  ·  RAM $($Sys.Ram)GB  ·  $n/$($Catalog.Count) app terpasang"; $hdr += '' }
    $items = @(
      MkItem '🧙 Wizard Preferensi' "Jawab $($Wizard.Count) pertanyaan singkat (browser, WinRAR/7-Zip, editor, bahasa, WSL, WSA, dst). Setiap pilihan ada penjelasan dan rekomendasinya. PALING DISARANKAN untuk laptop baru." 'wiz' '{Yellow}♦ mulai di sini'
      MkItem '📦 Profil Siap Pakai' 'Paket sekali klik: Starter Mahasiswa IF, Web, Mobile, Data/AI, Jaringan & Security, DevOps, Game, Desain, Abang IT.' 'prof'
      MkItem '🗂  Pilih Manual per Kategori' "Jelajahi $($Catalog.Count) aplikasi dalam $($CatOrder.Count) kategori lalu centang sendiri." 'cat'
      MkItem '🔍 Cek Status Laptop' 'Lihat semua aplikasi: mana yang sudah terpasang dan mana yang belum. Laporan disimpan ke laporan-status.txt.' 'status' "{Green}$n/$($Catalog.Count) terpasang"
      MkItem "🛒 Keranjang & Install" 'Tinjau daftar yang akan dipasang lalu mulai instalasi otomatis dengan progress bar.' 'cart' $(if ($Cart.Count) { "{Cyan}$($Cart.Count) item siap" } else { '{DarkGray}kosong' })
      MkItem '🧩 Ekstensi VS Code' 'Pasang ekstensi VS Code penting: C/C++, Code Runner, Python, Java, Live Server, GitLens, Error Lens, dll.' 'ext'
      MkItem '🔑 Setup Git & SSH Key GitHub' 'Atur nama/email Git, buat SSH key, copy ke clipboard, buka halaman GitHub, aktifkan ssh-agent, gh auth login.' 'git'
      MkItem '⚙  Tweak Windows untuk Developer' 'Tampilkan ekstensi file, file tersembunyi, dark mode, Long Paths, Developer Mode, ExecutionPolicy.' 'tweak'
      MkItem '⟳  Update Semua Aplikasi' 'winget upgrade --all + wsl --update.' 'upd'
      MkItem '💻 Info Sistem' 'Spesifikasi laptop, RAM, disk, status virtualisasi (untuk WSL/Docker/Emulator).' 'sys'
      MkItem '⏻  Keluar' 'Sampai jumpa! Semangat ngodingnya.' 'quit'
    )
    if (-not $env:WT_SESSION) { foreach ($it in $items) { $it.Label = $it.Label.Substring(2).TrimStart() } }  # conhost lama: emoji tidak tampil
    $r = Select-List -Title 'Menu Utama' -Sub 'Selamat datang! Pakai panah ↑↓ lalu Enter. Setiap menu punya penjelasan di kotak info bawah.' -Items $items -Header $hdr
    $v = if ($r.Ok) { $r.Value } else { 'quit' }
    switch ($v) {
      'wiz' { Run-Wizard } 'prof' { Pick-Profile } 'cat' { Browse-Category } 'status' { Show-All }
      'cart' { Review-Install } 'ext' { Setup-VSCodeExt } 'git' { Setup-Git } 'tweak' { Setup-Tweaks }
      'upd' { Update-All } 'sys' { Show-SysInfo }
      'quit' {
        if ($Cart.Count -and -not (YesNo "Keranjang masih berisi $($Cart.Count) item. Yakin keluar?" $false)) { continue }
        Clear-Host; [Console]::CursorVisible = $true
        Line "`n  Terima kasih sudah pakai DEVSETUP IF. Log: $LogFile`n" Magenta; return
      }
    }
  }
}

# =====================================================================================
#  MAIN
# =====================================================================================
try {
  Log "DEVSETUP IF dimulai. Admin=$IsAdmin"
  Show-Boot
  if ($Preset) {
    $p = $Profiles | Where-Object { $_.K -eq $Preset }
    if (-not $p) { Line "Preset '$Preset' tidak dikenal. Pilihan: $(($Profiles | ForEach-Object K) -join ', ')" Red; exit 1 }
    Sync-Cart ($p.L -split ',') ($p.L -split ',')
    Install-Cart
  } else { Main-Menu }
} finally { [Console]::CursorVisible = $true }
