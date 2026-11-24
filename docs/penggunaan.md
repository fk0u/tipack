# Panduan Penggunaan

Panduan ini membahas setiap layar TIPACK secara berurutan. Tampilan di Windows, macOS dan Linux hampir sama; perbedaannya ditandai.

- [Layar pembuka](#1-layar-pembuka)
- [Menu utama](#2-menu-utama)
- [Wizard preferensi](#3-wizard-preferensi)
- [Profil siap pakai](#4-profil-siap-pakai)
- [Pilih manual per kategori](#5-pilih-manual-per-kategori)
- [Cek status](#6-cek-status)
- [Keranjang & install](#7-keranjang--install)
- [Ekstensi VS Code](#8-ekstensi-vs-code)
- [Setup Git & SSH key](#9-setup-git--ssh-key)
- [Tweak OS](#10-tweak-os-untuk-developer)
- [Update semua](#11-update-semua)
- [Info sistem](#12-info-sistem)
- [Membaca tampilan daftar](#membaca-tampilan-daftar)

---

## 1. Layar pembuka

Saat dijalankan, TIPACK menampilkan banner lalu mengecek sistem:

| Cek | Windows | macOS | Linux |
|---|---|---|---|
| Info sistem | Model laptop, versi Windows, CPU, RAM, disk C | Model Mac, chip, macOS, CPU, RAM, disk | Distro, kernel, desktop, CPU, RAM, disk |
| Hak akses | Administrator? Kalau tidak, ditawari menjalankan ulang sebagai Admin | — | Root atau user + sudo |
| Package manager | winget ada? Kalau tidak, Microsoft Store dibuka ke "App Installer" | Xcode CLT & Homebrew (dipasang otomatis) | apt/dnf/pacman/zypper/apk + status AUR helper |
| Virtualisasi | Status VT-x/AMD-V (untuk WSL, Docker, emulator) | — | Status KVM (`/dev/kvm`) |
| Internet | Resolusi DNS github.com | Request ke github.com | Request ke github.com |

Lalu TIPACK **memindai aplikasi yang sudah terpasang** dan menampilkan hasilnya, misalnya `✓ Pemindaian selesai: 22 dari 113 aplikasi sudah terpasang`.

Peringatan yang mungkin muncul: disk hampir penuh, tidak ada internet, virtualisasi BIOS mati.

## 2. Menu utama

| Menu | Fungsi |
|---|---|
| 🧙 **Wizard Preferensi** | Tanya-jawab langkah demi langkah. **Paling disarankan untuk laptop baru.** |
| 📦 **Profil Siap Pakai** | Paket aplikasi sesuai peminatan, bisa diubah sebelum dipasang. |
| 🗂 **Pilih Manual per Kategori** | Jelajahi katalog dan centang sendiri. |
| 🔍 **Cek Status** | Lihat semua aplikasi beserta statusnya, sekaligus menyimpan `laporan-status.txt`. |
| 🛒 **Keranjang & Install** | Tinjau pilihan lalu mulai instalasi. Badge di kanan menunjukkan jumlah item. |
| 🧩 **Ekstensi VS Code** | Pasang ekstensi VS Code pilihan. |
| 🔑 **Setup Git & SSH Key** | Identitas Git dan SSH key untuk GitHub. |
| ⚙️ **Tweak OS** | Pengaturan OS yang ramah programmer. |
| ⟳ **Update Semua** | Update semua aplikasi lewat package manager. |
| 💻 **Info Sistem** | Detail spesifikasi dan rekomendasi berdasarkan RAM. |
| ⏻ **Keluar** | Kalau keranjang belum kosong, ada konfirmasi dulu. |

Semua pilihan di wizard, profil dan kategori masuk ke **satu keranjang yang sama**, jadi kamu bisa mengombinasikannya (misalnya profil `web` ditambah beberapa aplikasi dari kategori Desain).

## 3. Wizard preferensi

Wizard menanyakan preferensi per topik. Ada dua jenis pertanyaan:

- **Pilih satu** (● / ○): misalnya browser utama atau aplikasi arsip. Selalu ada opsi *Lewati / tidak perlu*.
- **Pilih banyak** (◉ / ◯): misalnya bahasa pemrograman atau tool jaringan.

Indikator `●●●○○○` di judul menunjukkan posisi pertanyaan. Tekan **Esc** untuk kembali ke pertanyaan sebelumnya (jawaban tetap tersimpan). Di pertanyaan pertama, Esc keluar dari wizard.

Setelah pertanyaan terakhir, kamu langsung dibawa ke [Keranjang](#7-keranjang--install).

### Daftar pertanyaan

| # | Windows (20) | macOS (19) | Linux (16) |
|---|---|---|---|
| 1 | Browser utama | Browser utama | Browser utama |
| 2 | Kompres/ekstrak arsip (7-Zip, **WinRAR**, NanaZip, PeaZip) | Pengganti WinRAR (The Unarchiver, Keka) | Terminal & shell |
| 3 | Editor kode | Terminal & shell | Editor kode |
| 4 | IDE tambahan | Editor kode | IDE tambahan |
| 5 | Bahasa & runtime | IDE tambahan | Bahasa & runtime |
| 6 | Web server lokal (XAMPP / Laragon / Docker) | Bahasa & runtime | Web server (LAMP / XAMPP / Docker) |
| 7 | Database & client | Web server (DBngin / Herd / MAMP / XAMPP) | Database & client |
| 8 | Git & API tools | Database & client | Git & API tools |
| 9 | Terminal & shell | Git & API tools | Container & VM |
| 10 | **Mau WSL?** (core, Ubuntu, Debian, Kali) | Container / Linux (pengganti WSL: OrbStack, Docker, UTM, Multipass) | Jaringan & keamanan |
| 11 | **WSA / aplikasi Android?** | Virtual machine | DevOps & AI |
| 12 | Virtual machine | Jaringan & keamanan | Mobile & game |
| 13 | Jaringan & keamanan | DevOps & cloud | Desain & multimedia |
| 14 | DevOps & cloud | AI di laptop | Komunikasi |
| 15 | AI di laptop | Mobile & game | Kuliah & produktivitas |
| 16 | Mobile & game | Desain & multimedia | Utilitas sistem |
| 17 | Desain & multimedia | Komunikasi | |
| 18 | Komunikasi | Kuliah & produktivitas | |
| 19 | Kuliah & produktivitas | Utilitas Mac | |
| 20 | Utilitas sistem | | |

> [!NOTE]
> **Tentang WSA.** Microsoft menghentikan Windows Subsystem for Android pada **5 Maret 2025**, dan WSA tidak bisa dipasang lagi. Di pertanyaan ini pilih **Android Studio** (emulator resmi, untuk develop) atau **BlueStacks** (untuk sekadar menjalankan APK). Kalau WSA tetap dipilih, TIPACK hanya menampilkan informasi tersebut.

> [!NOTE]
> **Tentang WSL.** WSL butuh virtualisasi aktif di BIOS dan restart. Status virtualisasi laptop ditampilkan langsung di teks pertanyaan.

## 4. Profil siap pakai

| Preset | Untuk |
|---|---|
| `starter` | Mahasiswa IF semester 1–2: browser, editor, compiler C/C++, Python, Java, Node, Git, database, draw.io, komunikasi |
| `cpp` | Praktikum Algoritma & Struktur Data |
| `java` | Pemrograman Berorientasi Objek |
| `web` | Fullstack: Laravel/PHP, Node, database, Postman, Docker |
| `mobile` | Android Studio, JDK, Flutter |
| `data` | Python, uv/conda, R, Jupyter, LLM lokal |
| `net` | Packet Tracer, Wireshark, Nmap, SSH tools, VM |
| `devops` | Docker/Podman, Kubernetes, Terraform, cloud CLI |
| `game` | Unity, Godot, Blender |
| `design` | Figma, GIMP, Inkscape, OBS |
| `tech` | Abang IT / power user: tool servis, flashdisk bootable, remote desktop |

Isi persisnya per OS ada di [katalog.md](katalog.md#profil). Alur di menu:

1. Pilih profil. Kotak info menampilkan deskripsi dan semua isinya.
2. Muncul checklist isi profil yang **sudah dicentang semua**. Hapus centang yang tidak perlu.
3. Enter → masuk keranjang → ditawari langsung install.

## 5. Pilih manual per kategori

Daftar kategori menampilkan jumlah aplikasi, berapa yang sudah terpasang, dan berapa yang ada di keranjang. Pilih kategori untuk membuka checklist-nya. Opsi **» Semua aplikasi** menampilkan seluruh katalog dalam satu daftar dengan pemisah kategori.

## 6. Cek status

Menampilkan seluruh katalog dengan status:

- `✓ terpasang`: sudah ada, tidak bisa dicentang.
- `□` / `◯`: belum ada. Centang untuk memasukkan ke keranjang.

Setiap kali menu ini dibuka, laporan teks disimpan ke `laporan-status.txt` (format `[v]` / `[ ]`), berguna untuk dicetak atau dikirim ke teman yang membantu.

## 7. Keranjang & install

### Tinjau

Semua item keranjang sudah dicentang; hapus centang untuk membatalkan. Di bagian atas bisa muncul peringatan:

| Peringatan | Alasan |
|---|---|
| Paket berat | Docker, Android Studio, Visual Studio, Unity, LLM lokal: download besar dan butuh RAM besar |
| Node.js + NVM/fnm | Dua cara memasang Node sebaiknya tidak dicampur |
| MySQL + XAMPP | Bentrok port 3306 |
| Docker + OrbStack (macOS) | Keduanya menyediakan perintah `docker` |

Tekan **Enter** untuk **MULAI INSTALL**.

### Proses

- **macOS/Linux:** password diminta sekali di awal, lalu sesi sudo dijaga tetap hidup selama instalasi.
- **Linux:** daftar paket diperbarui dulu (`apt update` / `dnf makecache` / `pacman -Sy` / dst). Kalau ada item AUR dan `yay` belum ada, `yay` dipasang dulu.
- Urutan instalasi: fitur sistem (WSL/fitur Windows) → paket utama → AUR/script → Flatpak → item manual.

Setiap item menampilkan progress bar keseluruhan, spinner dan timer, lalu hasilnya:

| Tanda | Arti |
|---|---|
| `√` / `✓` | Berhasil (dengan durasi) |
| `=` | Sudah terpasang atau sudah versi terbaru (Windows) |
| `i` / `ⓘ` | Harus diinstall manual; link dikumpulkan di akhir |
| `×` / `✗` | Gagal; detail ada di log, item tetap di keranjang untuk dicoba lagi |

### Ringkasan

Kotak ringkasan menampilkan jumlah berhasil, sudah ada, manual dan gagal, plus waktu total. Lalu:

- Daftar link download manual, dengan tawaran membuka semuanya di browser.
- Pengingat membuka terminal baru supaya PATH terbaca.
- **Windows:** tawaran restart kalau WSL atau fitur Windows membutuhkannya.
- **Linux:** pengingat logout-login kalau grup docker atau shell zsh berubah.

## 8. Ekstensi VS Code

Membaca ekstensi yang sudah terpasang (`code --list-extensions`), lalu menampilkan checklist. Yang direkomendasikan dan belum terpasang sudah dicentang otomatis.

Ekstensi rekomendasi: C/C++ Extension Pack, Code Runner, Python, Extension Pack for Java, Prettier, Live Server, GitLens, Git Graph, Error Lens, Path Intellisense, Material Icon Theme. Di Windows ditambah WSL, dan di Linux ditambah ShellCheck. Daftar lengkap (24–30 ekstensi) bisa dilihat di menu.

## 9. Setup Git & SSH key

1. Menampilkan konfigurasi Git saat ini.
2. Menanyakan **nama** dan **email**. Pakai email yang sama dengan akun GitHub supaya commit terhubung ke profilmu.
3. Mengatur `init.defaultBranch=main`, `pull.rebase=false`, `core.autocrlf` (`true` di Windows, `input` di macOS/Linux) dan editor VS Code.
4. Membuat SSH key `ed25519` kalau belum ada.
5. Menyalin public key ke clipboard:
   - Windows: `Set-Clipboard`
   - macOS: `pbcopy`, ditambah key disimpan di Keychain
   - Linux: `wl-copy`, `xclip`, `xsel`, atau `clip.exe` di WSL
6. Menawarkan membuka `github.com/settings/ssh/new`, tes `ssh -T git@github.com`, dan `gh auth login`.
7. Windows (Admin): bisa mengaktifkan service `ssh-agent`.

## 10. Tweak OS untuk developer

Hanya pengaturan yang **belum aktif** yang dicentang otomatis. Yang sudah aktif ditandai ✓.

**Windows**

| Tweak | Butuh Admin |
|---|---|
| Tampilkan ekstensi file | — |
| Tampilkan file tersembunyi | — |
| Mode gelap | — |
| Long Paths (> 260 karakter) | ✓ |
| Developer Mode | ✓ |
| ExecutionPolicy RemoteSigned (CurrentUser), supaya `npm`/`venv` jalan di PowerShell | — |
| `git config core.longpaths true` | — |

**macOS:** tampilkan ekstensi file, file tersembunyi di Finder, path bar & status bar, folder screenshot `~/Pictures/Screenshots`, key repeat cepat, matikan popup aksen, tanpa `.DS_Store` di flashdisk/jaringan, Dock auto-hide.

**Linux**

- Batas inotify 524288. Ini mengatasi error `ENOSPC: System limit for number of file watchers reached` di VS Code, Vite dan Webpack.
- Grup `dialout`/`uucp` (Arduino), `docker` dan `libvirt`.
- Untuk GNOME: mode gelap, file tersembunyi, persentase baterai.

## 11. Update semua

| OS | Perintah yang dijalankan |
|---|---|
| Windows | `winget upgrade --all --include-unknown` + `wsl --update` |
| macOS | `brew update && brew upgrade && brew upgrade --cask --greedy && brew cleanup` |
| Linux | Upgrade paket distro (via `yay`/`paru` di Arch kalau ada) + `flatpak update` |

## 12. Info sistem

Menampilkan spesifikasi dengan saran praktis, misalnya:

- RAM < 8 GB: hindari Docker dan Android Studio.
- Virtualisasi/KVM mati: cara mengaktifkannya di BIOS.
- Disk kurang dari 30 GB.

## Membaca tampilan daftar

```
 ► ■ Visual Studio Code                     √ terpasang  ♦ rekomendasi
   □ Cursor
```

| Simbol | Arti |
|---|---|
| `►` / `❯` | Posisi kursor |
| `■` `◉` | Dicentang |
| `□` `◯` | Belum dicentang |
| `●` / `○` | Pilihan tunggal (radio) |
| `√` / `✓ terpasang` | Sudah ada di laptop (tidak bisa dicentang) |
| `+ keranjang` | Sudah ada di keranjang |
| `♦` / `★ rekomendasi` | Direkomendasikan untuk mahasiswa IF |
| `i manual` / `ⓘ manual` | Harus download manual |
| `fitur Windows` | WSL / Windows Optional Feature |
| `flatpak`, `AUR` | (Linux) Sumber paket |
| `! berat untuk RAM xGB` | Aplikasi berat untuk RAM laptop ini |

Kotak info di bawah daftar selalu menjelaskan item yang sedang disorot: fungsinya, status di laptop ini, dan perintah/sumber instalasinya.
