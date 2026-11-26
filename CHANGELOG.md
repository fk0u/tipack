# Changelog

Semua perubahan penting di TIPACK dicatat di sini. Format mengikuti [Keep a Changelog](https://keepachangelog.com/id-ID/1.1.0/) dan versi mengikuti [Semantic Versioning](https://semver.org/lang/id/).

Riwayat lengkap beserta keputusan dan akar masalah setiap perbaikan ada di [docs/notulensi.md](docs/notulensi.md).

## [2.1.0] - 2026-11-26

### Ditambahkan
- **Aplikasi GUI** (Tauri 2): pasang aplikasi dengan progres langsung, profil, konfigurasi `tipack.json`, Doctor dan laporan masalah.
  - Installer `.msi`/`.exe` (x64 & ARM64), `.dmg` universal, serta `.deb`/`.rpm`/AppImage (x64 & ARM64), dibangun otomatis di GitHub Actions.
  - Penandatanganan Windows lewat **SignPath** (aktif setelah variabel repo diisi).
- **Katalog umum ala Ninite 2026**: 245 aplikasi unik (Windows 186, macOS 153, Linux 142).
  - Kategori baru: Media & Hiburan, Keamanan & Privasi, Cloud, Gaming, Download, Runtime.
  - Aplikasi baru antara lain Zen Browser, WhatsApp, Spotify, CapCut, DaVinci Resolve, WPS Office, Bitwarden, Proton VPN, Cloudflare WARP, Steam, Epic, Heroic, ChatGPT, qBittorrent, IDM dan WizTree.
  - Profil baru `umum`, `gamer` dan `kreator`.
- Dukungan **Microsoft Store** (`msstore:`) di mesin Windows.
- **Doctor** (auto-fix) dan **Laporkan masalah** (log disensor → form GitHub Issue) di ketiga OS.
- `--config` / `-Config` (`tipack.json`, file atau URL), `--json` (event untuk GUI), `--scan-json`, `--doctor`, `--doctor-fix`, `--report`.
- **Website baru**: logo TIPACK, ikon brand asli (Simple Icons, CC0), pemilih aplikasi ala Ninite (perintah satu baris, link bagikan, `tipack.json`), bento fitur, matriks platform, FAQ.
- Bootstrap Windows menerima `TIPACK_APPS` / `TIPACK_CONFIG`.
- Template issue GitHub (laporan masalah, usul aplikasi).
- CI: validasi semua ID Homebrew dan Flathub, ditambah winget.

### Diperbaiki
- ID Homebrew: `tldr` → `tlrc`; Azure CLI dan DaVinci Resolve di macOS menjadi unduhan manual.
- Key wizard Windows yang menunjuk aplikasi khusus macOS/Linux.

## [2.0.0] - 2026-11-26

Rilis publik pertama.

### Ditambahkan

**Installer**
- Installer interaktif berbasis terminal (TUI) untuk **Windows** (PowerShell 5.1/7 + winget), **macOS** (bash 3.2 + Homebrew) dan **Linux** (apt, dnf, pacman + AUR, zypper, apk, dengan Flatpak sebagai cadangan).
- **Katalog 188 aplikasi unik** dalam 17 kategori: Windows 128, macOS 113, Linux 105. Setiap aplikasi punya tooltip penjelasan, label rekomendasi dan status terpasang.
- **Wizard preferensi**: 20 pertanyaan (Windows), 19 (macOS), 16 (Linux). Termasuk WinRAR vs 7-Zip, WSL, pengganti WSA (dihentikan Microsoft 5 Maret 2025), editor, IDE, bahasa, web server, database dan container/VM.
- **11 profil siap pakai**: `starter`, `cpp`, `java`, `web`, `mobile`, `data`, `net`, `devops`, `game`, `design`, `tech`.
- **Deteksi otomatis aplikasi terpasang** lewat `winget export`, `brew list`, database paket distro, `flatpak list`, perintah di PATH dan folder instalasi.
- **Keranjang** dengan peringatan konflik (Node vs NVM/fnm, XAMPP vs MySQL, Docker vs OrbStack) dan peringatan paket berat untuk RAM kecil.
- **Instalasi** dengan progress bar, spinner + timer per aplikasi, ringkasan, log lengkap dan link untuk aplikasi yang harus diinstall manual.
- **Ekstensi VS Code**: pemilih 24–30 ekstensi dengan tooltip.
- **Setup Git & SSH key** ke GitHub: identitas, ed25519, salin ke clipboard, `gh auth login`.
- **Tweak OS untuk developer** di ketiga OS.
- **Update semua** aplikasi lewat package manager.

**Laptop lama**
- **Tune-Up & optimasi** di ketiga OS:
  - Bersihkan file sampah dan cache; ukurannya ditampilkan sebelum dihapus, dan ruang yang dibebaskan dihitung.
  - Windows: efek visual performa, power plan, hibernasi, TRIM/defrag, SFC + DISM.
  - macOS: snapshot Time Machine, cache Xcode, animasi lebih cepat.
  - Linux: **zram**, **earlyoom**, swappiness, TRIM, TLP, batas journal.
- **Kelola startup** (Windows), memakai kunci `StartupApproved` yang sama dengan Task Manager.
- **Debloat**:
  - Windows: aplikasi bawaan/promo, iklan Start, Copilot, Recall, Widgets, telemetri, Bing, OneDrive, menu klik kanan klasik, dengan restore point otomatis.
  - macOS: GarageBand/iMovie/iWork dipindah ke Trash, iklan personal, Siri.
  - Linux: lepas Snap di Ubuntu, telemetri Ubuntu, layanan yang tidak dipakai.

**Platform & arsitektur**
- Windows x64, **ARM64** (LLVM-MinGW menggantikan MinGW; VirtualBox/BlueStacks disembunyikan) dan x86 (katalog terbatas).
- macOS Apple Silicon & Intel.
- Linux x64 & **ARM64** (Raspberry Pi, laptop ARM), **paket alternatif** `a/b/c` (misalnya JDK 21/25/17 sesuai distro).
- **Distro immutable** (Fedora Silverblue/Kinoite, Bazzite, Bluefin, SteamOS, NixOS): Flatpak + script di home, dengan saran memakai distrobox.
- ChromeOS (Crostini) dan WSL terdeteksi otomatis.
- **Android**: disarankan lewat **Andronix**. Linux di dalam proot terdeteksi otomatis; Termux murni didukung dengan katalog CLI terbatas.

**Mode tanpa menu & pengujian**
- `-Install a,b,c` / `--install a,b,c` (exit code 3 kalau ada yang gagal), `-Preset` / `--preset`, `-SelfTest` / `--self-test`, `-NoAnim` / `--no-anim`.
- Antrean tombol `TIPACK_KEYS` untuk mengendalikan TUI tanpa keyboard.
- **GitHub Actions**: 15 job untuk Windows x64/ARM64, macOS arm64/Intel, Ubuntu/Debian/Fedora/Arch/openSUSE/Alpine x64, Ubuntu/Fedora/Debian ARM64, Termux, dan cek sinkronisasi katalog.

**Website [tipack.kousozo.tech](https://tipack.kousozo.tech)**
- Landing page dengan deteksi OS, perintah satu baris (`irm … | iex` dan `curl … | bash`), dan bootstrap yang memilih macOS/Linux otomatis.
- **Katalog interaktif** `/katalog`: pencarian, filter OS/kategori/profil/rekomendasi, serta detail perintah install per OS dan per distro.
- **Sistem optimisasi animasi** (`perf.js`):
  - Animasi berhenti di luar layar dan saat tab tidak aktif.
  - Mode lite otomatis berdasarkan perangkat dan probe FPS.
  - Tombol Auto/Lite/Full.

**Dokumentasi**
- README, `docs/` (instalasi, penggunaan, Linux, katalog otomatis, troubleshooting, keamanan, arsitektur, website, notulensi), `CONTRIBUTING.md`, lisensi MIT.

### Diperbaiki (selama pengembangan menuju 2.0.0)
- **Windows stuck/error sejak awal**: `$C` (tabel katalog) dan `$c` (variabel loop) adalah variabel yang sama karena PowerShell tidak membedakan huruf besar-kecil. Diganti menjadi `$Apps`. Masalah serupa `$T`/`$t` di Tune-Up juga diperbaiki.
- **Windows menunggu input tersembunyi**: `winget source update` dan stub `wsl.exe` kini tidak dipanggil tanpa batas. Semua program luar memakai stdin kosong + timeout, dan WSL dideteksi lewat registry.
- `Clear-Host` gagal di PowerShell 7 tanpa jendela konsol. Diganti pembersih layar yang tahan banting.
- Log gagal ditulis di folder read-only, sehingga perintah install di bash tidak dijalankan. Log kini pindah ke folder temp.
- Nama paket Linux disesuaikan hasil uji: Alpine `tealdeer`, JDK/.NET di Fedora & Debian, Node di openSUSE, IntelliJ/PyCharm/Arduino/VirtualBox di Arch, iperf/qemu di openSUSE.
- Katalog web membaca kolom Linux bergeser setelah kolom Termux ditambahkan (99 → 105 aplikasi).
- Mode lite situs terlalu agresif (aktif di perangkat 16 GB RAM / 4 core). Kini keputusan memakai probe FPS.

[2.1.0]: https://github.com/fk0u/tipack/releases/tag/v2.1.0
[2.0.0]: https://github.com/fk0u/tipack/releases/tag/v2.0.0
