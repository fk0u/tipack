#!/usr/bin/env bash
# =====================================================================================
#  DEVSETUP IF v2 - Installer interaktif untuk Mahasiswa Teknik Informatika & Abang IT (Linux)
#  Mendukung semua distro besar:
#    apt     : Debian, Ubuntu, Linux Mint, Pop!_OS, Zorin, Kali, elementary, MX
#    dnf     : Fedora, RHEL, Rocky, AlmaLinux, Nobara
#    pacman  : Arch, Manjaro, EndeavourOS, CachyOS, Garuda (+ AUR via yay/paru)
#    zypper  : openSUSE Tumbleweed / Leap
#    apk     : Alpine
#  Distro lain (Void, Solus, NixOS, Gentoo, ...): aplikasi GUI tetap bisa lewat Flatpak & script resmi.
#
#  Jalankan:   bash setup.sh            (sebagai user biasa, BUKAN root; sudo diminta saat perlu)
#  Langsung:   bash setup.sh --preset starter   |   --no-anim
#
#  CATATAN: file ini dirakit oleh linux/src/build.sh dari linux-parts.sh + mesin TUI macos/setup.sh.
# =====================================================================================

PRESET=""; NOANIM=0; INSTALL_KEYS=""; SELFTEST=0
while [ $# -gt 0 ]; do case "$1" in --preset) PRESET="$2"; shift ;; --install) INSTALL_KEYS="$2"; shift ;; --self-test) SELFTEST=1 ;; --no-anim) NOANIM=1 ;; esac; shift; done
TEST_MODE=0; KEYQ=(); KEYI=0
if [ -n "$TIPACK_KEYS" ]; then IFS=',' read -r -a KEYQ <<< "$TIPACK_KEYS"; TEST_MODE=1; fi
[ $SELFTEST = 1 ] && TEST_MODE=1
[ $TEST_MODE = 1 ] && NOANIM=1
UNATTENDED=0; { [ -n "$INSTALL_KEYS" ] || [ -n "$PRESET" ]; } && UNATTENDED=1
INSTALL_FAIL=0

[ "$(uname -s)" = Linux ] || { echo "Script ini khusus Linux. macOS: macos/setup.sh, Windows: windows/setup.ps1"; exit 1; }
[ -z "$BASH_VERSION" ] && { echo "Jalankan dengan bash: bash setup.sh"; exit 1; }
export LANG="${LANG:-C.UTF-8}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG="$ROOT/devsetup-log-$(date +%Y%m%d-%H%M%S).txt"
# folder script tidak bisa ditulisi (flashdisk read-only, folder milik root, dll) -> log ke folder temp
( : >> "$LOG" ) 2>/dev/null || { LOG="${TMPDIR:-/tmp}/devsetup-log-$(date +%Y%m%d-%H%M%S).txt"; ROOT="${TMPDIR:-/tmp}"; }

E=$'\e'; R0="$E[0m"; B="$E[1m"; RED="$E[31m"; GRN="$E[32m"; YEL="$E[33m"; BLU="$E[34m"; MAG="$E[35m"; CYN="$E[36m"
WHT="$E[97m"; GRY="$E[37m"; DIM="$E[90m"; ORG="$E[38;5;208m"; PNK="$E[38;5;213m"; INV="$E[7m"

if [ "$(id -u)" = 0 ]; then SUDO=""; IS_ROOT=1; else SUDO="sudo"; IS_ROOT=0; fi
IS_TERMUX=0; { [ -n "$TERMUX_VERSION" ] || [ -d /data/data/com.termux/files/usr ]; } && { IS_TERMUX=1; SUDO=""; }

# =====================================================================================
#  KATALOG
#  key | Kategori | Nama | Rek | deteksi | apt | dnf | pacman | zypper | apk | termux | flatpak | universal | Tooltip
#  Kolom distro : "-" = tidak ada di repo, "pkg pkg2" = paket native, "aur:pkg" = AUR, "sh:fungsi" = script resmi
#  flatpak      : ID aplikasi Flathub, dipakai kalau kolom distro "-"
#  universal    : "sh:fungsi" atau "info:url", dipakai kalau dua kolom di atas tidak tersedia
#  deteksi      : "cmd:perintah" atau "dir:path"
# =====================================================================================
CATALOG_RAW='
chrome|Browser|Google Chrome|1|cmd:google-chrome|sh:chrome|sh:chrome|aur:google-chrome|sh:chrome|-|-|com.google.Chrome|-|Browser paling umum dengan DevTools terlengkap. Firefox biasanya sudah bawaan distro.
firefox|Browser|Mozilla Firefox|0|cmd:firefox|firefox|firefox|firefox|MozillaFirefox|firefox|-|org.mozilla.firefox|-|Open source, menjaga privasi, DevTools CSS terbaik. Bawaan hampir semua distro.
brave|Browser|Brave|0||-|-|aur:brave-bin|-|-|-|com.brave.Browser|-|Berbasis Chromium dengan adblock bawaan, lebih hemat RAM.
chromium|Browser|Chromium|0|cmd:chromium|chromium|chromium|chromium|chromium|chromium|-|org.chromium.Chromium|-|Versi open source Chrome, tanpa layanan Google.
clipack|Terminal & Shell|CLI Power Pack (curl, htop, jq, tldr, dll)|1|cmd:htop|curl wget tree htop btop jq tldr ripgrep bat fzf fd-find unzip|curl wget tree htop btop jq tldr ripgrep bat fzf fd-find unzip|curl wget tree htop btop jq tldr ripgrep bat fzf fd eza zoxide unzip|curl wget tree htop btop jq tealdeer ripgrep bat fzf fd eza zoxide unzip|curl wget tree htop btop jq tealdeer ripgrep bat fzf fd eza zoxide unzip|curl wget tree htop jq tealdeer ripgrep bat fzf fd eza zoxide unzip|-|-|Paket tool terminal wajib: curl, wget, tree, htop, btop, jq, tldr (contoh perintah), ripgrep, bat, fzf, fd.
zsh|Terminal & Shell|Zsh|0|cmd:zsh|zsh|zsh|zsh|zsh|zsh|zsh|-|-|Shell yang lebih nyaman dari bash. Dibutuhkan Oh My Zsh.
ohmyzsh|Terminal & Shell|Oh My Zsh + autosuggest + syntax highlight|1|dir:~/.oh-my-zsh|sh:ohmyzsh|sh:ohmyzsh|sh:ohmyzsh|sh:ohmyzsh|sh:ohmyzsh|sh:ohmyzsh|-|-|Framework zsh dengan tema dan plugin, plus saran perintah otomatis dan pewarnaan. Zsh dipasang otomatis.
fish|Terminal & Shell|Fish shell|0|cmd:fish|fish|fish|fish|fish|fish|fish|-|-|Shell ramah pemula dengan autosuggestion bawaan tanpa konfigurasi.
starship|Terminal & Shell|Starship prompt|0|cmd:starship|-|-|starship|starship|starship|starship|-|sh:starship|Prompt cantik yang menampilkan branch git dan versi bahasa. Butuh Nerd Font.
tmux|Terminal & Shell|tmux|0|cmd:tmux|tmux|tmux|tmux|tmux|tmux|tmux|-|-|Terminal multiplexer: split pane dan sesi yang tetap hidup walau SSH putus.
kitty|Terminal & Shell|Kitty terminal|0|cmd:kitty|kitty|kitty|kitty|kitty|kitty|-|-|-|Terminal cepat berbasis GPU dengan tab dan split.
alacritty|Terminal & Shell|Alacritty|0|cmd:alacritty|alacritty|alacritty|alacritty|alacritty|alacritty|-|-|-|Terminal minimalis berbasis GPU, sangat ringan.
nerdfont|Terminal & Shell|JetBrains Mono Nerd Font|0|dir:~/.local/share/fonts/JetBrainsMono|sh:nerdfont|sh:nerdfont|ttf-jetbrains-mono-nerd|sh:nerdfont|sh:nerdfont|-|-|-|Font coding dengan ligature dan ikon untuk terminal modern dan Starship.
vscode|Editor Kode|Visual Studio Code|1|cmd:code|sh:vscode|sh:vscode|aur:visual-studio-code-bin|sh:vscode|-|-|com.visualstudio.code|-|Editor paling populer. Dipasang dari repo resmi Microsoft (bukan Flatpak) supaya terminal dan compiler terbaca normal.
vscodium|Editor Kode|VSCodium|0|cmd:codium|-|-|aur:vscodium-bin|-|-|-|com.vscodium.codium|-|VS Code versi open source tanpa telemetri Microsoft.
cursor|Editor Kode|Cursor|0|cmd:cursor|-|-|aur:cursor-bin|-|-|-|-|info:https://cursor.com/downloads|Fork VS Code dengan AI terintegrasi. Distro selain Arch: download AppImage resmi.
antigravity|Editor Kode|Google Antigravity|0|cmd:antigravity|-|-|-|-|-|-|-|info:https://antigravity.google|IDE agentic dari Google (berbasis VS Code). Download manual dari situs resminya.
zed|Editor Kode|Zed|0|cmd:zed|-|-|zed|-|-|-|dev.zed.Zed|-|Editor super cepat (Rust) dengan kolaborasi realtime dan AI.
sublime|Editor Kode|Sublime Text|0|cmd:subl|-|-|aur:sublime-text-4|-|-|-|com.sublimetext.three|-|Editor ringan dan sangat cepat.
neovim|Editor Kode|Neovim|0|cmd:nvim|neovim|neovim|neovim|neovim|neovim|neovim|-|-|Editor di terminal untuk yang mau jadi keyboard warrior.
intellij|IDE|IntelliJ IDEA Community|0||-|-|-|-|-|-|com.jetbrains.IntelliJ-IDEA-Community|-|IDE terbaik untuk Java/Kotlin, wajib untuk matkul PBO.
pycharm|IDE|PyCharm Community|0||-|-|-|-|-|-|com.jetbrains.PyCharm-Community|-|IDE khusus Python dengan debugger dan pengelola virtualenv.
toolbox|IDE|JetBrains Toolbox|0||-|-|aur:jetbrains-toolbox|-|-|-|-|info:https://www.jetbrains.com/toolbox-app/|Satu aplikasi untuk install/update semua IDE JetBrains.
netbeans|IDE|Apache NetBeans|0||-|-|netbeans|-|-|-|org.apache.netbeans|-|IDE Java yang masih sering dipakai dosen untuk Java Swing/GUI.
codeblocks|IDE|Code::Blocks|0|cmd:codeblocks|codeblocks|codeblocks|codeblocks|-|-|-|org.codeblocks.codeblocks|-|IDE C/C++ klasik untuk praktikum Algoritma.
build|Bahasa & Runtime|Build tools C/C++ (gcc, g++, make, gdb)|1|cmd:g++|build-essential gdb|gcc gcc-c++ make gdb|base-devel gdb|gcc gcc-c++ make gdb|build-base gdb|clang make gdb|-|-|Compiler C/C++ dan debugger. Wajib untuk Algoritma dan Struktur Data.
clang|Bahasa & Runtime|Clang + LLVM|0|cmd:clang|clang lldb|clang lldb|clang lldb|clang lldb|clang lldb|clang|-|-|Compiler C/C++ alternatif dengan pesan error lebih jelas, plus clangd untuk editor.
cmake|Bahasa & Runtime|CMake|0|cmd:cmake|cmake|cmake|cmake|cmake|cmake|cmake|-|-|Build system untuk proyek C/C++.
python|Bahasa & Runtime|Python 3 + pip + venv|1|cmd:pip3|python3 python3-pip python3-venv python-is-python3|python3 python3-pip|python python-pip|python3 python3-pip|python3 py3-pip|python python-pip|-|-|Bahasa wajib untuk algoritma, data science, AI dan scripting.
uv|Bahasa & Runtime|uv (Python package manager)|0|cmd:uv|-|uv|uv|-|uv|uv|-|sh:uv|Pengganti pip + venv yang 10-100x lebih cepat.
nodejs|Bahasa & Runtime|Node.js + npm (repo distro)|1|cmd:node|nodejs npm|nodejs nodejs-npm|nodejs npm|nodejs-default/nodejs22 npm-default/npm22|nodejs npm|nodejs|-|-|Runtime JavaScript. Versi dari repo distro; butuh versi terbaru? pilih fnm.
fnm|Bahasa & Runtime|fnm (Node version manager)|0|cmd:fnm|-|-|fnm|-|-|-|-|sh:fnm|Untuk memasang Node versi berapa pun (misal fnm install --lts). Pilih ini ATAU Node.js repo.
bun|Bahasa & Runtime|Bun|0|cmd:bun|-|-|-|-|-|-|-|sh:bun|Runtime JS super cepat sekaligus package manager.
jdk|Bahasa & Runtime|Java JDK LTS (OpenJDK 21/25)|1|cmd:javac|openjdk-21-jdk/openjdk-25-jdk/openjdk-17-jdk|java-21-openjdk-devel/java-25-openjdk-devel/java-latest-openjdk-devel|jdk21-openjdk|java-21-openjdk-devel/java-25-openjdk-devel|openjdk21/openjdk25|openjdk-21/openjdk-17|-|-|JDK LTS. Wajib untuk PBO/Java dan Android. Versi LTS terbaru yang tersedia di distro dipilih otomatis (21, 25, atau 17 di Debian 12).
jdk17|Bahasa & Runtime|Java JDK 17 (OpenJDK)|0||openjdk-17-jdk|-|jdk17-openjdk|java-17-openjdk-devel|openjdk17|-|-|-|Versi LTS lama, kadang diminta dosen atau proyek lama.
go|Bahasa & Runtime|Go|0|cmd:go|golang-go|golang|go|go|go|golang|-|-|Bahasa backend modern: cepat dan simpel.
rust|Bahasa & Runtime|Rust (rustup)|0|cmd:rustup|-|-|rustup|-|-|rust|-|sh:rustup|Bahasa sistem yang aman memori. Dipasang lewat rustup resmi.
php|Bahasa & Runtime|PHP + ekstensi umum|0|cmd:php|php-cli php-mbstring php-xml php-curl php-mysql php-zip|php-cli php-mbstring php-xml php-mysqlnd php-pdo|php|php8 php8-mbstring php8-mysql|php83 php83-mbstring php83-pdo_mysql|php|-|-|PHP CLI dengan ekstensi untuk Laravel dan MySQL.
composer|Bahasa & Runtime|Composer|0|cmd:composer|composer|composer|composer|php-composer2|composer|composer|-|-|Package manager PHP, wajib untuk Laravel.
dotnet|Bahasa & Runtime|.NET SDK|0|cmd:dotnet|dotnet-sdk-8.0/dotnet-sdk-10.0|dotnet-sdk-10.0/dotnet-sdk-8.0|dotnet-sdk|-|dotnet8-sdk/dotnet10-sdk|-|-|info:https://learn.microsoft.com/dotnet/core/install/linux|Untuk C#, ASP.NET dan Blazor.
r|Bahasa & Runtime|R|0|cmd:R|r-base|R|r|R-base|R|-|-|-|Bahasa statistik untuk matkul Statistika/Data Mining.
lamp|Web Server & Database|Apache + PHP (LAMP)|0|cmd:apachectl|apache2 libapache2-mod-php|httpd php|apache php-apache|apache2 apache2-mod_php8|apache2 php83-apache2|-|-|-|Web server Apache dengan PHP, setara XAMPP versi native. Folder web: /var/www/html.
xampp|Web Server & Database|XAMPP (installer resmi)|0|dir:/opt/lampp|-|-|-|-|-|-|-|info:https://www.apachefriends.org/download.html|Sama seperti di lab kampus. Download file .run lalu jalankan dengan sudo.
mariadb|Web Server & Database|MariaDB (MySQL)|1|cmd:mariadb|mariadb-server|mariadb-server|mariadb|mariadb|mariadb|mariadb|-|-|Database MySQL-compatible. Setelah install: sudo systemctl enable --now mariadb.
postgres|Web Server & Database|PostgreSQL|0|cmd:psql|postgresql|postgresql-server|postgresql|postgresql-server|postgresql|postgresql|-|-|Database relasional open source paling canggih.
sqlite|Web Server & Database|SQLite|0|cmd:sqlite3|sqlite3|sqlite|sqlite|sqlite3|sqlite|sqlite|-|-|Database satu file untuk aplikasi kecil dan mobile.
redis|Web Server & Database|Redis / Valkey|0|cmd:redis-server|redis-server|valkey|valkey|redis|redis|redis|-|-|Database key-value di memori untuk cache dan antrean.
dbeaver|Web Server & Database|DBeaver Community|1||-|-|dbeaver|-|-|-|io.dbeaver.DBeaverCommunity|-|Satu aplikasi untuk SEMUA database. Bisa bikin ERD otomatis.
workbench|Web Server & Database|MySQL Workbench|0|cmd:mysql-workbench|-|-|aur:mysql-workbench|-|-|-|-|info:https://dev.mysql.com/downloads/workbench/|Tool resmi MySQL untuk desain ERD.
git|Git & API|Git|1|cmd:git|git|git|git|git|git|git|-|-|Version control wajib.
ghcli|Git & API|GitHub CLI (gh)|1|cmd:gh|gh|gh|github-cli|gh|github-cli|gh|-|-|Login GitHub, clone, bikin repo dan PR dari terminal.
ghdesktop|Git & API|GitHub Desktop (komunitas)|0||-|-|aur:github-desktop-bin|-|-|-|io.github.shiftey.Desktop|-|Git versi GUI. Versi Linux dikelola komunitas (shiftey).
lazygit|Git & API|lazygit|0|cmd:lazygit|-|-|lazygit|lazygit|lazygit|lazygit|-|-|UI Git di terminal.
postman|Git & API|Postman|1||-|-|aur:postman-bin|-|-|-|com.getpostman.Postman|-|Tes REST API. Standar industri untuk matkul Web Service.
bruno|Git & API|Bruno|0||-|-|aur:bruno-bin|-|-|-|com.usebruno.Bruno|-|Alternatif Postman yang open source dan offline.
docker|DevOps & Cloud|Docker Engine + Compose|0|cmd:docker|sh:docker|sh:docker|docker docker-compose docker-buildx|docker docker-compose|docker docker-cli-compose|-|-|-|Container standar industri. User otomatis dimasukkan ke grup docker (logout-login setelahnya).
podman|DevOps & Cloud|Podman|0|cmd:podman|podman|podman|podman|podman|podman|-|-|-|Alternatif Docker tanpa daemon dan tanpa root. Bawaan Fedora.
distrobox|DevOps & Cloud|Distrobox|0|cmd:distrobox|distrobox|distrobox|distrobox|distrobox|distrobox|-|-|-|Jalankan distro lain (Ubuntu di Arch, Arch di Fedora, dll) dalam container terintegrasi.
kubectl|DevOps & Cloud|kubectl|0|cmd:kubectl|-|-|kubectl|kubernetes-client|kubectl|kubectl|-|sh:kubectl|CLI untuk Kubernetes.
ngrok|DevOps & Cloud|ngrok|0|cmd:ngrok|-|-|aur:ngrok|-|-|-|-|info:https://ngrok.com/download|Membuat localhost bisa diakses publik untuk demo.
ollama|AI & Data|Ollama|0|cmd:ollama|-|-|ollama|-|-|ollama|-|sh:ollama|Jalankan LLM (Llama, Gemma, Qwen) secara lokal. Nyaman di RAM 16GB.
jupyter|AI & Data|JupyterLab|0|cmd:jupyter-lab|jupyter-notebook|-|jupyterlab|-|-|-|-|info:https://jupyter.org/install|Notebook untuk data science (alternatif: pip install jupyterlab di venv).
androidstudio|Mobile & Game|Android Studio|0||-|-|aur:android-studio|-|-|-|com.google.AndroidStudio|-|IDE resmi Android + emulator. Emulator butuh KVM (cek menu Info Sistem).
flutter|Mobile & Game|Flutter SDK|0|cmd:flutter|-|-|aur:flutter-bin|-|-|-|-|info:https://docs.flutter.dev/get-started/install/linux|Framework mobile cross-platform. Install manual atau lewat ekstensi VS Code Flutter.
godot|Mobile & Game|Godot Engine|0|cmd:godot|-|godot|godot|godot|-|-|org.godotengine.Godot|-|Engine game open source, ringan, native di Linux.
blender|Mobile & Game|Blender|0|cmd:blender|-|-|blender|-|-|-|org.blender.Blender|-|Modeling dan animasi 3D gratis.
unity|Mobile & Game|Unity Hub|0||-|-|aur:unityhub|-|-|-|-|info:https://docs.unity3d.com/hub/manual/InstallHub.html|Engine game populer. Linux: pakai repo resmi Unity (Ubuntu) atau AUR.
arduino|Mobile & Game|Arduino IDE|0||-|-|aur:arduino-ide-bin|-|-|-|cc.arduino.IDE2|-|Untuk matkul IoT. User otomatis dimasukkan ke grup dialout lewat menu Tweak.
packettracer|Jaringan & Keamanan|Cisco Packet Tracer|0||-|-|aur:packettracer|-|-|-|-|info:https://www.netacad.com/resources/lab-downloads|Simulasi jaringan Cisco. Download .deb dari NetAcad (butuh akun gratis).
wireshark|Jaringan & Keamanan|Wireshark|0|cmd:wireshark|wireshark|wireshark|wireshark-qt|wireshark|wireshark|-|-|-|Analisis paket jaringan. Wajib untuk matkul Jarkom/Keamanan.
nmap|Jaringan & Keamanan|Nmap|0|cmd:nmap|nmap|nmap|nmap|nmap|nmap|nmap|-|-|Port scanner. Pakai hanya di jaringan sendiri atau yang sudah diizinkan.
nettools|Jaringan & Keamanan|Network tools (dig, traceroute, whois, iperf3)|0|cmd:traceroute|net-tools dnsutils traceroute whois iperf3|net-tools bind-utils traceroute whois iperf3|net-tools bind traceroute whois iperf3|net-tools bind-utils traceroute whois iperf|net-tools bind-tools whois iperf3|dnsutils traceroute whois iperf3|-|-|Perkakas diagnosa jaringan untuk praktikum Jarkom.
openssh|Jaringan & Keamanan|OpenSSH server|0|cmd:sshd|openssh-server|openssh-server|openssh|openssh-server|openssh-server|openssh|-|-|Supaya laptop bisa diakses lewat SSH (praktikum server).
filezilla|Jaringan & Keamanan|FileZilla|0|cmd:filezilla|filezilla|filezilla|filezilla|filezilla|filezilla|-|org.filezillaproject.Filezilla|-|Klien FTP/SFTP untuk upload ke hosting.
remmina|Jaringan & Keamanan|Remmina (RDP/VNC/SSH)|0|cmd:remmina|remmina|remmina|remmina|remmina|remmina|-|org.remmina.Remmina|-|Remote desktop ke Windows (RDP), VNC dan SSH.
wireguard|Jaringan & Keamanan|WireGuard tools|0|cmd:wg|wireguard-tools|wireguard-tools|wireguard-tools|wireguard-tools|wireguard-tools|wireguard-tools|-|-|VPN modern yang cepat.
burp|Jaringan & Keamanan|Burp Suite Community|0||-|-|aur:burpsuite|-|-|-|-|info:https://portswigger.net/burp/releases/community/latest|Proxy untuk pentest aplikasi web. Gunakan secara etis.
virtmanager|Virtualisasi & Linux|virt-manager + QEMU/KVM|1|cmd:virt-manager|virt-manager qemu-system-x86 libvirt-daemon-system|virt-manager qemu-kvm libvirt|virt-manager qemu-full libvirt dnsmasq|virt-manager qemu-x86 libvirt|-|-|-|-|Mesin virtual native Linux (paling cepat, pakai KVM). Untuk matkul Sistem Operasi.
boxes|Virtualisasi & Linux|GNOME Boxes|0|cmd:gnome-boxes|gnome-boxes|gnome-boxes|gnome-boxes|gnome-boxes|-|-|org.gnome.Boxes|-|VM paling mudah: pilih ISO, klik, jadi.
virtualbox|Virtualisasi & Linux|VirtualBox|0|cmd:virtualbox|virtualbox|-|virtualbox virtualbox-host-dkms|virtualbox|-|-|-|info:https://www.virtualbox.org/wiki/Linux_Downloads|Mesin virtual populer. Fedora: download dari situs resmi.
figma|Desain & Multimedia|Figma (klien komunitas)|1||-|-|aur:figma-linux-bin|-|-|-|io.github.Figma_Linux.figma_linux|-|Figma tidak punya app resmi Linux; ini klien komunitas. Alternatif: buka figma.com di browser.
drawio|Desain & Multimedia|draw.io Desktop|1||-|-|aur:drawio-desktop-bin|-|-|-|com.jgraph.drawio.desktop|-|Flowchart, UML, ERD dan DFD offline. Wajib untuk matkul RPL.
gimp|Desain & Multimedia|GIMP|0|cmd:gimp|gimp|gimp|gimp|gimp|gimp|-|org.gimp.GIMP|-|Edit foto gratis, alternatif Photoshop.
inkscape|Desain & Multimedia|Inkscape|0|cmd:inkscape|inkscape|inkscape|inkscape|inkscape|inkscape|-|org.inkscape.Inkscape|-|Desain vektor gratis.
obs|Desain & Multimedia|OBS Studio|0|cmd:obs|obs-studio|obs-studio|obs-studio|obs-studio|-|-|com.obsproject.Studio|-|Rekam layar dan live streaming untuk video demo tugas.
vlc|Desain & Multimedia|VLC|1|cmd:vlc|vlc|-|vlc|vlc|vlc|-|org.videolan.VLC|-|Pemutar semua format video.
flameshot|Desain & Multimedia|Flameshot|1|cmd:flameshot|flameshot|flameshot|flameshot|flameshot|flameshot|-|org.flameshot.Flameshot|-|Screenshot dengan anotasi (panah, kotak, blur). Pengganti Snipping Tool.
discord|Komunikasi|Discord|1||-|-|discord|-|-|-|com.discordapp.Discord|-|Grup kelas, komunitas programmer, voice call kerja kelompok.
zoom|Komunikasi|Zoom|1||-|-|aur:zoom|-|-|-|us.zoom.Zoom|-|Kuliah online dan sidang.
telegram|Komunikasi|Telegram|0|cmd:telegram-desktop|-|-|telegram-desktop|-|-|-|org.telegram.desktop|-|Banyak grup/komunitas IT.
slack|Komunikasi|Slack|0||-|-|aur:slack-desktop|-|-|-|com.slack.Slack|-|Komunikasi tim ala industri dan magang.
notion|Kuliah & Produktivitas|Notion (klien komunitas)|0||-|-|aur:notion-app-electron|-|-|-|-|info:https://www.notion.so|Notion tidak punya app resmi Linux; gunakan versi web atau klien komunitas.
obsidian|Kuliah & Produktivitas|Obsidian|0||-|-|obsidian|-|-|-|md.obsidian.Obsidian|-|Catatan Markdown offline dengan graph view.
zotero|Kuliah & Produktivitas|Zotero|0||-|-|aur:zotero-bin|-|-|-|org.zotero.Zotero|-|Manajer referensi dan sitasi otomatis untuk skripsi.
libreoffice|Kuliah & Produktivitas|LibreOffice|1|cmd:libreoffice|libreoffice|libreoffice|libreoffice-fresh|libreoffice|libreoffice|-|org.libreoffice.LibreOffice|-|Office gratis, kompatibel dengan file Word/Excel/PowerPoint.
office|Kuliah & Produktivitas|Microsoft 365 (web, email kampus)|0||-|-|-|-|-|-|-|info:https://www.office.com|Microsoft Office tidak tersedia untuk Linux. Pakai versi web gratis dengan email kampus.
okular|Kuliah & Produktivitas|Okular (PDF)|0|cmd:okular|okular|okular|okular|okular|okular|-|org.kde.okular|-|Pembaca PDF lengkap dengan anotasi dan tanda tangan.
flatpak|Utilitas Sistem|Flatpak + Flathub|1|cmd:flatpak|flatpak|flatpak|flatpak|flatpak|flatpak|-|-|-|Toko aplikasi universal Linux. Dipasang otomatis kalau ada aplikasi yang butuh.
fastfetch|Utilitas Sistem|fastfetch|0|cmd:fastfetch|fastfetch/neofetch|fastfetch|fastfetch|fastfetch|fastfetch|fastfetch|-|-|Tampilkan info sistem + logo distro di terminal (pengganti neofetch). Wajib buat pamer.
timeshift|Utilitas Sistem|Timeshift (backup sistem)|1|cmd:timeshift|timeshift|timeshift|timeshift|-|-|-|-|-|Snapshot sistem: kalau update bikin rusak, tinggal restore. WAJIB untuk pemula Linux.
gparted|Utilitas Sistem|GParted|0|cmd:gparted|gparted|gparted|gparted|gparted|gparted|-|-|-|Atur partisi disk.
localsend|Utilitas Sistem|LocalSend|1||-|-|aur:localsend-bin|-|-|-|org.localsend.localsend_app|-|Kirim file HP ke laptop lewat WiFi, seperti AirDrop lintas platform.
copyq|Utilitas Sistem|CopyQ (riwayat clipboard)|0|cmd:copyq|copyq|copyq|copyq|-|-|-|com.github.hluk.copyq|-|Riwayat copy-paste yang bisa dicari.
ventoy|Utilitas Sistem|Ventoy|0||-|-|aur:ventoy-bin|-|-|-|-|info:https://www.ventoy.net/en/download.html|Satu flashdisk untuk banyak ISO sekaligus. Wajib untuk abang IT.
gnometweaks|Utilitas Sistem|GNOME Tweaks + Extension Manager|0|cmd:gnome-tweaks|gnome-tweaks gnome-shell-extension-manager|gnome-tweaks|gnome-tweaks|gnome-tweaks|-|-|com.mattjakeman.ExtensionManager|-|Kustomisasi tampilan GNOME (font, tema, ekstensi). Hanya untuk desktop GNOME.
'

i=0
while IFS='|' read -r k cat name rec det papt pdnf ppac pzyp papk ptmx flat uni tip; do
  [ -z "$k" ] && continue
  K_KEY[$i]=$k; K_CAT[$i]=$cat; K_NAME[$i]=$name; K_REC[$i]=$rec; K_DET[$i]=$det
  K_APT[$i]=$papt; K_DNF[$i]=$pdnf; K_PAC[$i]=$ppac; K_ZYP[$i]=$pzyp; K_APK[$i]=$papk; K_TMX[$i]=$ptmx; K_FLAT[$i]=$flat; K_UNI[$i]=$uni; K_TIP[$i]=$tip
  K_TYPE[$i]=pending; K_ID[$i]=""
  INST[$i]=0; CART[$i]=0; eval "IDX_$k=$i"
  i=$((i+1))
done <<< "$CATALOG_RAW"
NCAT=$i
HEAVY=" docker androidstudio unity ollama virtualbox "
ix() { eval "echo \${IDX_$1}"; }

PROFILES=(
"starter|Starter Pack Mahasiswa IF (Semester 1-2)|Paket aman untuk mahasiswa IF baru: browser, editor, compiler, Python, Java, Node, Git, database, tool diagram dan komunikasi kuliah.|chrome clipack ohmyzsh vscode build python jdk nodejs git ghcli mariadb dbeaver postman drawio figma discord zoom vlc flameshot libreoffice flatpak timeshift localsend"
"cpp|C/C++ & Algoritma|Untuk praktikum Dasar Pemrograman, Algoritma dan Struktur Data.|build clang cmake codeblocks vscode git"
"java|Java & PBO|Untuk matkul Pemrograman Berorientasi Objek.|jdk intellij netbeans vscode git"
"web|Web Developer (Fullstack)|Laravel/PHP, Node.js/React, database, API testing dan container.|chrome firefox vscode fnm bun git ghcli lamp php composer mariadb postgres redis dbeaver postman docker"
"mobile|Mobile Developer (Android/Flutter)|Android Studio + emulator, JDK dan Flutter.|androidstudio jdk flutter vscode git ghcli figma postman"
"data|Data Science & AI|Python + uv, Jupyter, R, database dan LLM lokal.|python uv jupyter r vscode git dbeaver postgres ollama"
"net|Jaringan & Keamanan Siber|Packet Tracer, Wireshark, Nmap, SSH, Remmina, Burp dan VM.|packettracer wireshark nmap nettools openssh filezilla remmina wireguard burp virtmanager"
"devops|DevOps & Cloud|Docker, Podman, Distrobox, Kubernetes dan VM.|docker podman distrobox kubectl git ghcli lazygit vscode virtmanager tmux"
"game|Game Developer|Godot, Blender, Unity dan tool aset.|godot blender unity vscode gimp inkscape git obs"
"design|UI/UX & Konten Kreator|Figma, desain vektor/raster, rekam layar.|figma drawio gimp inkscape obs flameshot vlc blender"
"tech|Abang IT / Linux Power User|Toolkit servis dan kustomisasi: backup, partisi, flashdisk bootable, remote, info sistem.|clipack fastfetch timeshift gparted ventoy remmina openssh localsend copyq tmux gnometweaks flatpak"
)

WIZ=(
"Browser utama?|s|chrome firefox brave chromium|Firefox biasanya sudah terpasang. Chrome = DevTools terlengkap, Brave = hemat RAM + adblock."
"Terminal & shell?|m|clipack zsh ohmyzsh fish starship tmux kitty alacritty nerdfont|CLI Power Pack + Oh My Zsh = setup terminal standar developer Linux."
"Editor kode? (boleh lebih dari satu)|m|vscode vscodium cursor antigravity zed sublime neovim|VS Code dipasang dari repo resmi Microsoft supaya terintegrasi penuh dengan terminal."
"IDE tambahan sesuai matkul?|m|intellij pycharm toolbox netbeans codeblocks|Java/PBO -> IntelliJ/NetBeans. Praktikum C -> Code::Blocks kalau diminta dosen."
"Bahasa pemrograman & runtime?|m|build clang cmake python uv nodejs fnm bun jdk jdk17 go rust php composer dotnet r|Minimal untuk mahasiswa IF: Build tools C/C++, Python, Java JDK dan Node.js."
"Web server lokal?|s|lamp xampp docker|LAMP native = paling ringan. XAMPP = sama seperti di lab kampus. Docker = cara industri."
"Database & client database?|m|mariadb postgres sqlite redis dbeaver workbench|DBeaver bisa untuk semua jenis database. MariaDB = MySQL versi open source."
"Git & API tools?|m|git ghcli ghdesktop lazygit postman bruno|Git wajib. Postman untuk tes API backend."
"Container & mesin virtual?|m|docker podman distrobox virtmanager boxes virtualbox|virt-manager (KVM) paling cepat di Linux. GNOME Boxes paling mudah. Distrobox untuk menjalankan distro lain."
"Jaringan & keamanan?|m|packettracer wireshark nmap nettools openssh filezilla remmina wireguard burp|Untuk matkul Jaringan Komputer dan Keamanan Informasi. Gunakan secara etis."
"DevOps & AI?|m|kubectl ngrok ollama jupyter|LLM lokal butuh RAM 16GB+ supaya nyaman. RAM laptop ini: __RAM__ GB."
"Mobile & game development?|m|androidstudio flutter godot blender unity arduino|Emulator Android butuh KVM aktif (lihat Info Sistem)."
"Desain & multimedia?|m|figma drawio gimp inkscape obs vlc flameshot|draw.io wajib untuk UML/ERD/flowchart. Figma bisa juga lewat browser."
"Komunikasi?|m|discord zoom telegram slack|Sesuaikan dengan platform kelas dan dosen."
"Kuliah & produktivitas?|m|libreoffice okular obsidian zotero notion office|Microsoft 365 di Linux hanya versi web. LibreOffice untuk offline."
"Utilitas sistem?|m|flatpak fastfetch timeshift gparted localsend copyq ventoy gnometweaks|Timeshift = penyelamat kalau sistem rusak setelah update. Pasang di hari pertama."
)

VSEXT=(
"ms-vscode.cpptools-extension-pack|C/C++ Extension Pack|1|IntelliSense, debugging dan CMake untuk C/C++."
"formulahendry.code-runner|Code Runner|1|Tombol Run untuk menjalankan file C/C++/Python/Java/JS sekali klik."
"ms-python.python|Python|1|Dukungan Python lengkap: Pylance, debugger, venv."
"ms-toolsai.jupyter|Jupyter|0|Notebook .ipynb di VS Code."
"vscjava.vscode-java-pack|Extension Pack for Java|1|Java: Maven/Gradle, debugger, test runner."
"esbenp.prettier-vscode|Prettier|1|Format otomatis JS/TS/HTML/CSS/JSON."
"dbaeumer.vscode-eslint|ESLint|0|Linting JavaScript/TypeScript."
"ritwickdey.LiveServer|Live Server|1|Preview HTML dengan auto-reload."
"bmewburn.vscode-intelephense-client|PHP Intelephense|0|IntelliSense PHP terbaik untuk Laravel."
"eamodio.gitlens|GitLens|1|Blame per baris dan riwayat commit."
"mhutchie.git-graph|Git Graph|1|Visualisasi branch dan commit."
"ms-azuretools.vscode-docker|Docker|0|Kelola container dan Dockerfile."
"ms-vscode-remote.remote-ssh|Remote - SSH|0|Coding langsung di server lewat SSH."
"ms-vscode-remote.remote-containers|Dev Containers|0|Lingkungan dev di dalam container Docker."
"mtxr.sqltools|SQLTools|0|Query database dari VS Code."
"usernamehw.errorlens|Error Lens|1|Error dan warning tampil langsung di baris kode."
"christian-kohler.path-intellisense|Path Intellisense|1|Autocomplete nama file/path."
"timonwong.shellcheck|ShellCheck|1|Cek bug di script bash. Wajib untuk anak Linux."
"yzhang.markdown-all-in-one|Markdown All in One|0|Shortcut dan preview README.md."
"hediet.vscode-drawio|Draw.io Integration|0|Edit diagram draw.io di VS Code."
"MS-vsliveshare.vsliveshare|Live Share|0|Ngoding bareng teman secara realtime."
"GitHub.copilot|GitHub Copilot|0|AI autocomplete. Gratis untuk mahasiswa lewat GitHub Student Pack."
"PKief.material-icon-theme|Material Icon Theme|1|Ikon file yang cantik."
"zhuangtongfa.material-theme|One Dark Pro|0|Tema gelap paling populer."
)

BANNER=(
'██████╗ ███████╗██╗   ██╗███████╗███████╗████████╗██╗   ██╗██████╗ '
'██╔══██╗██╔════╝██║   ██║██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗'
'██║  ██║█████╗  ██║   ██║███████╗█████╗     ██║   ██║   ██║██████╔╝'
'██║  ██║██╔══╝  ╚██╗ ██╔╝╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ '
'██████╔╝███████╗ ╚████╔╝ ███████║███████╗   ██║   ╚██████╔╝██║     '
'╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     '
)
BCOL=("$E[38;5;201m" "$E[38;5;165m" "$E[38;5;129m" "$E[38;5;93m" "$E[38;5;57m" "$E[38;5;33m")

#@@MAC_ENGINE@@

# =====================================================================================
#  LINUX: DETEKSI DISTRO & PACKAGE MANAGER
# =====================================================================================
detect_distro() {
  D_ID=""; D_LIKE=""; D_NAME="Linux"; D_VER=""
  if [ -r /etc/os-release ]; then
    D_ID=$(. /etc/os-release; echo "${ID:-}"); D_LIKE=$(. /etc/os-release; echo "${ID_LIKE:-}")
    D_NAME=$(. /etc/os-release; echo "${PRETTY_NAME:-${NAME:-Linux}}"); D_VER=$(. /etc/os-release; echo "${VERSION_ID:-}")
  fi
  PM=""
  case " $D_ID $D_LIKE " in
    *" arch "*|*" manjaro "*|*" endeavouros "*|*" cachyos "*|*" garuda "*|*" artix "*) PM=pacman ;;
    *" debian "*|*" ubuntu "*|*" linuxmint "*|*" pop "*|*" kali "*|*" raspbian "*|*" elementary "*|*" zorin "*) PM=apt ;;
    *" fedora "*|*" rhel "*|*" centos "*|*" rocky "*|*" almalinux "*|*" nobara "*) PM=dnf ;;
    *" opensuse"*|*" suse "*|*" sles "*) PM=zypper ;;
    *" alpine "*) PM=apk ;;
  esac
  if [ -z "$PM" ]; then
    for c in apt-get:apt dnf:dnf pacman:pacman zypper:zypper apk:apk; do command -v "${c%%:*}" >/dev/null 2>&1 && { PM=${c##*:}; break; }; done
  fi
  [ -z "$PM" ] && PM=none
  IMMUTABLE=0
  if [ -e /run/ostree-booted ] || [ "$D_ID" = steamos ] || [ "$D_ID" = nixos ] || command -v rpm-ostree >/dev/null 2>&1; then IMMUTABLE=1; BASE_PM=$PM; PM=immutable; fi
  if [ "$IS_TERMUX" = 1 ]; then PM=termux; D_NAME="Termux $(getprop ro.build.version.release 2>/dev/null | sed 's/^/(Android /;s/$/)/')"; fi
  IS_CROS=0; [ -e /dev/.cros_milestone ] && IS_CROS=1
  IS_RPI=0; grep -qi 'raspberry pi' /proc/device-tree/model 2>/dev/null && IS_RPI=1
  case $PM in apt) PM_LABEL="apt (keluarga Debian/Ubuntu)" ;; dnf) PM_LABEL="dnf (keluarga Fedora/RHEL)" ;; pacman) PM_LABEL="pacman + AUR (keluarga Arch)" ;;
    zypper) PM_LABEL="zypper (openSUSE)" ;; apk) PM_LABEL="apk (Alpine)" ;; termux) PM_LABEL="pkg (Termux di Android)" ;;
    immutable) PM_LABEL="distro immutable: Flatpak + script di home (sistem tidak diubah)" ;; *) PM_LABEL="tidak dikenal: hanya Flatpak & script resmi" ;; esac
  IS_WSL=0; grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=1
  AUR_HELPER=""; for h in paru yay; do command -v $h >/dev/null 2>&1 && { AUR_HELPER=$h; break; }; done
  # ID tampilan untuk sistem notifikasi
}

# Tentukan cara install setiap item untuk distro ini -> K_TYPE / K_ID
resolve_methods() {
  local i v
  for ((i=0;i<NCAT;i++)); do
    case $PM in apt) v=${K_APT[$i]} ;; dnf) v=${K_DNF[$i]} ;; pacman) v=${K_PAC[$i]} ;; zypper) v=${K_ZYP[$i]} ;; apk) v=${K_APK[$i]} ;; termux) v=${K_TMX[$i]} ;; *) v="-" ;; esac
    if [ $PM = termux ]; then   # Termux: hanya paket pkg (tidak ada Flatpak/systemd/sudo)
      case "$v" in -|"") K_TYPE[$i]=none; K_ID[$i]="" ;; sh:*) K_TYPE[$i]=script; K_ID[$i]=${v#sh:} ;; *) K_TYPE[$i]=native; K_ID[$i]=$v ;; esac
      continue
    fi
    if [ -n "$v" ] && [ "$v" != "-" ]; then
      case "$v" in aur:*) K_TYPE[$i]=aur; K_ID[$i]=${v#aur:} ;; sh:*) K_TYPE[$i]=script; K_ID[$i]=${v#sh:} ;; *) K_TYPE[$i]=native; K_ID[$i]=$v ;; esac
    elif [ "${K_FLAT[$i]}" != "-" ] && [ -n "${K_FLAT[$i]}" ]; then K_TYPE[$i]=flatpak; K_ID[$i]=${K_FLAT[$i]}
    elif [ "${K_UNI[$i]}" != "-" ] && [ -n "${K_UNI[$i]}" ]; then
      case "${K_UNI[$i]}" in sh:*) K_TYPE[$i]=script; K_ID[$i]=${K_UNI[$i]#sh:} ;; info:*) K_TYPE[$i]=info; K_ID[$i]=${K_UNI[$i]#info:} ;; esac
      [ $PM = immutable ] && [ "${K_ID[$i]}" = ollama ] && { K_TYPE[$i]=none; K_ID[$i]=""; }
    else K_TYPE[$i]=none; K_ID[$i]=""; fi
  done
}

method_label() { # $1=index
  case "${K_TYPE[$1]}" in
    native) echo "$PM: ${K_ID[$1]//\// atau }" ;; aur) echo "AUR: ${K_ID[$1]} (lewat ${AUR_HELPER:-yay})" ;; flatpak) echo "Flatpak: ${K_ID[$1]}" ;;
    script) echo "script/repo resmi ($(script_desc "${K_ID[$1]}"))" ;; info) echo "Download manual: ${K_ID[$1]}" ;; *) echo "tidak tersedia" ;;
  esac
}
script_desc() { case $1 in vscode) echo "repo Microsoft" ;; chrome) echo "paket resmi Google" ;; docker) echo "get.docker.com" ;; rustup) echo "rustup.rs" ;;
  uv) echo "astral.sh" ;; bun) echo "bun.sh" ;; fnm) echo "fnm.vercel.app" ;; ollama) echo "ollama.com" ;; starship) echo "starship.rs" ;; kubectl) echo "dl.k8s.io" ;;
  nerdfont) echo "GitHub nerd-fonts" ;; ohmyzsh) echo "ohmyz.sh" ;; *) echo "$1" ;; esac; }

# Override: item yang tidak tersedia di distro ini tidak ditampilkan
cat_opt() {
  local i; i=$(ix "$1"); [ -z "$i" ] && return
  [ "${K_TYPE[$i]}" = none ] && return
  local b="" st
  if [ "${INST[$i]}" = 1 ]; then b="${GRN}✓ terpasang  "; elif [ "${CART[$i]}" = 1 ]; then b="${CYN}+ keranjang  "; fi
  [ "${K_REC[$i]}" = 1 ] && b="$b${YEL}★ rekomendasi  "
  case "${K_TYPE[$i]}" in info) b="$b${ORG}ⓘ manual  " ;; flatpak) b="$b${DIM}flatpak  " ;; aur) b="$b${BLU}AUR  " ;; esac
  in_list "$1" "$HEAVY" && [ "${SYS_RAM:-16}" -lt 12 ] && b="$b${RED}! berat untuk RAM ${SYS_RAM}GB"
  if [ "${INST[$i]}" = 1 ]; then st="Status: SUDAH TERPASANG di laptop ini."; else st="Status: belum terpasang."; fi
  opt_add "${K_NAME[$i]}" "${K_TIP[$i]}\n$st  |  $(method_label "$i")" "$1" "$b" "${CART[$i]}" "${INST[$i]}" "${K_REC[$i]}"
}

# =====================================================================================
#  SISTEM & DETEKSI TERPASANG
# =====================================================================================
get_sysinfo() {
  detect_distro
  SYS_OS="$D_NAME"
  SYS_ARCH=$(uname -m); SYS_KERNEL=$(uname -r)
  SYS_CPU=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//'); [ -z "$SYS_CPU" ] && SYS_CPU=$(uname -p)
  SYS_CORES="$(nproc 2>/dev/null) thread"
  SYS_RAM=$(( ($(grep MemTotal /proc/meminfo | awk '{print $2}') + 524288) / 1048576 ))
  SYS_MODEL=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || tr -d '\0' < /proc/device-tree/model 2>/dev/null || getprop ro.product.model 2>/dev/null || hostname 2>/dev/null || echo Linux)
  [ "$IS_WSL" = 1 ] && SYS_MODEL="WSL ($SYS_MODEL)"
  SYS_DISKFREE=$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2{print int($4/1048576)}'); SYS_DISKTOT=$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2{print int($2/1048576)}')
  SYS_SSD=1; for r in /sys/block/[sn][dv]*/queue/rotational; do [ -r "$r" ] && [ "$(cat "$r")" = 1 ] && SYS_SSD=0; done
  SYS_LAPTOP=0; ls /sys/class/power_supply/BAT* >/dev/null 2>&1 && SYS_LAPTOP=1
  SYS_DE="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-tanpa desktop / server}}"
  if [ -e /dev/kvm ]; then SYS_KVM="aktif (/dev/kvm ada)"; elif grep -Eq 'vmx|svm' /proc/cpuinfo 2>/dev/null; then SYS_KVM="CPU mendukung, modul KVM belum aktif"; else SYS_KVM="tidak tersedia (aktifkan VT-x/AMD-V di BIOS)"; fi
  SYS_NET=0; (curl -sI --max-time 5 https://github.com >/dev/null 2>&1 || wget -q --spider --timeout=5 https://github.com 2>/dev/null) && SYS_NET=1
  SYS_CHIP="$SYS_ARCH"
}

NATIVE_LIST=""; FLAT_LIST=""
scan_installed() {
  case $PM in
    apt|termux) NATIVE_LIST=$(dpkg-query -W -f='${db:Status-Abbrev} ${Package}\n' 2>/dev/null | awk '$1 ~ /^ii/ {print $2}' | sed 's/:.*//') ;;
    dnf|zypper) NATIVE_LIST=$(rpm -qa --qf '%{NAME}\n' 2>/dev/null) ;;
    pacman) NATIVE_LIST=$(pacman -Qq 2>/dev/null) ;;
    apk) NATIVE_LIST=$(apk info 2>/dev/null) ;;
  esac
  NATIVE_LIST=$'\n'"$NATIVE_LIST"$'\n'
  FLAT_LIST=$'\n'"$(flatpak list --app --columns=application 2>/dev/null)"$'\n'
  local i first det hit
  for ((i=0;i<NCAT;i++)); do
    hit=0
    case "${K_TYPE[$i]}" in
      native) first=${K_ID[$i]%% *}; for alt in ${first//\// }; do case "$NATIVE_LIST" in *$'\n'"$alt"$'\n'*) hit=1 ;; esac; done ;;
      aur) case "$NATIVE_LIST" in *$'\n'"${K_ID[$i]}"$'\n'*) hit=1 ;; esac ;;
      flatpak) case "$FLAT_LIST" in *$'\n'"${K_ID[$i]}"$'\n'*) hit=1 ;; esac ;;
    esac
    # versi Flatpak juga dihitung terpasang walau metode utamanya native
    [ $hit = 0 ] && [ "${K_FLAT[$i]}" != "-" ] && case "$FLAT_LIST" in *$'\n'"${K_FLAT[$i]}"$'\n'*) hit=1 ;; esac
    det=${K_DET[$i]}
    if [ $hit = 0 ] && [ -n "$det" ]; then
      case "$det" in cmd:*) command -v "${det#cmd:}" >/dev/null 2>&1 && hit=1 ;; dir:*) eval "[ -d ${det#dir:} ]" && hit=1 ;; esac
    fi
    INST[$i]=$hit; [ $hit = 1 ] && CART[$i]=0
  done
}

# =====================================================================================
#  INSTALLER
# =====================================================================================
pm_refresh() {
  case $PM in
    termux) pkg update -y ;;
    apt) $SUDO env DEBIAN_FRONTEND=noninteractive apt-get update ;;
    dnf) $SUDO dnf makecache ;;
    pacman) $SUDO pacman -Sy --noconfirm ;;
    zypper) $SUDO zypper --non-interactive refresh ;;
    apk) $SUDO apk update ;;
    *) true ;;
  esac
}
pkg_avail() { # apakah paket ada di repo distro
  case $PM in
    apt) apt-cache show "$1" >/dev/null 2>&1 ;;
    dnf) dnf -q list --available "$1" >/dev/null 2>&1 || rpm -q "$1" >/dev/null 2>&1 ;;
    pacman) pacman -Si "$1" >/dev/null 2>&1 || pacman -Q "$1" >/dev/null 2>&1 ;;
    zypper) zypper -q --non-interactive search -x "$1" >/dev/null 2>&1 ;;
    apk) [ -n "$(apk search -e "$1" 2>/dev/null)" ] ;;
    termux) apt-cache show "$1" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}
expand_alts() { # "a/b c" -> paket pertama yang tersedia dari setiap grup alternatif
  local tok alt out=""
  for tok in $1; do
    if [ "${tok#*/}" != "$tok" ]; then
      local pick=""; for alt in ${tok//\// }; do pkg_avail "$alt" && { pick=$alt; break; }; done
      out="$out ${pick:-${tok%%/*}}"
    else out="$out $tok"; fi
  done
  echo $out
}
pm_install() { # paket... (sengaja tidak di-quote supaya terpecah per paket)
  case $PM in
    termux) pkg install -y "$@" ;;
    apt) $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" ;;
    dnf) $SUDO dnf install -y "$@" ;;
    pacman) $SUDO pacman -S --needed --noconfirm "$@" ;;
    zypper) $SUDO zypper --non-interactive install --no-recommends "$@" ;;
    apk) $SUDO apk add "$@" ;;
    *) return 1 ;;
  esac
}
pm_upgrade() {
  case $PM in
    termux) pkg upgrade -y ;;
    apt) $SUDO env DEBIAN_FRONTEND=noninteractive apt-get update && $SUDO env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y ;;
    dnf) $SUDO dnf upgrade -y ;;
    pacman) if [ -n "$AUR_HELPER" ]; then $AUR_HELPER -Syu --noconfirm; else $SUDO pacman -Syu --noconfirm; fi ;;
    zypper) $SUDO zypper --non-interactive dup ;;
    apk) $SUDO apk upgrade ;;
  esac
}

ensure_flatpak() {
  command -v flatpak >/dev/null 2>&1 || pm_install flatpak || return 1
  flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}
ensure_aur() {
  [ -n "$AUR_HELPER" ] && return 0
  [ "$IS_ROOT" = 1 ] && { echo "AUR tidak bisa dipakai sebagai root (makepkg menolak). Jalankan script sebagai user biasa."; return 1; }
  pm_install base-devel git || return 1
  local d; d=$(mktemp -d)
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$d/yay-bin" && (cd "$d/yay-bin" && makepkg -si --noconfirm) || return 1
  AUR_HELPER=yay
}
aur_install() { ensure_aur && $AUR_HELPER -S --needed --noconfirm --answerdiff None --answerclean None "$@" 2>/dev/null || $AUR_HELPER -S --needed --noconfirm "$@"; }
dl() { if command -v curl >/dev/null 2>&1; then curl -fsSL "$1"; else wget -qO- "$1"; fi; }
add_path_line() { # tambah baris ke rc shell bila belum ada
  local line=$1 rc
  for rc in ~/.bashrc ~/.zshrc; do [ -f "$rc" ] || [ "$rc" = ~/.bashrc ] || continue; touch "$rc"; grep -qF "$line" "$rc" || echo "$line" >> "$rc"; done
}

# ---------- installer script / repo resmi ----------
inst_vscode() {
  case $PM in
    apt) pm_install wget gpg apt-transport-https
         dl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
         $SUDO install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
         echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | $SUDO tee /etc/apt/sources.list.d/vscode.list >/dev/null
         $SUDO env DEBIAN_FRONTEND=noninteractive apt-get update && pm_install code ;;
    dnf|zypper) $SUDO rpm --import https://packages.microsoft.com/keys/microsoft.asc
         printf '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n' > /tmp/vscode.repo
         if [ $PM = dnf ]; then $SUDO cp /tmp/vscode.repo /etc/yum.repos.d/vscode.repo; else $SUDO cp /tmp/vscode.repo /etc/zypp/repos.d/vscode.repo; $SUDO zypper --non-interactive --gpg-auto-import-keys refresh; fi
         pm_install code ;;
    *) ensure_flatpak && flatpak install --user -y flathub com.visualstudio.code ;;
  esac
}
inst_chrome() {
  [ "$SYS_ARCH" = x86_64 ] || { echo "Chrome resmi hanya untuk x86_64. Pakai Chromium."; return 1; }
  case $PM in
    apt) dl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /tmp/chrome.deb && pm_install /tmp/chrome.deb ;;
    dnf) $SUDO dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm ;;
    zypper) $SUDO rpm --import https://dl.google.com/linux/linux_signing_key.pub
            dl https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm > /tmp/chrome.rpm && pm_install /tmp/chrome.rpm ;;
    *) ensure_flatpak && flatpak install --user -y flathub com.google.Chrome ;;
  esac
}
inst_docker() {
  case $PM in
    apt|dnf) dl https://get.docker.com > /tmp/get-docker.sh && $SUDO sh /tmp/get-docker.sh || return 1 ;;
  esac
  $SUDO systemctl enable --now docker 2>/dev/null
  [ "$IS_ROOT" = 0 ] && $SUDO usermod -aG docker "$USER"
  NEED_RELOGIN=1
}
inst_rustup() { dl https://sh.rustup.rs | sh -s -- -y && add_path_line '. "$HOME/.cargo/env"'; }
inst_uv() { dl https://astral.sh/uv/install.sh | sh && add_path_line 'export PATH="$HOME/.local/bin:$PATH"'; }
inst_bun() { pm_install unzip >/dev/null 2>&1; dl https://bun.sh/install | bash && add_path_line 'export PATH="$HOME/.bun/bin:$PATH"'; }
inst_fnm() { pm_install unzip >/dev/null 2>&1; dl https://fnm.vercel.app/install | bash -s -- --skip-shell && add_path_line 'export PATH="$HOME/.local/share/fnm:$PATH"; eval "$(fnm env --use-on-cd 2>/dev/null)"'; }
inst_ollama() { dl https://ollama.com/install.sh | sh; }
inst_starship() { dl https://starship.rs/install.sh | sh -s -- -y && add_path_line 'eval "$(starship init bash)"'; }
inst_kubectl() {
  local a=amd64; [ "$SYS_ARCH" = aarch64 ] && a=arm64
  local v; v=$(dl https://dl.k8s.io/release/stable.txt) && dl "https://dl.k8s.io/release/$v/bin/linux/$a/kubectl" > /tmp/kubectl && $SUDO install -m 755 /tmp/kubectl /usr/local/bin/kubectl
}
inst_nerdfont() {
  pm_install unzip fontconfig >/dev/null 2>&1
  mkdir -p ~/.local/share/fonts/JetBrainsMono
  dl https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip > /tmp/jbm.zip && unzip -oq /tmp/jbm.zip -d ~/.local/share/fonts/JetBrainsMono && fc-cache -f
}
inst_ohmyzsh() {
  command -v zsh >/dev/null 2>&1 || pm_install zsh || return 1
  command -v git >/dev/null 2>&1 || pm_install git || return 1
  if [ ! -d ~/.oh-my-zsh ]; then RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(dl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || return 1; fi
  local c=~/.oh-my-zsh/custom/plugins
  [ -d $c/zsh-autosuggestions ] || git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions $c/zsh-autosuggestions
  [ -d $c/zsh-syntax-highlighting ] || git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting $c/zsh-syntax-highlighting
  [ -f ~/.zshrc ] || cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
  sed -i 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
  grep -q 'oh-my-zsh.sh' ~/.zshrc || printf '\nexport ZSH="$HOME/.oh-my-zsh"\nplugins=(git zsh-autosuggestions zsh-syntax-highlighting)\nsource $ZSH/oh-my-zsh.sh\n' >> ~/.zshrc
  if [ "$IS_TERMUX" = 1 ]; then chsh -s zsh 2>/dev/null; elif [ "$IS_ROOT" = 0 ]; then $SUDO chsh -s "$(command -v zsh)" "$USER" 2>/dev/null; fi
  NEED_RELOGIN=1
}

install_one() { # $1 = index ; return code = hasil
  local i=$1
  case "${K_TYPE[$i]}" in
    native) pm_install $(expand_alts "${K_ID[$i]}") ;;
    aur) aur_install ${K_ID[$i]} ;;
    flatpak) ensure_flatpak && flatpak install --user -y --noninteractive flathub "${K_ID[$i]}" ;;
    script) "inst_${K_ID[$i]}" ;;
    *) return 1 ;;
  esac
}

post_install() {
  # Debian/Ubuntu menamai beberapa perintah berbeda
  if [ $PM = apt ]; then
    mkdir -p ~/.local/bin
    command -v batcat >/dev/null && ! command -v bat >/dev/null && ln -sf "$(command -v batcat)" ~/.local/bin/bat
    command -v fdfind >/dev/null && ! command -v fd >/dev/null && ln -sf "$(command -v fdfind)" ~/.local/bin/fd
    add_path_line 'export PATH="$HOME/.local/bin:$PATH"'
  fi
  # layanan database
  command -v systemctl >/dev/null 2>&1 && for s in mariadb postgresql docker; do systemctl list-unit-files "$s.service" >/dev/null 2>&1 && $SUDO systemctl enable --now "$s" >/dev/null 2>&1; done
  if [ $PM = dnf ] && command -v postgresql-setup >/dev/null && [ ! -f /var/lib/pgsql/data/PG_VERSION ]; then $SUDO postgresql-setup --initdb >/dev/null 2>&1; $SUDO systemctl enable --now postgresql >/dev/null 2>&1; fi
  # data flatpak supaya muncul di menu aplikasi
  [ -d ~/.local/share/flatpak/exports/share ] && add_path_line 'export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"'
}

install_cart() {
  local order="" i n=0 total ok=0 skip=0 fail=0 info=0 failed="" notes="" t0=$SECONDS status msg t
  NEED_RELOGIN=0
  for t in native aur script flatpak info; do for ((i=0;i<NCAT;i++)); do [ "${CART[$i]}" = 1 ] && [ "${K_TYPE[$i]}" = $t ] && order="$order $i"; done; done
  total=$(echo $order | wc -w | tr -d ' ')
  printf '%s' "$E[2J$E[H"; show_banner
  printf '\n  %s═══ INSTALASI DIMULAI · %s item · %s · log: %s%s\n\n' "$MAG" "$total" "$PM" "$LOG" "$R0"
  if [ "$IS_ROOT" = 0 ] && [ -n "$SUDO" ] && ! sudo -n true 2>/dev/null; then
    printf '  %sMasukkan password sudo sekali di sini (untuk %s):%s\n' "$DIM" "$PM" "$R0"; show_cur
    sudo -v || { printf '  %sButuh akses sudo untuk memasang paket.%s\n' "$RED" "$R0"; pause_key; return; }
    ( while true; do sudo -n true; sleep 50; kill -0 $$ 2>/dev/null || exit; done ) 2>/dev/null & SUDO_PID=$!
    hide_cur; echo
  fi
  spin "Memperbarui daftar paket ($PM)..." pm_refresh
  printf '\r   %s✓ Daftar paket diperbarui%s%s\n' "$DIM" "$R0" "$E[K"
  local need_aur=0; for i in $order; do [ "${K_TYPE[$i]}" = aur ] && need_aur=1; done
  if [ $need_aur = 1 ] && [ -z "$AUR_HELPER" ]; then
    spin "Menyiapkan AUR helper (yay)..." ensure_aur
    if [ "$SPIN_RC" = 0 ]; then AUR_HELPER=yay; printf '\r   %s✓ yay siap%s%s\n' "$DIM" "$R0" "$E[K"; else printf '\r   %s✗ yay gagal dipasang, item AUR akan gagal%s%s\n' "$RED" "$R0" "$E[K"; fi
  fi
  for i in $order; do
    n=$((n+1)); status=fail; msg=""
    printf '  %s%s  [%s/%s] %s%s · %s%s\n' "$MAG" "$(bar $((n-1)) $total)" $n $total "$DIM" "${K_CAT[$i]}" "${K_TYPE[$i]}" "$R0"
    if [ "${K_TYPE[$i]}" = info ]; then status=info; notes="$notes${K_NAME[$i]}|${K_ID[$i]}"$'\n'
    else
      spin "Menginstall ${K_NAME[$i]}" install_one "$i"
      [ "$SPIN_RC" = 0 ] && status=ok || msg="exit $SPIN_RC, lihat log"
    fi
    case $status in
      ok) printf '\r   %s✓ %s  (%ss)%s%s\n' "$GRN" "${K_NAME[$i]}" "$SPIN_SECS" "$R0" "$E[K"; ok=$((ok+1)); INST[$i]=1; CART[$i]=0 ;;
      info) printf '\r   %sⓘ %s  -> perlu download manual (lihat catatan di akhir)%s%s\n' "$ORG" "${K_NAME[$i]}" "$R0" "$E[K"; info=$((info+1)); CART[$i]=0 ;;
      fail) printf '\r   %s✗ %s  GAGAL: %s%s%s\n' "$RED" "${K_NAME[$i]}" "$msg" "$R0" "$E[K"; fail=$((fail+1)); failed="$failed${failed:+, }${K_NAME[$i]}" ;;
    esac
    log "${K_KEY[$i]}: ${K_TYPE[$i]} ${K_ID[$i]} -> $status $msg"
  done
  spin "Merapikan konfigurasi..." post_install; printf '\r%s' "$E[K"
  [ -n "$SUDO_PID" ] && { kill $SUDO_PID 2>/dev/null; SUDO_PID=""; }
  printf '  %s%s%s\n\n' "$MAG" "$(bar $total $total)" "$R0"
  local mins=$(( (SECONDS-t0)/60 ))
  printf '  %s╔══════════════════════════════════════════════════════════╗\n' "$MAG"
  printf '  ║  RINGKASAN  ·  waktu total ~%-3s menit                     ║\n' "$mins"
  printf '  ╠══════════════════════════════════════════════════════════╣%s\n' "$R0"
  printf '  %s║%s   %s✓ Berhasil        : %-4s%s                               %s║%s\n' "$MAG" "$R0" "$GRN" "$ok" "$R0" "$MAG" "$R0"
  printf '  %s║%s   %sⓘ Manual/catatan  : %-4s%s                               %s║%s\n' "$MAG" "$R0" "$ORG" "$info" "$R0" "$MAG" "$R0"
  printf '  %s║%s   %s✗ Gagal           : %-4s%s                               %s║%s\n' "$MAG" "$R0" "$RED" "$fail" "$R0" "$MAG" "$R0"
  printf '  %s╚══════════════════════════════════════════════════════════╝%s\n' "$MAG" "$R0"
  [ -n "$failed" ] && printf '  %sGagal: %s\n  Item yang gagal tetap di keranjang dan bisa dicoba lagi. Detail ada di log.%s\n' "$RED" "$failed" "$R0"
  if [ -n "$notes" ]; then
    printf '\n  %sPerlu download/instal manual:%s\n' "$YEL" "$R0"
    echo "$notes" | while IFS='|' read -r nm url; do [ -n "$nm" ] && printf '   • %s: %s\n' "$nm" "$url"; done
    if [ "$UNATTENDED$TEST_MODE" = 00 ] && command -v xdg-open >/dev/null 2>&1 && [ -n "$DISPLAY$WAYLAND_DISPLAY" ] && yesno "Buka semua link di browser?" y; then
      echo "$notes" | while IFS='|' read -r nm url; do [ -n "$url" ] && xdg-open "$url" >/dev/null 2>&1 & done; fi
  fi
  printf '\n  %sTip: buka terminal baru (atau: source ~/.bashrc) supaya PATH baru terbaca.%s\n' "$CYN" "$R0"
  [ "$NEED_RELOGIN" = 1 ] && printf '  %sLogout lalu login lagi supaya grup docker / shell zsh aktif.%s\n' "$YEL" "$R0"
  INSTALL_FAIL=$fail
  [ "$UNATTENDED" = 1 ] || pause_key
}

clip_copy() { # salin stdin ke clipboard bila ada alatnya
  if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null; then wl-copy
  elif command -v xclip >/dev/null; then xclip -selection clipboard
  elif command -v xsel >/dev/null; then xsel -ib
  elif [ "$IS_WSL" = 1 ] && command -v clip.exe >/dev/null; then clip.exe
  else cat >/dev/null; return 1; fi
}

setup_vscode_ext() {
  local code="" e have id nm rec tip ins
  for c in code codium; do command -v $c >/dev/null && { code=$c; break; }; done
  if [ -z "$code" ] && flatpak info com.visualstudio.code >/dev/null 2>&1; then code="flatpak run com.visualstudio.code"; fi
  if [ -z "$code" ]; then printf '%s' "$E[2J$E[H"; printf '\n  %sVS Code belum terpasang. Install dulu lewat menu lain.%s\n' "$RED" "$R0"; pause_key; return; fi
  printf '%s\n   %sMembaca ekstensi yang sudah terpasang...%s' "$E[2J$E[H" "$DIM" "$R0"
  have=" $($code --list-extensions 2>/dev/null | tr 'A-Z' 'a-z' | tr '\n' ' ') "
  opt_reset
  for e in "${VSEXT[@]}"; do
    IFS='|' read -r id nm rec tip <<< "$e"
    ins=0; in_list "$(echo "$id" | tr 'A-Z' 'a-z')" "$have" && ins=1
    local b=""; [ $ins = 1 ] && b="${GRN}✓ terpasang  "; [ "$rec" = 1 ] && b="$b${YEL}★ rekomendasi"
    local chk=0; [ "$rec" = 1 ] && [ $ins = 0 ] && chk=1
    opt_add "$nm" "$tip\nID: $id" "$id" "$b" $chk $ins "$rec"
  done
  select_list "Ekstensi VS Code" "Yang direkomendasikan sudah dicentang. Enter untuk memasang." multi 0 "pasang"
  [ "$RES_OK" != 1 ] && return
  printf '%s\n' "$E[2J$E[H"
  local n=0 t; t=$(echo $RES_VALUES | wc -w | tr -d ' ')
  for e in $RES_VALUES; do n=$((n+1)); spin "[$n/$t] $e" $code --install-extension "$e" --force
    [ "$SPIN_RC" = 0 ] && printf '\r   %s✓ %s%s%s\n' "$GRN" "$e" "$R0" "$E[K" || printf '\r   %s✗ %s (gagal)%s%s\n' "$RED" "$e" "$R0" "$E[K"; done
  pause_key
}

setup_git() {
  printf '%s' "$E[2J$E[H"; show_cur
  printf '\n  %s═══ SETUP GIT & SSH KEY ═══%s\n\n' "$MAG" "$R0"
  command -v git >/dev/null || { printf '  %sGit belum terpasang.%s\n' "$RED" "$R0"; pause_key; return; }
  local cn ce; cn=$(git config --global user.name); ce=$(git config --global user.email)
  printf '  %sKonfigurasi sekarang: %s%s\n\n' "$DIM" "${cn:+$cn <$ce>}${cn:-(belum ada)}" "$R0"
  ask "Nama lengkap (tampil di commit)" "$cn"; local name=$REPLY_VAL
  ask "Email (SAMA dengan email akun GitHub)" "$ce"; local mail=$REPLY_VAL
  git config --global user.name "$name"; git config --global user.email "$mail"
  git config --global init.defaultBranch main; git config --global core.autocrlf input; git config --global pull.rebase false
  command -v code >/dev/null && git config --global core.editor "code --wait"
  printf '  %s✓ user.name, user.email, defaultBranch=main, autocrlf=input%s\n' "$GRN" "$R0"
  if [ ! -f ~/.ssh/id_ed25519 ]; then
    if yesno "Buat SSH key baru (ed25519) untuk GitHub?" y; then mkdir -p ~/.ssh && chmod 700 ~/.ssh; ssh-keygen -t ed25519 -C "$mail" -f ~/.ssh/id_ed25519 -N "" -q; fi
  else printf '  %sSSH key sudah ada, dipakai ulang.%s\n' "$DIM" "$R0"; fi
  if [ -f ~/.ssh/id_ed25519.pub ]; then
    if clip_copy < ~/.ssh/id_ed25519.pub; then printf '\n  %sSSH public key (sudah DICOPY ke clipboard):%s\n' "$GRN" "$R0"; else printf '\n  %sSSH public key (copy manual baris di bawah):%s\n' "$GRN" "$R0"; fi
    printf '  %s%s%s\n' "$WHT" "$(cat ~/.ssh/id_ed25519.pub)" "$R0"
    printf '\n  %s1. Buka github.com/settings/ssh/new  2. Paste (Ctrl+Shift+V di terminal)  3. Add SSH key%s\n' "$YEL" "$R0"
    command -v xdg-open >/dev/null && [ -n "$DISPLAY$WAYLAND_DISPLAY" ] && yesno "Buka halaman GitHub SSH sekarang?" y && xdg-open "https://github.com/settings/ssh/new" >/dev/null 2>&1 &
    yesno "Tes koneksi ke GitHub (setelah key ditambahkan)?" n && ssh -T -o StrictHostKeyChecking=accept-new git@github.com
  fi
  command -v gh >/dev/null && yesno "Login GitHub CLI (gh auth login) juga?" n && gh auth login
  printf '\n  %sBonus: GitHub Student Developer Pack (Copilot, JetBrains, domain gratis): https://education.github.com/pack%s\n' "$CYN" "$R0"
  pause_key
}

setup_tweaks() {
  local gs=0; command -v gsettings >/dev/null && [ -n "$DISPLAY$WAYLAND_DISPLAY" ] && gs=1
  local cur_watch; cur_watch=$(cat /proc/sys/fs/inotify/max_user_watches 2>/dev/null || echo 0)
  local TW=()
  TW+=("inotify|Naikkan batas file watcher (inotify)|Mencegah error 'ENOSPC: System limit for number of file watchers reached' di VS Code, npm run dev dan Vite.|$( [ "$cur_watch" -ge 524288 ] && echo 1 || echo 0)")
  TW+=("dialout|Izin port serial (grup dialout/uucp)|Supaya Arduino/ESP32 bisa di-upload tanpa sudo. Berlaku setelah logout-login.|$(id -nG | grep -qwE 'dialout|uucp' && echo 1 || echo 0)")
  getent group docker >/dev/null && TW+=("dockergrp|Pakai docker tanpa sudo (grup docker)|Menambahkan user ke grup docker. Berlaku setelah logout-login.|$(id -nG | grep -qw docker && echo 1 || echo 0)")
  getent group libvirt >/dev/null && TW+=("libvirt|Pakai virt-manager tanpa password (grup libvirt)|Menambahkan user ke grup libvirt untuk VM KVM.|$(id -nG | grep -qw libvirt && echo 1 || echo 0)")
  if [ $gs = 1 ]; then
    TW+=("dark|Mode gelap (GNOME/GTK)|Tema gelap untuk desktop dan aplikasi GTK.|$( [ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" = "'prefer-dark'" ] && echo 1 || echo 0)")
    TW+=("hidden|Tampilkan file tersembunyi di file manager|Supaya .git, .env, .config terlihat. Shortcut manual: Ctrl+H.|$( [ "$(gsettings get org.gtk.gtk4.Settings.FileChooser show-hidden 2>/dev/null)" = true ] && echo 1 || echo 0)")
    TW+=("battery|Tampilkan persentase baterai|Persentase baterai di top bar GNOME.|$( [ "$(gsettings get org.gnome.desktop.interface show-battery-percentage 2>/dev/null)" = true ] && echo 1 || echo 0)")
  fi
  local t k nm d on
  opt_reset
  for t in "${TW[@]}"; do IFS='|' read -r k nm d on <<< "$t"; opt_add "$nm" "$d" "$k" "$( [ "$on" = 1 ] && printf '%s✓ sudah aktif' "$GRN")" $((1-on)) "$on" 1; done
  select_list "Tweak Linux untuk Developer" "Pengaturan yang bikin Linux lebih ramah programmer. Yang belum aktif sudah dicentang." multi 0 "terapkan"
  [ "$RES_OK" != 1 ] && return
  printf '%s\n' "$E[2J$E[H"; show_cur
  [ "$IS_ROOT" = 0 ] && sudo -v
  for k in $RES_VALUES; do
    case $k in
      inotify) echo 'fs.inotify.max_user_watches=524288' | $SUDO tee /etc/sysctl.d/60-devsetup-inotify.conf >/dev/null && $SUDO sysctl -p /etc/sysctl.d/60-devsetup-inotify.conf >/dev/null ;;
      dialout) if getent group uucp >/dev/null && [ $PM = pacman ]; then $SUDO usermod -aG uucp "$USER"; else $SUDO usermod -aG dialout "$USER"; fi ;;
      dockergrp) $SUDO usermod -aG docker "$USER" ;;
      libvirt) $SUDO usermod -aG libvirt "$USER" ;;
      dark) gsettings set org.gnome.desktop.interface color-scheme prefer-dark; gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark 2>/dev/null ;;
      hidden) gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true 2>/dev/null; gsettings set org.gtk.Settings.FileChooser show-hidden true 2>/dev/null; gsettings set org.gnome.nautilus.preferences show-hidden-files true 2>/dev/null ;;
      battery) gsettings set org.gnome.desktop.interface show-battery-percentage true ;;
    esac
    printf '   %s✓ %s%s\n' "$GRN" "$k" "$R0"
  done
  printf '   %sPerubahan grup berlaku setelah logout lalu login lagi.%s\n' "$DIM" "$R0"
  pause_key
}

# =====================================================================================
#  TUNE-UP & DEBLOAT Linux
# =====================================================================================
svc_active() { command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet "$1" 2>/dev/null; }
svc_enabled() { command -v systemctl >/dev/null 2>&1 && systemctl is-enabled --quiet "$1" 2>/dev/null; }
tune_up() {
  printf '%s\n   %sMenghitung ukuran cache, tunggu sebentar...%s' "$E[2J$E[H" "$DIM" "$R0"
  local pc=0
  case $PM in apt) pc=$(dir_bytes /var/cache/apt/archives) ;; dnf) pc=$(dir_bytes /var/cache/dnf /var/cache/libdnf5) ;; pacman) pc=$(dir_bytes /var/cache/pacman/pkg) ;;
    zypper) pc=$(dir_bytes /var/cache/zypp/packages) ;; apk) pc=$(dir_bytes /var/cache/apk) ;; termux) pc=$(dir_bytes "$PREFIX/var/cache/apt/archives") ;; esac
  local jr=0; command -v journalctl >/dev/null && jr=$(journalctl --disk-usage 2>/dev/null | grep -oE '[0-9.]+[KMGT]' | head -1)
  local th; th=$(dir_bytes ~/.cache/thumbnails); local dv; dv=$(dir_bytes ~/.npm/_cacache ~/.cache/pip ~/.cache/yarn ~/.gradle/caches ~/.cache/go-build)
  local zr=0; swapon --show 2>/dev/null | grep -q zram && zr=1
  local eo=0; { svc_active earlyoom || svc_active systemd-oomd; } && eo=1
  local ft=0; svc_enabled fstrim.timer && ft=1
  local sw; sw=$(cat /proc/sys/vm/swappiness 2>/dev/null || echo 60)
  local old=0; [ "${SYS_RAM:-8}" -le 8 ] && old=1
  local gn=0; command -v gsettings >/dev/null && [ -n "$DISPLAY$WAYLAND_DISPLAY" ] && gn=1
  local TU=()
  TU+=("pkgcache|Bersihkan cache paket & paket yatim ($(human "$pc"))|Hapus installer paket lama di cache dan dependensi yang sudah tidak dipakai ($PM).|1|0")
  command -v flatpak >/dev/null && TU+=("flatunused|Hapus runtime Flatpak yang tidak terpakai|flatpak uninstall --unused. Sering membebaskan ratusan MB sampai beberapa GB.|1|0")
  [ "$IS_TERMUX" = 0 ] && command -v journalctl >/dev/null && TU+=("journal|Batasi log sistem (journal $jr) ke 100 MB|Log lama dihapus dan ukuran maksimal diatur supaya tidak terus membengkak.|1|0")
  TU+=("thumbs|Hapus cache thumbnail ($(human "$th"))|Gambar mini file manager, dibuat ulang otomatis.|0|0")
  TU+=("devcache|Bersihkan cache developer ($(human "$dv"))|npm, pip, yarn, Gradle dan Go build cache. Diunduh/dibuat ulang saat dibutuhkan.|0|0")
  if [ "$IS_TERMUX" = 0 ] && [ $PM != immutable ]; then
    TU+=("zram|Aktifkan zram (RAM terkompresi)|Swap di dalam RAM yang dikompresi: laptop RAM 4-8 GB jauh lebih jarang lag/freeze saat banyak tab. Hampir tanpa efek samping.|$old|$zr")
    TU+=("earlyoom|Pasang earlyoom (anti freeze)|Kalau RAM hampir habis, aplikasi paling boros ditutup sebelum seluruh sistem macet. Penyelamat laptop lama.|$old|$eo")
    TU+=("swappiness|Swappiness = 10 (sekarang $sw)|Kernel lebih lama menahan data di RAM sebelum memakai swap disk. Bagus untuk RAM 8 GB+ tanpa zram.|0|$( [ "$sw" -le 10 ] && echo 1 || echo 0)")
    [ "$SYS_SSD" = 1 ] && TU+=("fstrim|Aktifkan TRIM SSD mingguan (fstrim.timer)|Menjaga kecepatan tulis SSD tetap optimal.|1|$ft")
    [ "$SYS_LAPTOP" = 1 ] && TU+=("tlp|Pasang TLP (hemat baterai laptop)|Pengaturan daya otomatis untuk baterai lebih awet. power-profiles-daemon akan dinonaktifkan karena bentrok.|0|$(svc_enabled tlp && echo 1 || echo 0)")
  fi
  [ $gn = 1 ] && TU+=("anim|Matikan animasi desktop (GNOME)|Desktop terasa lebih responsif di GPU lama.|$old|$( [ "$(gsettings get org.gnome.desktop.interface enable-animations 2>/dev/null)" = false ] && echo 1 || echo 0)")
  command -v resolvectl >/dev/null && TU+=("dns|Flush DNS cache|Untuk situs yang tidak bisa dibuka setelah ganti jaringan/DNS.|0|0")
  TU+=("big|Cari file besar (> 500 MB) di folder home|Hanya menampilkan daftar, tidak menghapus apa pun.|0|0")
  local t k n d r on
  opt_reset
  for t in "${TU[@]}"; do IFS='|' read -r k n d r on <<< "$t"
    local chk=$r; [ "$on" = 1 ] && chk=0
    opt_add "$n" "$d" "$k" "$( [ "$on" = 1 ] && printf '%s✓ sudah aktif  ' "$GRN")$( [ "$r" = 1 ] && printf '%s★ rekomendasi' "$YEL")" "$chk" "$on" "$r"; done
  select_list "Tune-Up & Optimasi" "RAM ${SYS_RAM} GB, $( [ "$SYS_SSD" = 1 ] && echo SSD || echo HDD), disk kosong ${SYS_DISKFREE} GB. Rekomendasi untuk laptop ini sudah dicentang." multi 0 "jalankan"
  [ "$RES_OK" != 1 ] && return
  printf '%s\n  %s═══ TUNE-UP ═══%s\n\n' "$E[2J$E[H" "$MAG" "$R0"; show_cur
  [ -n "$SUDO" ] && ! sudo -n true 2>/dev/null && sudo -v
  local before; before=$(df -Pk / | awk 'NR==2{print $4}')
  for k in $RES_VALUES; do
    log "TUNE $k"; local ok=0
    case $k in
      pkgcache) case $PM in
          apt) $SUDO apt-get clean && $SUDO env DEBIAN_FRONTEND=noninteractive apt-get autoremove -y >>"$LOG" 2>&1 && ok=1 ;;
          dnf) $SUDO dnf clean all >>"$LOG" 2>&1; $SUDO dnf autoremove -y >>"$LOG" 2>&1 && ok=1 ;;
          pacman) $SUDO pacman -Sc --noconfirm >>"$LOG" 2>&1; o=$(pacman -Qdtq 2>/dev/null); [ -n "$o" ] && $SUDO pacman -Rns --noconfirm $o >>"$LOG" 2>&1; ok=1 ;;
          zypper) $SUDO zypper --non-interactive clean -a >>"$LOG" 2>&1 && ok=1 ;;
          apk) $SUDO apk cache clean >>"$LOG" 2>&1; ok=1 ;;
          termux) pkg clean >>"$LOG" 2>&1; pkg autoclean >>"$LOG" 2>&1; ok=1 ;;
          immutable) command -v rpm-ostree >/dev/null && $SUDO rpm-ostree cleanup -b -m >>"$LOG" 2>&1; ok=1 ;;
        esac ;;
      flatunused) flatpak uninstall --unused -y >>"$LOG" 2>&1 && ok=1 ;;
      journal) $SUDO journalctl --vacuum-size=100M >>"$LOG" 2>&1 && { $SUDO mkdir -p /etc/systemd/journald.conf.d; printf '[Journal]\nSystemMaxUse=200M\n' | $SUDO tee /etc/systemd/journald.conf.d/60-tipack.conf >/dev/null; ok=1; } ;;
      thumbs) rm -rf ~/.cache/thumbnails/* 2>/dev/null; ok=1 ;;
      devcache) command -v npm >/dev/null && npm cache clean --force >>"$LOG" 2>&1; command -v pip3 >/dev/null && pip3 cache purge >>"$LOG" 2>&1; rm -rf ~/.cache/yarn ~/.gradle/caches ~/.cache/go-build 2>/dev/null; ok=1 ;;
      zram) case $PM in
          apt) pm_install zram-tools >>"$LOG" 2>&1 && printf 'ALGO=zstd\nPERCENT=50\nPRIORITY=100\n' | $SUDO tee /etc/default/zramswap >/dev/null && $SUDO systemctl restart zramswap >>"$LOG" 2>&1 && ok=1 ;;
          dnf|pacman|zypper) pm_install zram-generator >>"$LOG" 2>&1 && printf '[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\n' | $SUDO tee /etc/systemd/zram-generator.conf >/dev/null && $SUDO systemctl daemon-reload && $SUDO systemctl start systemd-zram-setup@zram0.service >>"$LOG" 2>&1 && ok=1 ;;
          apk) pm_install zram-init >>"$LOG" 2>&1 && $SUDO rc-update add zram-init default >>"$LOG" 2>&1 && $SUDO rc-service zram-init start >>"$LOG" 2>&1 && ok=1 ;;
        esac ;;
      earlyoom) pm_install earlyoom >>"$LOG" 2>&1 && { command -v systemctl >/dev/null && $SUDO systemctl enable --now earlyoom >>"$LOG" 2>&1 || $SUDO rc-update add earlyoom default >>"$LOG" 2>&1; ok=1; } ;;
      swappiness) echo 'vm.swappiness=10' | $SUDO tee /etc/sysctl.d/61-tipack-swappiness.conf >/dev/null && $SUDO sysctl -q -p /etc/sysctl.d/61-tipack-swappiness.conf && ok=1 ;;
      fstrim) $SUDO systemctl enable --now fstrim.timer >>"$LOG" 2>&1 && ok=1 ;;
      tlp) pm_install tlp >>"$LOG" 2>&1 && { $SUDO systemctl mask power-profiles-daemon >>"$LOG" 2>&1; $SUDO systemctl enable --now tlp >>"$LOG" 2>&1; ok=1; } ;;
      anim) gsettings set org.gnome.desktop.interface enable-animations false && ok=1 ;;
      dns) $SUDO resolvectl flush-caches && ok=1 ;;
      big) printf '  %sFile terbesar di %s:%s\n' "$CYN" "$HOME" "$R0"; find ~ -xdev -type f -size +500M 2>/dev/null | head -200 | while IFS= read -r f; do du -h "$f" 2>/dev/null; done | sort -rh | head -15 | sed 's/^/     /'; ok=1 ;;
    esac
    [ $ok = 1 ] && printf '   %s✓ %s%s\n' "$GRN" "$k" "$R0" || printf '   %s✗ %s (lihat log)%s\n' "$RED" "$k" "$R0"
  done
  local after; after=$(df -Pk / | awk 'NR==2{print $4}')
  [ "$after" -gt "$before" ] && printf '\n   %sRuang kosong bertambah: %s%s\n' "$GRN" "$(human $(( (after-before)*1024 )))" "$R0"
  pause_key
}

debloat() {
  opt_reset
  local any=0
  if command -v snap >/dev/null 2>&1 && [ $PM = apt ]; then
    local sn; sn=$(snap list 2>/dev/null | awk 'NR>1{print $1}' | tr '\n' ' ')
    opt_add "Lepas Snap sepenuhnya (Ubuntu)" "Menghapus semua snap ($sn) dan snapd, lalu mengunci supaya tidak terpasang lagi. Aplikasi jadi lebih cepat terbuka dan disk lebih lega. Firefox diganti versi Flatpak. PERUBAHAN BESAR: pastikan tidak ada data penting di aplikasi snap." "snap" "${RED}perubahan besar" 0 0 0; any=1
  fi
  if [ $PM = apt ] && grep -qi ubuntu /etc/os-release 2>/dev/null; then
    local tel=""; for x in popularity-contest ubuntu-report apport whoopsie; do case "$NATIVE_LIST" in *$'\n'"$x"$'\n'*) tel="$tel $x" ;; esac; done
    [ -n "$tel" ] && { opt_add "Hapus telemetri & pelaporan error Ubuntu" "Menghapus paket:$tel. Ubuntu tidak lagi mengirim statistik pemakaian dan laporan crash." "ubtel" "${YEL}★ rekomendasi" 1 0 1; any=1; }
  fi
  if command -v systemctl >/dev/null 2>&1 && [ "$IS_TERMUX" = 0 ]; then
    local sv
    for sv in "cups|Printer (CUPS)|Matikan kalau tidak pernah mencetak dari laptop ini.|0" "bluetooth|Bluetooth|Matikan kalau tidak memakai mouse/headset bluetooth.|0" "ModemManager|ModemManager|Untuk modem/kartu SIM internal. Hampir tidak pernah dipakai di laptop.|1" "avahi-daemon|Avahi (discovery jaringan lokal)|Untuk menemukan printer/perangkat di jaringan otomatis.|0" "packagekit|PackageKit (cek update di latar)|Sering memakan CPU/RAM di belakang. Update tetap bisa lewat menu Update Semua.|0"; do
      IFS='|' read -r k n d r <<< "$sv"
      if svc_enabled "$k" || svc_active "$k"; then opt_add "Matikan layanan: $n" "$d Bisa diaktifkan lagi: sudo systemctl enable --now $k" "svc:$k" "$( [ "$r" = 1 ] && printf '%s★ rekomendasi' "$YEL")" "$r" 0 "$r"; any=1; fi
    done
  fi
  if [ $any = 0 ]; then printf '%s\n  %sTidak ada yang perlu di-debloat di sistem ini. Mantap!%s\n' "$E[2J$E[H" "$GRN" "$R0"; pause_key; return; fi
  select_list "Debloat Linux" "Lepas Snap, telemetri dan layanan latar yang tidak terpakai. Semua bisa dikembalikan lewat package manager." multi 0 "jalankan"
  [ "$RES_OK" != 1 ] && return
  printf '%s\n  %s═══ DEBLOAT ═══%s\n\n' "$E[2J$E[H" "$MAG" "$R0"; show_cur
  [ -n "$SUDO" ] && ! sudo -n true 2>/dev/null && sudo -v
  local v
  for v in $RES_VALUES; do
    log "DEBLOAT $v"
    case $v in
      snap)
        local pass=0
        while [ $pass -lt 4 ] && [ -n "$(snap list 2>/dev/null | awk 'NR>1 && $1!="snapd"{print $1}')" ]; do
          for x in $(snap list 2>/dev/null | awk 'NR>1 && $1!="snapd"{print $1}'); do spin "snap remove $x" $SUDO snap remove --purge "$x"; printf '\r%s' "$E[K"; done; pass=$((pass+1))
        done
        spin "Menghapus snapd" $SUDO env DEBIAN_FRONTEND=noninteractive apt-get purge -y snapd
        printf 'Package: snapd\nPin: release a=*\nPin-Priority: -10\n' | $SUDO tee /etc/apt/preferences.d/no-snap.pref >/dev/null
        rm -rf ~/snap; $SUDO rm -rf /snap /var/snap /var/lib/snapd 2>/dev/null
        printf '\r   %s✓ Snap dilepas%s%s\n' "$GRN" "$R0" "$E[K"
        if yesno "Pasang Firefox versi Flatpak sebagai pengganti?" y; then spin "Firefox (Flatpak)" sh -c 'command -v flatpak >/dev/null || sudo apt-get install -y flatpak; flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && flatpak install --user -y flathub org.mozilla.firefox'; printf '\r   %s✓ Firefox Flatpak%s%s\n' "$GRN" "$R0" "$E[K"; fi ;;
      ubtel) $SUDO env DEBIAN_FRONTEND=noninteractive apt-get purge -y popularity-contest ubuntu-report apport whoopsie >>"$LOG" 2>&1; printf '   %s✓ telemetri Ubuntu dihapus%s\n' "$GRN" "$R0" ;;
      svc:*) k=${v#svc:}; $SUDO systemctl disable --now "$k" >>"$LOG" 2>&1 && printf '   %s✓ %s dimatikan%s\n' "$GRN" "$k" "$R0" || printf '   %s✗ %s gagal%s\n' "$RED" "$k" "$R0" ;;
    esac
  done
  pause_key
}

update_all() {
  printf '%s' "$E[2J$E[H"; show_cur
  printf '\n  %s═══ UPDATE SEMUA (%s + flatpak) ═══%s\n\n' "$MAG" "$PM" "$R0"
  pm_upgrade
  command -v flatpak >/dev/null && flatpak update -y
  scan_installed; pause_key
}

show_sysinfo() {
  local rt
  if [ "$SYS_RAM" -lt 8 ]; then rt="RAM di bawah 8GB: pilih desktop ringan (XFCE/LXQt), hindari Android Studio + Docker bersamaan."
  elif [ "$SYS_RAM" -lt 16 ]; then rt="RAM 8-12GB: cukup untuk kuliah. Emulator Android akan terasa berat."
  else rt="RAM 16GB+: aman untuk Docker, VM, Android Studio dan LLM lokal."; fi
  opt_reset
  opt_add "Distro  : $SYS_OS" "ID: $D_ID ${D_LIKE:+(turunan: $D_LIKE)}  versi: ${D_VER:-rolling}"
  opt_add "Paket   : $PM_LABEL" "Package manager yang dipakai. Aplikasi yang tidak ada di repo diambil dari Flatpak (Flathub)${AUR_HELPER:+; AUR helper: $AUR_HELPER}."
  opt_add "Kernel  : $SYS_KERNEL ($SYS_ARCH)" "Arsitektur $SYS_ARCH. Beberapa aplikasi (Chrome, Android Studio) hanya untuk x86_64."
  opt_add "Desktop : $SYS_DE" "Lingkungan desktop. Menu Tweak tampilan hanya untuk GNOME/GTK."
  opt_add "CPU     : ${SYS_CPU:0:40}" "$SYS_CORES"
  opt_add "RAM     : $SYS_RAM GB" "$rt"
  opt_add "Disk    : $SYS_DISKFREE GB kosong / $SYS_DISKTOT GB" "Sisakan minimal 30GB untuk tool dev dan proyek."
  opt_add "KVM     : $SYS_KVM" "Dibutuhkan virt-manager, GNOME Boxes dan emulator Android. Kalau tidak aktif: masuk BIOS lalu aktifkan Intel VT-x / AMD SVM."
  opt_add "Disk    : $( [ "$SYS_SSD" = 1 ] && echo SSD || echo HDD)$( [ "$SYS_LAPTOP" = 1 ] && echo ' · laptop (baterai terdeteksi)')" "$( [ "$SYS_SSD" = 1 ] && echo 'SSD: cepat.' || echo 'HDD lambat untuk desktop modern: upgrade ke SSD adalah peningkatan paling terasa. Sementara itu aktifkan zram & earlyoom di Tune-Up.')"
  [ "$IMMUTABLE" = 1 ] && opt_add "Immutable: ya" "Sistem dasar read-only. Aplikasi GUI lewat Flatpak; tool CLI/compiler sebaiknya di dalam distrobox (distrobox create -i ubuntu:24.04 lalu jalankan TIPACK di dalamnya)."
  [ "$IS_TERMUX" = 1 ] && opt_add "Termux  : ya" "Linux di Android tanpa root. Hanya paket CLI yang tersedia; aplikasi GUI tidak didukung. Akses penyimpanan HP: termux-setup-storage."
  [ "$IS_WSL" = 1 ] && opt_add "WSL     : ya" "Berjalan di dalam WSL. Aplikasi GUI tampil lewat WSLg (Windows 11)."
  opt_add "Katalog : $(inst_count)/$NCAT aplikasi terpasang" "Lihat menu Cek Status untuk detailnya."
  select_list "Info Sistem" "" single 0 "kembali"
}

boot() {
  printf '%s' "$E[2J$E[H"; hide_cur
  show_banner
  local tag="      I F   ·   Installer Toolkit Mahasiswa Teknik Informatika & Abang IT   ·   v2.0 Linux"
  echo
  if [ $NOANIM = 1 ]; then printf '%s%s%s\n' "$DIM" "$tag" "$R0"; else
    printf '%s' "$DIM"; local j; for ((j=0;j<${#tag};j++)); do printf '%s' "${tag:$j:1}"; sleep 0.004; done; printf '%s\n' "$R0"; fi
  echo
  chk() { printf '  %s[ .... ]%s %s' "$DIM" "$R0" "$1"; [ $NOANIM = 0 ] && sleep 0.15
    if [ "$2" = 1 ]; then printf '\r  %s[  OK  ]%s %s\n' "$GRN" "$R0" "$1"; else printf '\r  %s[ WARN ]%s %s\n' "$YEL" "$R0" "$1"; fi; }
  get_sysinfo
  chk "Membaca informasi sistem" 1
  chk "Distro: $D_NAME" 1
  [ "$PM" != none ] && chk "Package manager: $PM_LABEL" 1 || chk "Package manager tidak dikenal (pakai Flatpak & script)" 0
  [ "$IMMUTABLE" = 1 ] && chk "Distro immutable: aplikasi lewat Flatpak; untuk tool CLI pakai distrobox" 0
  [ "$IS_CROS" = 1 ] && chk "ChromeOS (Crostini) terdeteksi" 1
  [ "$IS_RPI" = 1 ] && chk "Raspberry Pi terdeteksi ($SYS_ARCH)" 1
  chk "Koneksi internet" $SYS_NET
  [ "$IS_ROOT" = 1 ] && chk "Berjalan sebagai root (AUR & beberapa fitur dinonaktifkan)" 0
  if [ "$IS_TERMUX" = 0 ]; then command -v sudo >/dev/null 2>&1 || [ "$IS_ROOT" = 1 ] && chk "sudo tersedia" 1 || chk "sudo tidak ada: jalankan sebagai root atau pasang sudo" 0; fi
  [ $PM = pacman ] && { [ -n "$AUR_HELPER" ] && chk "AUR helper: $AUR_HELPER" 1 || chk "AUR helper belum ada (yay dipasang otomatis bila perlu)" 0; }
  echo
  printf '     %sLaptop : %s (%s)\n' "$CYN" "$SYS_MODEL" "$SYS_ARCH"
  printf '     Kernel : %s   Desktop: %s\n' "$SYS_KERNEL" "$SYS_DE"
  printf '     CPU    : %s (%s)\n' "$SYS_CPU" "$SYS_CORES"
  printf '     RAM    : %s GB      Disk: %s GB kosong dari %s GB\n' "$SYS_RAM" "$SYS_DISKFREE" "$SYS_DISKTOT"
  printf '     KVM    : %s%s\n\n' "$SYS_KVM" "$R0"
  [ $SYS_NET = 0 ] && printf '  %sTidak ada internet. Instalasi butuh koneksi, cek WiFi dulu ya.%s\n' "$YEL" "$R0"
  [ "${SYS_DISKFREE:-99}" -lt 15 ] && printf '  %sDisk tinggal %s GB. Paket besar bisa gagal.%s\n' "$YEL" "$SYS_DISKFREE" "$R0"
  resolve_methods
  local avail=0; for ((i=0;i<NCAT;i++)); do [ "${K_TYPE[$i]}" != none ] && avail=$((avail+1)); done
  spin "Memindai paket yang sudah terpasang..." true
  scan_installed
  printf '\r   %s✓ %s dari %s aplikasi tersedia untuk distro ini · %s sudah terpasang.%s%s\n' "$GRN" "$avail" "$NCAT" "$(inst_count)" "$R0" "$E[K"
  [ $NOANIM = 0 ] && sleep 0.9
}

main_menu() {
  local i
  while true; do
    HDR=()
    if [ "$(tput lines)" -ge 40 ]; then
      for ((i=0;i<6;i++)); do HDR+=("  ${BCOL[$i]}${BANNER[$i]}${R0}"); done
      HDR+=("      ${DIM}I F  ·  $USER@$D_NAME  ·  $PM  ·  RAM ${SYS_RAM}GB  ·  $(inst_count)/$NCAT app terpasang${R0}"); HDR+=("")
    fi
    local cc; cc=$(cart_count)
    opt_reset
    opt_add "🧙 Wizard Preferensi" "Jawab ${#WIZ[@]} pertanyaan singkat (browser, shell, editor, bahasa, container/VM, dst). Setiap pilihan ada penjelasan dan rekomendasinya. Aplikasi yang tidak tersedia di distro ini otomatis disembunyikan." wiz "${YEL}★ mulai di sini"
    opt_add "📦 Profil Siap Pakai" "Paket sekali klik: Starter Mahasiswa IF, Web, Mobile, Data/AI, Jaringan & Security, DevOps, Game, Desain, Linux Power User." prof
    opt_add "🗂  Pilih Manual per Kategori" "Jelajahi aplikasi per kategori lalu centang sendiri." cat
    opt_add "🔍 Cek Status Laptop" "Lihat semua aplikasi: mana yang sudah terpasang dan mana yang belum. Laporan disimpan ke laporan-status.txt." status "${GRN}$(inst_count)/$NCAT terpasang"
    opt_add "🛒 Keranjang & Install" "Tinjau daftar yang akan dipasang lalu mulai instalasi otomatis lewat $PM / Flatpak / script resmi." cart "$( [ "$cc" -gt 0 ] && printf '%s%s item siap' "$CYN" "$cc" || printf '%skosong' "$DIM")"
    opt_add "🧩 Ekstensi VS Code" "Pasang ekstensi VS Code penting: C/C++, Code Runner, Python, Java, ShellCheck, GitLens, dll." ext
    opt_add "🔑 Setup Git & SSH Key GitHub" "Atur nama/email Git, buat SSH key, copy ke clipboard, buka GitHub, gh auth login." git
    opt_add "⚙️  Tweak Linux untuk Developer" "Batas inotify untuk VS Code/Vite, grup dialout/docker/libvirt, dark mode, file tersembunyi." tweak
    opt_add "🚀 Tune-Up & Optimasi" "Bersihkan cache paket & paket yatim, Flatpak tak terpakai, batasi log journal, zram (RAM terkompresi), earlyoom anti-freeze, TRIM SSD, TLP baterai, matikan animasi. Cocok untuk laptop lama." tune "$( [ "${SYS_RAM:-8}" -le 8 ] && printf '%s★ disarankan untuk laptop ini' "$YEL")"
    opt_add "🧹 Debloat Linux" "Lepas Snap (Ubuntu), hapus telemetri Ubuntu, matikan layanan latar yang tidak dipakai (printer, bluetooth, modem, PackageKit)." debloat
    opt_add "🔄 Update Semua" "Upgrade semua paket $PM${AUR_HELPER:+ + AUR} + Flatpak." upd
    opt_add "💻 Info Sistem" "Distro, package manager, kernel, desktop, RAM, disk dan status KVM." sys
    opt_add "🚪 Keluar" "Sampai jumpa! Semangat ngodingnya." quit
    select_list "Menu Utama" "Selamat datang di $D_NAME! Pakai panah ↑↓ lalu Enter. Setiap menu punya penjelasan di kotak info bawah." single 0 "pilih"
    local v=quit; [ "$RES_OK" = 1 ] && v=$RES_VALUE
    HDR=()
    case $v in
      wiz) run_wizard ;; prof) pick_profile ;; cat) browse_category ;; status) show_all ;;
      cart) review_install ;; ext) setup_vscode_ext ;; git) setup_git ;; tweak) setup_tweaks ;;
      upd) update_all ;; sys) show_sysinfo ;; tune) tune_up ;; debloat) debloat ;;
      quit)
        if [ "$(cart_count)" -gt 0 ]; then printf '%s' "$E[2J$E[H"; echo; yesno "Keranjang masih berisi $(cart_count) item. Yakin keluar?" n || continue; fi
        printf '%s' "$E[2J$E[H"; printf '\n  %sTerima kasih sudah pakai DEVSETUP IF. Log: %s%s\n\n' "$MAG" "$LOG" "$R0"; return ;;
    esac
  done
}

# =====================================================================================
#  MAIN
# =====================================================================================
log "DEVSETUP IF Linux dimulai ($(uname -m), bash $BASH_VERSION, tes=$TEST_MODE)"
boot
if [ $SELFTEST = 1 ] && [ ${#KEYQ[@]} = 0 ]; then
  avail=0; for ((i=0;i<NCAT;i++)); do [ "${K_TYPE[$i]}" != none ] && avail=$((avail+1)); done
  echo "SELFTEST distro=$D_ID pm=$PM arch=$(uname -m) katalog=$NCAT tersedia=$avail terpasang=$(inst_count)"; exit 0
fi
if [ -n "$INSTALL_KEYS" ]; then
  want=""; bad=""
  for k in $(echo "$INSTALL_KEYS" | tr ',' ' '); do
    case "$k" in *[!a-z0-9]*) bad="$bad $k"; continue ;; esac
    i=$(ix "$k"); if [ -z "$i" ] || [ "${K_TYPE[$i]}" = none ]; then bad="$bad $k"; else want="$want $k"; fi
  done
  [ -n "$bad" ] && echo "Tidak dikenal / tidak tersedia di distro ini:$bad"
  sync_cart "$want" "$want"
  if [ "$(cart_count)" -gt 0 ]; then install_cart; else echo "Semua aplikasi yang diminta sudah terpasang."; fi
  [ "$INSTALL_FAIL" -gt 0 ] && exit 3; exit 0
fi
if [ -n "$PRESET" ]; then
  found=""; for p in "${PROFILES[@]}"; do [ "${p%%|*}" = "$PRESET" ] && found=${p##*|}; done
  [ -z "$found" ] && { echo "Preset '$PRESET' tidak dikenal."; exit 1; }
  sync_cart "$found" "$found"
  for ((i=0;i<NCAT;i++)); do [ "${K_TYPE[$i]}" = none ] && CART[$i]=0; done
  install_cart
  [ "$INSTALL_FAIL" -gt 0 ] && exit 3
else
  main_menu
fi
