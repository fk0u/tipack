# DEVSETUP IF v2

```
██████╗ ███████╗██╗   ██╗███████╗███████╗████████╗██╗   ██╗██████╗
██╔══██╗██╔════╝██║   ██║██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
██║  ██║█████╗  ██║   ██║███████╗█████╗     ██║   ██║   ██║██████╔╝
██║  ██║██╔══╝  ╚██╗ ██╔╝╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝
██████╔╝███████╗ ╚████╔╝ ███████║███████╗   ██║   ╚██████╔╝██║
╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝
        I F  ·  Installer Toolkit Mahasiswa Teknik Informatika & Abang IT
```

Installer interaktif di terminal untuk laptop baru. Navigasinya pakai panah, ada checklist, panel tooltip untuk setiap aplikasi, label rekomendasi, dan cek otomatis aplikasi yang sudah terpasang.

| OS | File | Mesin |
|---|---|---|
| Windows 10/11 | `windows/JALANKAN.bat` → `setup.ps1` | winget + WSL + Windows Features |
| macOS (Apple Silicon & Intel) | `macos/setup.sh` | Homebrew (diinstall otomatis) |
| Linux (semua distro besar) | `linux/setup.sh` | apt · dnf · pacman + AUR · zypper · apk, plus Flatpak sebagai cadangan |

## Cara menjalankan
**Windows:** klik kanan `windows/JALANKAN.bat` → **Run as administrator**. Paling bagus dibuka di **Windows Terminal**.

**macOS:**
```bash
chmod +x macos/setup.sh && ./macos/setup.sh
```

**Linux / macOS (satu perintah, OS terdeteksi otomatis):**
```bash
curl -fsSL https://tipack.kousozo.tech/install.sh | bash
```

Mode tanpa menu: `setup.ps1 -Preset starter` / `./setup.sh --preset starter`.
Pilihan preset: `starter cpp java web mobile data net devops game design tech`. Tambahkan `-NoAnim` / `--no-anim` untuk mematikan animasi.

## Fitur
- **Boot screen:** banner ASCII, cek admin/winget/brew/internet, lalu info laptop (CPU, RAM, disk, status virtualisasi BIOS).
- **Deteksi otomatis:** setiap aplikasi dicek lewat `winget export` / `brew list`, perintah di PATH, dan folder instalasi. Yang sudah terpasang ditandai ✓ dan otomatis dilewati.
- **Wizard Preferensi:** sekitar 20 pertanyaan, misalnya WinRAR atau 7-Zip, mau WSL atau tidak, WSA atau alternatifnya, editor, IDE dan bahasa. Setiap pilihan punya tooltip dan rekomendasi. Tekan Esc untuk kembali ke pertanyaan sebelumnya.
- **Profil siap pakai:** Starter Mahasiswa IF, C/C++, Java/PBO, Web, Mobile, Data/AI, Jaringan & Security, DevOps, Game, Desain, Abang IT.
- **Pilih manual:** per kategori, atau satu daftar panjang berisi semua aplikasi.
- **Keranjang:** ditinjau sebelum install, dengan peringatan konflik (Node vs NVM, XAMPP vs MySQL, Docker vs OrbStack) dan peringatan paket berat kalau RAM kecil.
- **Instalasi:** progress bar, spinner + timer per aplikasi, ringkasan akhir, log lengkap, lalu link download untuk aplikasi yang harus diinstall manual.
- **Ekstra:** pemilih ekstensi VS Code (28+), setup Git + SSH key + GitHub, tweak OS untuk developer, update semua, info sistem, dan `laporan-status.txt`.

## Tombol
| Tombol | Fungsi |
|---|---|
| ↑ ↓ / j k | gerak |
| PgUp PgDn Home End | lompat |
| Spasi | centang |
| a / n / r | centang semua / kosongkan / hanya rekomendasi |
| Enter | pilih / lanjut |
| Esc / Backspace / q (mac) | kembali |

## Catatan penting
- **WSA (Windows Subsystem for Android) sudah dihentikan Microsoft sejak 5 Maret 2025.** Di wizard, pilihan WSA diarahkan ke Android Studio Emulator atau BlueStacks.
- **WSL** butuh virtualisasi aktif di BIOS (Intel VT-x / AMD SVM) dan restart. Statusnya tampil di boot screen.
- Di **Mac tidak ada WSL**. Penggantinya OrbStack (Docker + Linux VM), UTM, atau Multipass.
- Aplikasi yang harus di-download manual (ditandai ⓘ): Cisco Packet Tracer (akun NetAcad), Microsoft 365 (email kampus), Google Antigravity, Xcode (App Store), XAMPP untuk Mac.
- Menambah aplikasi cukup dengan menambah satu baris di `$CatalogRaw` (Windows, cari ID pakai `winget search nama`) atau `CATALOG_RAW` (macOS, pakai `brew search nama`).

## Linux
- Distro dideteksi dari `/etc/os-release`: **apt** (Debian, Ubuntu, Mint, Pop!_OS, Kali, Zorin), **dnf** (Fedora, RHEL, Rocky, Alma), **pacman + AUR** (Arch, Manjaro, EndeavourOS, CachyOS, Garuda), **zypper** (openSUSE), **apk** (Alpine).
- Urutan cara install per aplikasi: paket repo distro → AUR (Arch) → Flatpak (Flathub) → script/repo resmi (VS Code, Chrome, Docker, rustup, Ollama, dll) → download manual. Aplikasi yang tidak tersedia di distro itu disembunyikan dari menu.
- Jalankan sebagai **user biasa**, bukan dengan `sudo`. Password sudo diminta sekali saat instalasi dimulai.
- `linux/setup.sh` dirakit oleh `linux/src/build.sh` dari `linux/src/linux-parts.sh` + mesin TUI `macos/setup.sh`. Edit `linux-parts.sh`, lalu jalankan `bash linux/src/build.sh`.

## Web (tipack.kousozo.tech)
- `web/index.html` landing page, `web/katalog.html` katalog semua aplikasi, `web/perf.js` sistem optimisasi animasi.
- `web/catalog.json` dibuat otomatis dari ketiga script: `python3 web/build-catalog.py`. Jalankan ulang setiap kali katalog di script berubah.
