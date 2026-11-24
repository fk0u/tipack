# TIPACK di Linux

- [Distro yang didukung](#distro-yang-didukung)
- [Cara deteksi distro](#cara-deteksi-distro)
- [Urutan metode instalasi](#urutan-metode-instalasi)
- [Script & repo resmi](#script--repo-resmi)
- [AUR (Arch)](#aur-arch)
- [Flatpak](#flatpak)
- [Root, sudo dan WSL](#root-sudo-dan-wsl)
- [Yang dilakukan setelah instalasi](#yang-dilakukan-setelah-instalasi)
- [Distro yang belum didukung penuh](#distro-yang-belum-didukung-penuh)

## Distro yang didukung

| Keluarga | Package manager | Distro (contoh) |
|---|---|---|
| Debian | `apt` | Debian, Ubuntu, Linux Mint, Pop!_OS, Zorin OS, elementary OS, Kali, Raspberry Pi OS, MX |
| Fedora/RHEL | `dnf` | Fedora, RHEL, Rocky Linux, AlmaLinux, CentOS Stream, Nobara |
| Arch | `pacman` + AUR | Arch Linux, Manjaro, EndeavourOS, CachyOS, Garuda, Artix |
| openSUSE | `zypper` | openSUSE Tumbleweed, Leap, SLES |
| Alpine | `apk` | Alpine Linux |

## Cara deteksi distro

1. Membaca `/etc/os-release` → `ID` dan `ID_LIKE`. Contoh: Linux Mint punya `ID_LIKE="ubuntu debian"`, jadi dianggap keluarga apt.
2. Kalau tidak cocok, mencari perintah yang ada: `apt-get` → `dnf` → `pacman` → `zypper` → `apk`.
3. Kalau semuanya tidak ada → mode **hanya Flatpak & script resmi**.

Hasilnya tampil di layar pembuka dan di menu **Info Sistem**.

## Urutan metode instalasi

Untuk setiap aplikasi, TIPACK memilih **satu** cara dengan urutan prioritas:

1. **Paket repo distro.** Paling terintegrasi, dan ikut ter-update saat update sistem.
2. **AUR** (khusus keluarga Arch, untuk aplikasi yang hanya ada di AUR).
3. **Script/repo resmi vendor.** Misalnya repo Microsoft untuk VS Code di apt/dnf/zypper.
4. **Flatpak (Flathub).** Untuk aplikasi GUI yang tidak ada di repo distro.
5. **Download manual.** Link dikumpulkan dan dibuka di akhir instalasi.

Aplikasi yang **tidak punya satu pun cara** untuk distro kamu disembunyikan dari semua menu, jadi tidak ada pilihan yang pasti gagal.

**Paket alternatif.** Kolom paket bisa berisi `a/b/c`, artinya pakai yang pertama tersedia di repo. Contohnya JDK: Debian 12 belum punya OpenJDK 21, jadi otomatis dapat 17; Fedora terbaru dapat 25.

Kotak info setiap aplikasi menampilkan metode yang akan dipakai, misalnya `apt: build-essential gdb`, `Flatpak: com.getpostman.Postman`, `AUR: visual-studio-code-bin (lewat yay)`, atau `script/repo resmi (repo Microsoft)`.

Contoh untuk satu aplikasi:

| Aplikasi | apt | dnf | pacman | zypper | apk |
|---|---|---|---|---|---|
| Build tools C/C++ | `build-essential gdb` | `gcc gcc-c++ make gdb` | `base-devel gdb` | `gcc gcc-c++ make gdb` | `build-base gdb` |
| Java JDK LTS | `openjdk-21-jdk` atau `openjdk-25-jdk` atau `openjdk-17-jdk` | `java-21-openjdk-devel` atau `java-25-openjdk-devel` | `jdk21-openjdk` | `java-21-openjdk-devel` atau `java-25-openjdk-devel` | `openjdk21` atau `openjdk25` |
| VS Code | repo Microsoft | repo Microsoft | AUR `visual-studio-code-bin` | repo Microsoft | Flatpak |
| Postman | Flatpak | Flatpak | AUR `postman-bin` | Flatpak | Flatpak |

Daftar lengkap ada di [katalog.md](katalog.md) dan di https://tipack.kousozo.tech/katalog (klik aplikasi untuk melihat perintah per distro).

## Script & repo resmi

| Aplikasi | Sumber |
|---|---|
| VS Code | Repo `packages.microsoft.com` (apt / yum / zypp) dengan kunci GPG Microsoft |
| Google Chrome | Paket `.deb` / `.rpm` resmi dari `dl.google.com` (hanya x86_64) |
| Docker Engine | `get.docker.com` (apt/dnf); paket distro untuk Arch/openSUSE/Alpine. User ditambahkan ke grup `docker` |
| Rust | `sh.rustup.rs` |
| uv | `astral.sh/uv/install.sh` |
| Bun | `bun.sh/install` |
| fnm | `fnm.vercel.app/install` |
| Ollama | `ollama.com/install.sh` |
| Starship | `starship.rs/install.sh` |
| kubectl | Binary dari `dl.k8s.io` ke `/usr/local/bin` |
| JetBrains Mono Nerd Font | Rilis GitHub `ryanoasis/nerd-fonts` ke `~/.local/share/fonts` |
| Oh My Zsh | `ohmyzsh/ohmyzsh` + plugin `zsh-autosuggestions` & `zsh-syntax-highlighting` (git clone), lalu shell default diubah ke zsh |

## AUR (Arch)

- Kalau `paru` atau `yay` sudah ada, itu yang dipakai.
- Kalau belum dan keranjang berisi item AUR, TIPACK memasang `base-devel` dan `git`, lalu membangun **`yay-bin`** dari AUR.
- AUR **tidak bisa** dipakai saat script dijalankan sebagai root, karena `makepkg` memang menolak root. Jalankan sebagai user biasa.

## Flatpak

- Kalau ada aplikasi yang butuh Flatpak, `flatpak` dipasang dari repo distro dan remote **Flathub** ditambahkan untuk user (`--user`), jadi tidak perlu sudo untuk aplikasinya.
- Aplikasi Flatpak yang sudah ada ikut terdeteksi sebagai *terpasang*, walaupun metode utama untuk distro itu adalah paket native.
- Supaya aplikasi Flatpak muncul di menu aplikasi tanpa relogin, `XDG_DATA_DIRS` ditambahkan ke `~/.bashrc`/`~/.zshrc`.
- Beberapa aplikasi di Flathub adalah **klien komunitas**, bukan resmi: Figma (`Figma_Linux`) dan GitHub Desktop (`shiftey`). Ini ditulis jelas di nama dan tooltip-nya.

## Root, sudo dan WSL

| Situasi | Perilaku |
|---|---|
| User biasa + sudo (disarankan) | Password diminta sekali saat instalasi dimulai, sesi sudo dijaga selama instalasi |
| Dijalankan sebagai root (container, server) | Tanpa sudo; AUR, `chsh` dan penambahan grup user dilewati |
| `curl ... \| sudo bash` | Ditolak oleh bootstrap. Jalankan tanpa sudo |
| WSL | Terdeteksi otomatis. Aplikasi GUI tampil lewat WSLg (Windows 11). Clipboard memakai `clip.exe` |

## Yang dilakukan setelah instalasi

- **apt:** membuat symlink `bat` → `batcat` dan `fd` → `fdfind` di `~/.local/bin` (nama di Debian/Ubuntu berbeda).
- Mengaktifkan service **mariadb**, **postgresql** dan **docker** kalau terpasang (`systemctl enable --now`).
- **Fedora:** inisialisasi database PostgreSQL (`postgresql-setup --initdb`).
- Menambahkan PATH untuk `~/.local/bin`, `~/.cargo`, `~/.bun/bin` dan fnm ke `~/.bashrc` (dan `~/.zshrc` kalau ada). Baris yang sudah ada tidak ditulis dua kali.

## Distro yang belum didukung penuh

**Void, Solus, NixOS, Gentoo, Slackware, Clear Linux** dan distro lain dengan package manager yang tidak dikenali tetap bisa menjalankan TIPACK. Yang tersedia hanya aplikasi lewat **Flatpak** dan **script resmi**; paket native tidak dipasang.

Di **NixOS**, cara yang benar adalah mendeklarasikan paket di `configuration.nix` atau home-manager.

Mau menambahkan dukungan package manager baru? Lihat [arsitektur.md](arsitektur.md#menambah-package-manager-linux).
