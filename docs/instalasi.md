# Instalasi

- [Syarat sistem](#syarat-sistem)
- [Perintah satu baris](#perintah-satu-baris)
- [Apa yang terjadi saat perintah dijalankan](#apa-yang-terjadi-saat-perintah-dijalankan)
- [Instalasi manual](#instalasi-manual)
- [Parameter](#parameter)
- [Lokasi file](#lokasi-file)
- [Menjalankan ulang](#menjalankan-ulang)
- [Menghapus TIPACK](#menghapus-tipack)

## Syarat sistem

| | Windows | macOS | Linux |
|---|---|---|---|
| Arsitektur | x64, ARM64, x86 (katalog terbatas) | Apple Silicon & Intel | x64, ARM64 (termasuk Raspberry Pi), Termux di Android |
| Versi | Windows 10 1809+ atau Windows 11 | macOS 12 Monterey+ | Distro keluarga Debian, Fedora, Arch, openSUSE, Alpine (lihat [linux.md](linux.md)) |
| Shell | Windows PowerShell 5.1 (bawaan) | bash 3.2 (bawaan) | bash 4+ |
| Package manager | **winget** (App Installer). Bawaan Win 11; di Win 10 update "App Installer" dari Microsoft Store | Homebrew (dipasang otomatis) | Bawaan distro; Flatpak dipasang otomatis bila perlu |
| Hak akses | Administrator disarankan (wajib untuk WSL & fitur Windows) | Password Mac (untuk Homebrew & cask tertentu) | User biasa dengan akses `sudo` |
| Internet | Wajib | Wajib | Wajib |
| Disk kosong | Minimal 20 GB disarankan | Minimal 20 GB | Minimal 15 GB |
| Terminal | Windows Terminal disarankan (emoji & braille spinner tampil sempurna) | Terminal / iTerm2 | Terminal apa saja dengan UTF-8 & 256 warna |

Ukuran terminal minimal sekitar **80 × 30**. Kalau tingginya **40 baris atau lebih**, banner ASCII ikut tampil di menu utama.

## Perintah satu baris

### Windows

Buka **PowerShell** atau **Terminal** (tekan `Win` + `X`, pilih *Terminal*), lalu:

```powershell
irm https://tipack.kousozo.tech/install.ps1 | iex
```

Kalau PowerShell belum berjalan sebagai Administrator, akan muncul popup UAC. Klik **Yes**, lalu installer terbuka di jendela baru.

### macOS dan Linux

```bash
curl -fsSL https://tipack.kousozo.tech/install.sh | bash
```

Kalau `curl` tidak ada:

```bash
wget -qO- https://tipack.kousozo.tech/install.sh | bash
```

> [!IMPORTANT]
> **Jangan** pakai `sudo curl ... | sudo bash`. Bootstrap akan menolak berjalan lewat `sudo` di Linux. Password sudo diminta sendiri oleh installer saat dibutuhkan.

## Apa yang terjadi saat perintah dijalankan

**`install.ps1` (Windows):**
1. Membuat folder `%USERPROFILE%\devsetup-if`.
2. Mengunduh `setup.ps1` dan `JALANKAN.bat` dari `tipack.kousozo.tech/windows/`.
3. `Unblock-File` supaya PowerShell tidak menganggapnya file internet yang diblokir.
4. Kalau belum Administrator: membuka jendela baru dengan `-Verb RunAs` (Windows Terminal kalau ada). Kalau sudah: langsung menjalankan `setup.ps1`.

**`install.sh` (macOS/Linux):**
1. Mendeteksi OS lewat `uname -s` (Darwin → `macos`, Linux → `linux`).
2. Membuat folder `~/devsetup-if` lalu mengunduh `setup.sh` yang sesuai.
3. Menjalankan `bash setup.sh` dengan input keyboard diarahkan ke `/dev/tty` (karena script dijalankan lewat pipe).

Setelah itu installer interaktif mengambil alih. Lihat [penggunaan.md](penggunaan.md).

## Instalasi manual

Cara paling aman: download, baca, lalu jalankan sendiri.

### Windows

1. Download [`setup.ps1`](https://tipack.kousozo.tech/windows/setup.ps1) dan [`JALANKAN.bat`](https://tipack.kousozo.tech/windows/JALANKAN.bat), atau clone repo ini.
2. Simpan keduanya di folder yang sama.
3. Klik kanan **JALANKAN.bat** → **Run as administrator**.

Atau dari PowerShell (Admin):

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\setup.ps1
```

> `setup.ps1` disimpan sebagai **UTF-8 dengan BOM**. Jangan simpan ulang tanpa BOM di editor, nanti karakter kotak dan garis berubah jadi karakter aneh di PowerShell 5.1.

### macOS

```bash
curl -fsSLO https://tipack.kousozo.tech/macos/setup.sh
less setup.sh          # baca dulu
bash setup.sh
```

### Linux

```bash
curl -fsSLO https://tipack.kousozo.tech/linux/setup.sh
less setup.sh
bash setup.sh
```

### Dari repo Git

```bash
git clone https://github.com/fk0u/tipack.git
cd tipack
bash macos/setup.sh      # atau: bash linux/setup.sh
```

## Parameter

| Windows (`setup.ps1`) | macOS/Linux (`setup.sh`) | Fungsi |
|---|---|---|
| `-Preset <nama>` | `--preset <nama>` | Langsung memasang satu profil tanpa menu. Nama: `starter cpp java web mobile data net devops game design tech`. |
| `-Install a,b,c` | `--install a,b,c` | Pasang aplikasi tertentu (key dari [katalog](katalog.md)) tanpa menu. Exit code `3` kalau ada yang gagal. |
| `-SelfTest` | `--self-test` | Cek sistem & katalog lalu keluar, tanpa memasang apa pun. |
| `-NoAnim` | `--no-anim` | Matikan animasi banner dan efek ketik (lebih cepat, cocok untuk terminal lambat/SSH). |

Parameter juga bisa diteruskan lewat bootstrap:

```bash
curl -fsSL https://tipack.kousozo.tech/install.sh | bash -s -- --preset starter
```

## Lokasi file

| File | Windows | macOS/Linux |
|---|---|---|
| Script | `%USERPROFILE%\devsetup-if\setup.ps1` (via bootstrap) | `~/devsetup-if/setup.sh` |
| Log instalasi | `devsetup-log-YYYYMMDD-HHMMSS.txt` di folder script | sama |
| Laporan status | `laporan-status.txt` di folder script (dibuat saat membuka menu *Cek Status*) | sama |
| Konfigurasi shell yang mungkin ditambah | — | `~/.zshrc`, `~/.bashrc`, `~/.zprofile` (PATH, alias, Oh My Zsh) |
| SSH key (menu Git) | `%USERPROFILE%\.ssh\id_ed25519` | `~/.ssh/id_ed25519` |

## Menjalankan ulang

Jalankan perintah yang sama kapan saja. Aplikasi yang sudah terpasang terdeteksi dan dilewati, jadi aman dipakai untuk menambah aplikasi baru atau mencoba ulang yang gagal.

## Menghapus TIPACK

TIPACK tidak memasang dirinya sendiri sebagai aplikasi. Cukup hapus folder `devsetup-if` di folder home. Aplikasi yang sudah dipasang tetap ada dan bisa dihapus lewat cara biasa:

| OS | Contoh |
|---|---|
| Windows | `winget uninstall --id Git.Git` atau Settings → Apps |
| macOS | `brew uninstall git` / `brew uninstall --cask visual-studio-code` |
| Linux | `sudo apt remove ...`, `sudo dnf remove ...`, `sudo pacman -Rns ...`, `flatpak uninstall ...` |
