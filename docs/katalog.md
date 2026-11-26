# Katalog Aplikasi

> File ini dibuat otomatis oleh `web/build-catalog.py` dari isi ketiga installer. Jangan diedit manual.

Total **188** aplikasi unik: Windows 128, macOS 113, Linux 105.

Legenda: ★ = rekomendasi · `—` = tidak tersedia di OS itu · `manual` = download manual (link dibuka di akhir instalasi).

Versi interaktif dengan pencarian: https://tipack.kousozo.tech/katalog

## Daftar isi

- [Browser](#browser)
- [Arsip & File](#arsip--file)
- [Terminal & Shell](#terminal--shell)
- [Editor Kode](#editor-kode)
- [IDE](#ide)
- [Bahasa & Runtime](#bahasa--runtime)
- [Web Server & Database](#web-server--database)
- [Git & API](#git--api)
- [DevOps & Cloud](#devops--cloud)
- [AI & Data](#ai--data)
- [Mobile & Game](#mobile--game)
- [Jaringan & Keamanan](#jaringan--keamanan)
- [Virtualisasi & Linux](#virtualisasi--linux)
- [Desain & Multimedia](#desain--multimedia)
- [Komunikasi](#komunikasi)
- [Kuliah & Produktivitas](#kuliah--produktivitas)
- [Utilitas Sistem](#utilitas-sistem)

## Browser

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **Google Chrome** | winget | brew cask | AUR · Flathub · script | Browser paling umum dengan DevTools terlengkap. Wajib untuk debugging web. Rekomendasi utama. |
| **Mozilla Firefox** | winget | brew cask | Flathub · apk · apt · dnf · pacman · zypper | Open source dan lebih menjaga privasi. DevTools untuk CSS Grid/Flexbox paling enak. Cocok jadi browser kedua untuk tes kompatibilitas. |
| **Firefox Developer Edition** | winget | brew cask | — | Firefox khusus developer dengan fitur DevTools eksperimental. |
| **Brave** | winget | brew cask | AUR · Flathub | Berbasis Chromium dengan adblock bawaan. Lebih hemat RAM dari Chrome, ekstensi Chrome tetap jalan. |
| **Opera GX** | winget | — | — | Browser "gaming" dengan pembatas RAM/CPU. Cocok untuk laptop RAM 8GB yang suka buka banyak tab. |
| **Arc** | — | brew cask | — | Browser dengan sidebar dan workspace, favorit banyak developer Mac. |
| **Chromium** | — | — | Flathub · apk · apt · dnf · pacman · zypper | Versi open source Chrome, tanpa layanan Google. |

## Arsip & File

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **7-Zip** | winget | — | — | Gratis dan open source. Bisa buka zip/rar/7z/iso/tar. Paling aman dan ringan. REKOMENDASI. |
| **WinRAR** | winget | — | — | Populer dan bisa MEMBUAT file .rar. Berbayar, tapi masa trialnya "abadi" (cuma muncul popup). Pilih kalau sering kirim file .rar. |
| **NanaZip** | winget | — | — | Fork 7-Zip dengan tampilan modern dan menu klik kanan Windows 11. Pilihan terbaik untuk Win11. |
| **PeaZip** | winget | — | — | Open source, mendukung 200+ format, ada enkripsi kuat dan secure delete. |
| ★ **Everything** | winget | — | — | Cari file di seluruh disk dalam hitungan milidetik. Wajib untuk yang file tugasnya berantakan. |
| ★ **The Unarchiver** | — | brew cask | — | Buka rar/7z/zip/iso dan lainnya. Gratis. Pengganti WinRAR di Mac. REKOMENDASI. |
| **Keka** | — | brew cask | — | Bisa MEMBUAT arsip 7z/zip dengan password, bukan cuma mengekstrak. |
| ★ **Raycast** | — | brew cask | — | Pengganti Spotlight super lengkap: launcher, clipboard history, window manager, snippet, kalkulator. |
| ★ **AppCleaner** | — | brew cask | — | Uninstall aplikasi Mac sampai bersih ke file sisa. |

## Terminal & Shell

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **Windows Terminal** | winget | — | — | Terminal modern bertab: PowerShell, CMD, WSL dan Git Bash dalam satu jendela. Sudah bawaan Windows 11. |
| ★ **PowerShell 7** | winget | — | — | Versi PowerShell terbaru. Lebih cepat dan cross-platform dibanding PowerShell 5 bawaan. |
| **Oh My Posh** | winget | — | — | Tema prompt keren: tampilkan branch git, versi bahasa, waktu eksekusi. Butuh Nerd Font. |
| **JetBrains Mono Nerd Font** | winget | brew cask | pacman · script | Font coding dengan ligature dan ikon, dipakai Oh My Posh dan terminal modern. |
| ★ **iTerm2** | — | brew cask | — | Terminal Mac paling populer: split pane, pencarian, profil. Lebih lengkap dari Terminal bawaan. |
| **Warp** | — | brew cask | — | Terminal modern dengan AI dan blok perintah ala IDE. |
| **Ghostty** | — | brew cask | — | Terminal super cepat berbasis GPU, minimalis. |
| ★ **Oh My Zsh + autosuggest + syntax highlight** | — | installer | script | Framework zsh dengan tema dan plugin, plus saran perintah otomatis dan pewarnaan perintah. |
| **Starship prompt** | — | brew | apk · pacman · termux · zypper | Prompt cantik yang menampilkan branch git dan versi bahasa. Butuh Nerd Font. |
| ★ **CLI Power Pack (wget, htop, jq, tldr, dll)** | — | brew | apk · apt · dnf · pacman · termux · zypper | Paket 11 tool terminal wajib: wget, tree, htop, btop, jq, tldr (contoh perintah), ripgrep, bat, eza, fzf, zoxide. |
| **Zsh** | — | — | apk · apt · dnf · pacman · termux · zypper | Shell yang lebih nyaman dari bash. Dibutuhkan Oh My Zsh. |
| **Fish shell** | — | — | apk · apt · dnf · pacman · termux · zypper | Shell ramah pemula dengan autosuggestion bawaan tanpa konfigurasi. |
| **tmux** | — | — | apk · apt · dnf · pacman · termux · zypper | Terminal multiplexer: split pane dan sesi yang tetap hidup walau SSH putus. |
| **Kitty terminal** | — | — | apk · apt · dnf · pacman · zypper | Terminal cepat berbasis GPU dengan tab dan split. |
| **Alacritty** | — | — | apk · apt · dnf · pacman · zypper | Terminal minimalis berbasis GPU, sangat ringan. |

## Editor Kode

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **Visual Studio Code** | winget | brew cask | AUR · Flathub · script | Editor paling populer: ringan dan ekstensinya melimpah. Standar mahasiswa IF. |
| **Cursor** | winget | brew cask | AUR | Fork VS Code dengan AI terintegrasi (chat, autocomplete multi-baris). Ada tier gratis. |
| **Google Antigravity** | manual | manual | manual | IDE agentic dari Google (berbasis VS Code). Download manual dari situs resminya. |
| **Zed** | winget | brew cask | Flathub · pacman | Editor super cepat (ditulis dengan Rust) dengan kolaborasi realtime. |
| **Sublime Text 4** | winget | brew cask | AUR · Flathub | Editor ringan dan sangat cepat. Cocok untuk laptop spek rendah. |
| ★ **Notepad++** | winget | — | — | Editor teks ringan untuk edit cepat file config/log. Pengganti Notepad. |
| **Neovim** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Editor di terminal untuk yang mau jadi "keyboard warrior". Kurva belajarnya tinggi. |
| **VSCodium** | — | — | AUR · Flathub | VS Code versi open source tanpa telemetri Microsoft. |

## IDE

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| **IntelliJ IDEA Community** | winget | brew cask | Flathub | IDE terbaik untuk Java/Kotlin. Wajib kalau ada matkul PBO. Mahasiswa bisa dapat Ultimate gratis lewat JetBrains Student Pack. |
| **PyCharm Community** | winget | brew cask | Flathub | IDE khusus Python dengan debugger dan pengelola virtualenv yang nyaman. |
| **JetBrains Toolbox** | winget | brew cask | AUR | Satu aplikasi untuk install/update semua IDE JetBrains. Rekomendasi kalau punya lisensi Student. |
| **Visual Studio 2022 Community** | winget | — | — | IDE berat (8GB+) untuk C#, .NET, C++ Windows dan Unity. Pilih kalau ada matkul C#/.NET. |
| **Apache NetBeans** | winget | brew cask | Flathub · pacman | IDE Java yang masih sering dipakai dosen untuk Java Swing/GUI. |
| **Code::Blocks** | winget | — | Flathub · apt · dnf · pacman | IDE C/C++ klasik, sering dipakai di praktikum Algoritma semester 1. |
| **Embarcadero Dev-C++** | winget | — | — | IDE C++ sederhana yang sering dipakai di praktikum Dasar Pemrograman. |
| **Xcode (App Store)** | — | manual | — | Wajib untuk develop aplikasi iOS/macOS dan Flutter iOS. Ukuran 10GB+, install dari App Store. |

## Bahasa & Runtime

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **WinLibs MinGW-w64 (GCC/G++)** | winget | — | — | Compiler C/C++ (gcc, g++, gdb). Wajib untuk Algoritma dan Struktur Data. |
| **MSYS2** | winget | — | — | Lingkungan mirip Unix + pacman untuk toolchain GCC/Clang. Alternatif MinGW yang lebih fleksibel. |
| **CMake** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Build system untuk proyek C/C++ besar. |
| ★ **Python 3.12** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Bahasa wajib untuk algoritma, data science, AI dan scripting. PATH diatur otomatis. |
| **uv (Python package manager)** | winget | brew | apk · dnf · pacman · termux | Pengganti pip + venv yang 10-100x lebih cepat. Modern, cocok untuk proyek baru. |
| **Miniconda** | winget | brew cask | — | Manajer environment Python untuk data science/ML. Lebih ringan dari Anaconda full. |
| ★ **Node.js LTS** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Runtime JavaScript + npm. Wajib untuk web dev (React, Vue, Express). JANGAN dipasang bareng NVM. |
| **NVM for Windows** | winget | — | — | Untuk gonta-ganti versi Node.js. Pilih ini ATAU Node.js LTS, jangan dua-duanya. |
| **Bun** | winget | brew | script resmi | Runtime JS super cepat sekaligus package manager. Alternatif modern npm. |
| ★ **Java JDK 21 (Temurin)** | winget | brew cask | apk · apt · dnf · pacman · termux · zypper | JDK LTS gratis. Wajib untuk PBO/Java dan Android. |
| **Java JDK 17 (Temurin)** | winget | brew cask | apk · apt · pacman · zypper | Versi LTS lama, kadang diminta dosen atau proyek lama. |
| **Go** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Bahasa backend modern: cepat dan simpel. Banyak dipakai startup. |
| **Rust (rustup)** | winget | brew | pacman · termux | Bahasa sistem yang aman memori. Butuh Visual C++ Build Tools. |
| **PHP 8.3 (standalone)** | winget | brew | apk · apt · dnf · pacman · termux · zypper | PHP CLI tanpa XAMPP. Tidak perlu kalau sudah pakai XAMPP/Laragon. |
| **Composer** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Package manager PHP, wajib untuk Laravel. |
| **.NET SDK 8** | winget | brew cask | apk · apt · dnf · pacman | Untuk C#, ASP.NET dan Blazor. |
| **R** | winget | brew cask | apk · apt · dnf · pacman · zypper | Bahasa statistik, sering dipakai di matkul Statistika/Data Mining. |
| ★ **GCC (g++ asli GNU)** | — | brew | — | Di Mac, perintah g++ sebenarnya clang. GCC asli dibutuhkan kalau dosen memakai bits/stdc++.h. Panggil dengan g++-15. |
| **fnm (Node version manager)** | — | brew | pacman | Untuk gonta-ganti versi Node.js. Pilih ini ATAU Node.js LTS. |
| **CocoaPods** | — | brew | — | Dependency manager iOS, dibutuhkan Flutter untuk build iOS. |
| ★ **Build tools C/C++ (gcc, g++, make, gdb)** | — | — | apk · apt · dnf · pacman · termux · zypper | Compiler C/C++ dan debugger. Wajib untuk Algoritma dan Struktur Data. |
| **Clang + LLVM** | — | — | apk · apt · dnf · pacman · termux · zypper | Compiler C/C++ alternatif dengan pesan error lebih jelas, plus clangd untuk editor. |

## Web Server & Database

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **XAMPP 8.2** | winget | manual | manual | Apache + MariaDB + PHP + phpMyAdmin dalam satu paket. Standar praktikum Pemrograman Web. |
| **Laragon** | winget | — | — | Alternatif XAMPP yang lebih ringan dan cepat, dengan virtual host otomatis (proyek.test). Favorit anak Laravel. |
| **MySQL Server** | winget | brew | — | MySQL resmi versi standalone. Jangan dipasang bareng XAMPP karena bentrok port 3306. |
| **PostgreSQL 16** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Database relasional open source paling canggih, banyak dipakai industri. |
| **MongoDB Community Server** | winget | — | — | Database NoSQL berbasis dokumen, populer di stack MERN. |
| **SQLite CLI** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Database satu file, cocok untuk aplikasi kecil dan mobile. |
| ★ **DBeaver Community** | winget | brew cask | Flathub · pacman | Satu aplikasi untuk SEMUA database (MySQL, Postgres, SQLite, Oracle...). Bisa bikin ERD otomatis. |
| **HeidiSQL** | winget | — | — | Client MySQL/MariaDB yang super ringan. |
| **MySQL Workbench** | winget | brew cask | AUR | Tool resmi MySQL. Kuat untuk desain ERD dan forward engineering. |
| **MongoDB Compass** | winget | brew cask | — | GUI untuk MongoDB. |
| **TablePlus** | winget | brew cask | — | Client database dengan UI paling cantik. Versi gratis dibatasi 2 tab. |
| **Laravel Herd** | — | brew cask | — | Server PHP/Laravel paling mudah di Mac: PHP, nginx dan domain .test otomatis. Favorit anak Laravel. |
| **MAMP** | — | brew cask | — | Apache + MySQL + PHP, mirip XAMPP versi Mac. Cocok untuk praktikum Pemrograman Web. |
| ★ **DBngin** | — | brew cask | — | Jalankan MySQL/PostgreSQL/Redis dengan satu klik, bisa banyak versi. Paling praktis di Mac. |
| **Sequel Ace** | — | brew cask | — | Client MySQL/MariaDB gratis, native dan ringan. |
| **Apache + PHP (LAMP)** | — | — | apk · apt · dnf · pacman · zypper | Web server Apache dengan PHP, setara XAMPP versi native. Folder web: /var/www/html. |
| ★ **MariaDB (MySQL)** | — | — | apk · apt · dnf · pacman · termux · zypper | Database MySQL-compatible. Setelah install: sudo systemctl enable --now mariadb. |
| **Redis / Valkey** | — | — | apk · apt · dnf · pacman · termux · zypper | Database key-value di memori untuk cache dan antrean. |

## Git & API

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **Git** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Version control wajib, sudah termasuk Git Bash. |
| ★ **GitHub Desktop** | winget | brew cask | AUR · Flathub | Git versi GUI, cocok untuk pemula sebelum lancar command line. |
| ★ **GitHub CLI (gh)** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Login GitHub, clone, bikin repo dan PR langsung dari terminal. 'gh auth login' cara autentikasi paling mudah. |
| **lazygit** | winget | brew | apk · pacman · termux · zypper | UI Git di terminal. Cepat untuk staging, commit dan rebase. |
| ★ **Postman** | winget | brew cask | AUR · Flathub | Tes REST API. Standar industri untuk matkul Web Service/Backend. |
| **Bruno** | winget | brew cask | AUR · Flathub | Alternatif Postman yang open source dan offline. Koleksinya disimpan sebagai file sehingga bisa masuk git. |

## DevOps & Cloud

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| **Docker Desktop** | winget | brew cask | apk · pacman · script · zypper | Container untuk menjalankan database/app tanpa install manual. Butuh WSL2 dan RAM 8GB+. |
| **kubectl** | winget | brew | apk · pacman · termux · zypper | CLI untuk Kubernetes. |
| **Terraform** | winget | brew | — | Infrastructure as Code. |
| **AWS CLI** | winget | brew | — | CLI Amazon Web Services. Mahasiswa bisa ikut AWS Academy. |
| **Google Cloud SDK** | winget | brew cask | — | CLI Google Cloud. |
| **Azure CLI** | winget | brew | — | CLI Microsoft Azure. Mahasiswa dapat kredit gratis lewat Azure for Students. |
| **ngrok** | winget | brew cask | AUR | Membuat localhost bisa diakses publik. Berguna untuk demo ke dosen atau tes webhook. |
| ★ **OrbStack** | — | brew cask | — | Docker + Linux VM untuk Mac. Jauh lebih ringan dan cepat dari Docker Desktop. Juga bisa jadi pengganti WSL di Mac. |
| **Podman** | — | — | apk · apt · dnf · pacman · zypper | Alternatif Docker tanpa daemon dan tanpa root. Bawaan Fedora. |
| **Distrobox** | — | — | apk · apt · dnf · pacman · zypper | Jalankan distro lain (Ubuntu di Arch, Arch di Fedora, dll) dalam container terintegrasi. |

## AI & Data

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| **Ollama** | winget | brew cask | pacman · termux | Jalankan LLM (Llama, Gemma, Qwen) secara lokal dan offline. Nyaman di RAM 16GB. |
| **LM Studio** | winget | brew cask | — | GUI untuk download dan chat dengan LLM lokal. |
| **Claude Desktop** | winget | brew cask | — | Aplikasi desktop Claude. |
| **RStudio** | winget | brew cask | — | IDE untuk R (R harus terinstall). |
| **JupyterLab** | — | — | apt · pacman | Notebook untuk data science (alternatif: pip install jupyterlab di venv). |

## Mobile & Game

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| **Android Studio** | winget | brew cask | AUR · Flathub | IDE resmi Android + emulator. Berat: RAM minimal 8GB, nyaman 16GB. |
| **Flutter SDK** | manual | brew cask | AUR | Framework mobile cross-platform. Install manual, atau lewat ekstensi VS Code "Flutter" yang bisa download SDK otomatis. |
| **Windows Subsystem for Android (WSA)** | manual | — | — | SUDAH DIHENTIKAN Microsoft sejak 5 Maret 2025 dan tidak bisa diinstall lagi. Alternatif: Android Studio Emulator, BlueStacks, atau Google Play Games. |
| **BlueStacks** | winget | — | — | Emulator Android untuk menjalankan APK di Windows. Pengganti WSA. |
| **Unity Hub** | winget | brew cask | AUR | Engine game 2D/3D paling populer, pakai C#. |
| **Godot Engine** | winget | brew cask | Flathub · dnf · pacman · zypper | Engine game open source, ringan, cocok untuk pemula. |
| **Blender** | winget | brew cask | Flathub · pacman | Modeling dan animasi 3D gratis. |
| **Arduino IDE** | winget | brew cask | AUR · Flathub | Untuk matkul IoT/Sistem Embedded. |

## Jaringan & Keamanan

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| **Cisco Packet Tracer** | manual | manual | AUR | Simulasi jaringan Cisco untuk matkul Jaringan Komputer. Download manual (butuh akun NetAcad gratis). |
| **Wireshark** | winget | brew cask | apk · apt · dnf · pacman · zypper | Analisis paket jaringan. Wajib untuk matkul Jarkom/Keamanan. |
| **Nmap** | winget | brew | apk · apt · dnf · pacman · termux · zypper | Port scanner. Pakai hanya di jaringan milik sendiri atau yang sudah diizinkan. |
| **PuTTY** | winget | — | — | Klien SSH/Telnet/Serial klasik. Windows sudah punya ssh bawaan. |
| **MobaXterm** | winget | — | — | Terminal SSH all-in-one dengan SFTP browser dan X11. Favorit abang server. |
| **WinSCP** | winget | — | — | Transfer file ke server lewat SFTP/SCP dengan GUI. |
| **FileZilla** | winget | — | Flathub · apk · apt · dnf · pacman · zypper | Klien FTP/SFTP untuk upload ke hosting. |
| **Advanced IP Scanner** | winget | — | — | Scan perangkat di jaringan lokal dan cek IP yang terpakai. |
| **Burp Suite Community** | winget | brew cask | AUR | Proxy untuk pentest aplikasi web. Gunakan secara etis. |
| **WireGuard** | winget | — | apk · apt · dnf · pacman · termux · zypper | VPN modern yang cepat. |
| **Termius** | — | brew cask | — | Klien SSH cantik dengan SFTP. Gratis untuk mahasiswa (GitHub Student Pack). |
| **Cyberduck** | — | brew cask | — | Klien FTP/SFTP/S3 untuk upload ke server. |
| **Network tools (dig, traceroute, whois, iperf3)** | — | — | apk · apt · dnf · pacman · termux · zypper | Perkakas diagnosa jaringan untuk praktikum Jarkom. |
| **OpenSSH server** | — | — | apk · apt · dnf · pacman · termux · zypper | Supaya laptop bisa diakses lewat SSH (praktikum server). |
| **Remmina (RDP/VNC/SSH)** | — | — | Flathub · apk · apt · dnf · pacman · zypper | Remote desktop ke Windows (RDP), VNC dan SSH. |

## Virtualisasi & Linux

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **WSL2 (Windows Subsystem for Linux)** | WSL | — | — | Linux asli di Windows tanpa dual boot. Dibutuhkan Docker dan banyak tool dev. Virtualisasi di BIOS harus aktif, lalu restart. |
| ★ **Ubuntu (WSL)** | WSL | — | — | Distro paling populer dan paling banyak tutorialnya. Rekomendasi untuk pemula. |
| **Debian (WSL)** | WSL | — | — | Distro yang stabil dan ringan. |
| **Kali Linux (WSL)** | WSL | — | — | Distro untuk belajar keamanan siber/pentest. |
| **Windows Sandbox** | fitur Windows | — | — | Windows "sekali pakai" untuk tes aplikasi mencurigakan. Hanya Windows Pro/Education. |
| **VirtualBox** | winget | — | apt · pacman · zypper | Mesin virtual gratis untuk install Linux/Windows lain (matkul Sistem Operasi). |
| ★ **UTM** | — | brew cask | — | Mesin virtual gratis untuk Mac (Apple Silicon & Intel). Install Ubuntu/Kali/Windows ARM. |
| **Multipass** | — | brew cask | — | VM Ubuntu instan dari terminal (multipass launch). Cocok untuk matkul SO/Server. |
| ★ **virt-manager + QEMU/KVM** | — | — | apt · dnf · pacman · zypper | Mesin virtual native Linux (paling cepat, pakai KVM). Untuk matkul Sistem Operasi. |
| **GNOME Boxes** | — | — | Flathub · apt · dnf · pacman · zypper | VM paling mudah: pilih ISO, klik, jadi. |

## Desain & Multimedia

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **Figma** | winget | brew cask | AUR · Flathub | Desain UI/UX dan prototipe. Ada Figma Education gratis. |
| ★ **draw.io Desktop** | winget | brew cask | AUR · Flathub | Flowchart, UML, ERD dan DFD secara offline. Wajib untuk matkul RPL/Analisis Sistem. |
| **GIMP** | winget | brew cask | Flathub · apk · apt · dnf · pacman · zypper | Edit foto gratis, alternatif Photoshop. |
| **Inkscape** | winget | brew cask | Flathub · apk · apt · dnf · pacman · zypper | Desain vektor gratis, alternatif Illustrator. |
| **OBS Studio** | winget | brew cask | Flathub · apt · dnf · pacman · zypper | Rekam layar/presentasi dan live streaming. Berguna untuk video demo tugas. |
| ★ **ShareX** | winget | — | — | Screenshot, rekam layar, GIF dan OCR. Jauh lebih lengkap dari Snipping Tool. |
| ★ **VLC Media Player** | winget | — | Flathub · apk · apt · pacman · zypper | Pemutar semua format video. |
| ★ **IINA** | — | brew cask | — | Video player modern untuk Mac, semua format. |
| ★ **Flameshot** | — | — | Flathub · apk · apt · dnf · pacman · zypper | Screenshot dengan anotasi (panah, kotak, blur). Pengganti Snipping Tool. |

## Komunikasi

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **Discord** | winget | brew cask | Flathub · pacman | Grup kelas, komunitas programmer, voice call kerja kelompok. |
| ★ **Zoom** | winget | brew cask | AUR · Flathub | Kuliah online dan sidang. |
| **Telegram** | winget | brew cask | Flathub · pacman | Banyak grup/komunitas IT dan bot. |
| **Slack** | winget | brew cask | AUR · Flathub | Komunikasi tim ala industri, sering dipakai saat magang. |
| **Microsoft Teams** | winget | brew cask | — | Dipakai beberapa kampus untuk kelas online. |
| **WhatsApp** | — | brew cask | — | Grup kelas dan koordinasi tugas. |

## Kuliah & Produktivitas

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| **Notion** | winget | brew cask | AUR | Catatan, task manager dan wiki. Ada plan Education gratis. |
| **Obsidian** | winget | brew cask | Flathub · pacman | Catatan Markdown offline dengan graph view. Cocok jadi second brain. |
| **Zotero** | winget | brew cask | AUR · Flathub | Manajer referensi dan sitasi otomatis untuk skripsi/jurnal. |
| **Microsoft 365 (email kampus)** | manual | manual | manual | Biasanya GRATIS pakai email kampus. Login di office.com lalu klik Install Apps. |
| ★ **LibreOffice** | winget | brew cask | Flathub · apk · apt · dnf · pacman · zypper | Office gratis. Tidak perlu kalau sudah punya Microsoft 365 dari kampus. |
| ★ **SumatraPDF** | winget | — | — | Pembaca PDF super ringan, modul kuliah terbuka instan. |
| **Adobe Acrobat Reader** | winget | — | — | Pembaca PDF standar dengan fitur tanda tangan dan form. |
| **Google Drive** | winget | brew cask | — | Sinkronisasi file tugas ke cloud secara otomatis. |
| **Okular (PDF)** | — | — | Flathub · apk · apt · dnf · pacman · zypper | Pembaca PDF lengkap dengan anotasi dan tanda tangan. |

## Utilitas Sistem

| Aplikasi | Windows | macOS | Linux | Keterangan |
|---|---|---|---|---|
| ★ **Microsoft PowerToys** | winget | — | — | Kumpulan tool: PowerToys Run (launcher), FancyZones, Color Picker, Text Extractor (OCR). |
| ★ **Visual C++ Redistributable** | winget | — | — | Library runtime yang dibutuhkan banyak aplikasi dan game. Install saja. |
| ★ **LocalSend** | winget | brew cask | AUR · Flathub | Kirim file HP ke laptop lewat WiFi tanpa kabel/internet, mirip AirDrop. |
| **Revo Uninstaller** | winget | — | — | Uninstall aplikasi sampai bersih ke sisa registri. |
| **CPU-Z** | winget | — | — | Lihat detail CPU, RAM dan motherboard. |
| **HWiNFO** | winget | — | — | Monitor suhu dan sensor hardware secara lengkap. |
| **CrystalDiskInfo** | winget | — | — | Cek kesehatan SSD/HDD. |
| **Rufus** | winget | — | — | Bikin flashdisk bootable untuk install Windows/Linux. |
| **Ventoy** | winget | — | AUR | Satu flashdisk untuk banyak ISO sekaligus. Wajib untuk abang IT. |
| **AnyDesk** | winget | — | — | Remote desktop untuk bantu teman dari jauh. |
| **RustDesk** | winget | — | — | Remote desktop open source, alternatif AnyDesk. |
| ★ **Rectangle** | — | brew cask | — | Atur jendela kiri/kanan dengan shortcut, seperti Snap di Windows. WAJIB. |
| **AltTab** | — | brew cask | — | Alt-Tab ala Windows dengan preview jendela. |
| ★ **Stats** | — | brew cask | — | Monitor CPU, RAM, suhu dan jaringan di menu bar. |
| **Maccy** | — | brew cask | — | Riwayat clipboard (copy-paste) yang ringan. |
| **Hidden Bar** | — | brew cask | — | Sembunyikan ikon menu bar yang terlalu ramai. |
| **MonitorControl** | — | brew cask | — | Atur brightness/volume monitor eksternal dari keyboard. |
| ★ **Flatpak + Flathub** | — | — | apk · apt · dnf · pacman · zypper | Toko aplikasi universal Linux. Dipasang otomatis kalau ada aplikasi yang butuh. |
| **fastfetch** | — | — | apk · apt · dnf · pacman · termux · zypper | Tampilkan info sistem + logo distro di terminal (pengganti neofetch). Wajib buat pamer. |
| ★ **Timeshift (backup sistem)** | — | — | apt · dnf · pacman | Snapshot sistem: kalau update bikin rusak, tinggal restore. WAJIB untuk pemula Linux. |
| **GParted** | — | — | apk · apt · dnf · pacman · zypper | Atur partisi disk. |
| **CopyQ (riwayat clipboard)** | — | — | Flathub · apt · dnf · pacman | Riwayat copy-paste yang bisa dicari. |
| **GNOME Tweaks + Extension Manager** | — | — | Flathub · apt · dnf · pacman · zypper | Kustomisasi tampilan GNOME (font, tema, ekstensi). Hanya untuk desktop GNOME. |

## Profil

| Preset | Nama | Isi |
|---|---|---|
| `starter` | Starter Pack Mahasiswa IF (Semester 1-2) | Google Chrome, 7-Zip, Everything, Windows Terminal, PowerShell 7, Visual Studio Code, Notepad++, WinLibs MinGW-w64 (GCC/G++), Python 3.12, Node.js LTS, Java JDK 21 (Temurin), XAMPP 8.2, DBeaver Community, Git, GitHub Desktop, GitHub CLI (gh), Postman, WSL2 (Windows Subsystem for Linux), Ubuntu (WSL), Figma, draw.io Desktop, ShareX, VLC Media Player, Discord, Zoom, LibreOffice, SumatraPDF, Microsoft PowerToys, Visual C++ Redistributable, LocalSend, The Unarchiver, Raycast, AppCleaner, iTerm2, Oh My Zsh + autosuggest + syntax highlight, CLI Power Pack (wget, htop, jq, tldr, dll), GCC (g++ asli GNU), DBngin, IINA, Rectangle, Stats, Build tools C/C++ (gcc, g++, make, gdb), MariaDB (MySQL), Flameshot, Flatpak + Flathub, Timeshift (backup sistem) |
| `cpp` | C/C++ & Algoritma | Visual Studio Code, Code::Blocks, Embarcadero Dev-C++, WinLibs MinGW-w64 (GCC/G++), CMake, Git, GCC (g++ asli GNU), Build tools C/C++ (gcc, g++, make, gdb), Clang + LLVM |
| `java` | Java & PBO | Visual Studio Code, IntelliJ IDEA Community, Apache NetBeans, Java JDK 21 (Temurin), Git |
| `web` | Web Developer (Fullstack) | Google Chrome, Mozilla Firefox, Firefox Developer Edition, Visual Studio Code, Node.js LTS, Bun, PHP 8.3 (standalone), Composer, Laragon, PostgreSQL 16, DBeaver Community, TablePlus, Git, GitHub CLI (gh), Postman, Docker Desktop, ngrok, WSL2 (Windows Subsystem for Linux), Ubuntu (WSL), Figma, fnm (Node version manager), Laravel Herd, DBngin, OrbStack, Apache + PHP (LAMP), MariaDB (MySQL), Redis / Valkey |
| `mobile` | Mobile Developer (Android/Flutter) | Visual Studio Code, Java JDK 21 (Temurin), Git, GitHub CLI (gh), Postman, Android Studio, Flutter SDK, BlueStacks, Figma, Xcode (App Store), CocoaPods |
| `data` | Data Science & AI | Visual Studio Code, Python 3.12, uv (Python package manager), Miniconda, R, PostgreSQL 16, DBeaver Community, Git, Ollama, LM Studio, RStudio, WSL2 (Windows Subsystem for Linux), Ubuntu (WSL), JupyterLab |
| `net` | Jaringan & Keamanan Siber | Cisco Packet Tracer, Wireshark, Nmap, PuTTY, MobaXterm, WinSCP, FileZilla, Advanced IP Scanner, Burp Suite Community, WireGuard, WSL2 (Windows Subsystem for Linux), Kali Linux (WSL), VirtualBox, Termius, Cyberduck, UTM, Network tools (dig, traceroute, whois, iperf3), OpenSSH server, Remmina (RDP/VNC/SSH), virt-manager + QEMU/KVM |
| `devops` | DevOps & Cloud | Visual Studio Code, Git, GitHub CLI (gh), lazygit, Docker Desktop, kubectl, Terraform, AWS CLI, Google Cloud SDK, Azure CLI, MobaXterm, WSL2 (Windows Subsystem for Linux), Ubuntu (WSL), OrbStack, Multipass, tmux, Podman, Distrobox, virt-manager + QEMU/KVM |
| `game` | Game Developer | Visual Studio Code, Visual Studio 2022 Community, Git, Unity Hub, Godot Engine, Blender, GIMP, Inkscape, OBS Studio |
| `design` | UI/UX & Konten Kreator | Blender, Figma, draw.io Desktop, GIMP, Inkscape, OBS Studio, ShareX, VLC Media Player, IINA, Flameshot |
| `tech` | Abang IT / Teknisi Laptop | 7-Zip, Everything, Advanced IP Scanner, VLC Media Player, SumatraPDF, Microsoft PowerToys, Visual C++ Redistributable, LocalSend, Revo Uninstaller, CPU-Z, HWiNFO, CrystalDiskInfo, Rufus, Ventoy, AnyDesk, RustDesk, The Unarchiver, Keka, Raycast, AppCleaner, CLI Power Pack (wget, htop, jq, tldr, dll), Rectangle, AltTab, Stats, Maccy, Hidden Bar, MonitorControl, tmux, OpenSSH server, Remmina (RDP/VNC/SSH), Flatpak + Flathub, fastfetch, Timeshift (backup sistem), GParted, CopyQ (riwayat clipboard), GNOME Tweaks + Extension Manager |
