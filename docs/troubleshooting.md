# Troubleshooting & FAQ

Langkah pertama untuk masalah apa pun: buka **file log** `devsetup-log-*.txt` di folder script (`~/devsetup-if` atau `%USERPROFILE%\devsetup-if`). Semua output winget/brew/apt/dnf/pacman tercatat lengkap di sana.

- [Umum](#umum)
- [Windows](#windows)
- [macOS](#macos)
- [Linux](#linux)
- [Setelah instalasi](#setelah-instalasi)

## Umum

<details>
<summary><b>Perintah sudah terpasang tapi "command not found" / "tidak dikenali".</b></summary>

PATH baru hanya terbaca di terminal **baru**. Tutup semua jendela terminal dan VS Code, lalu buka lagi. Di macOS/Linux bisa juga dengan `source ~/.zshrc` atau `source ~/.bashrc`.
</details>

<details>
<summary><b>Ada aplikasi yang GAGAL.</b></summary>

1. Lihat log, cari baris `=== ... install <id>`.
2. Item yang gagal **tetap ada di keranjang**. Buka *Keranjang & Install* lagi untuk mencoba ulang (sering berhasil kalau penyebabnya koneksi).
3. Kalau ID paketnya ternyata salah atau berubah di sumbernya, laporkan lewat [issue](https://github.com/fk0u/tipack/issues) dengan menyertakan potongan log.
</details>

<details>
<summary><b>Tampilan berantakan: kotak/garis jadi karakter aneh, atau baris saling menimpa.</b></summary>

- Perbesar jendela terminal (minimal sekitar 80 × 30).
- **Windows:** pakai **Windows Terminal**. Kalau memakai console lama, pastikan `setup.ps1` masih UTF-8 **dengan BOM** (jangan disimpan ulang di Notepad lama).
- **Linux:** pastikan locale UTF-8 (`locale` → `LANG=...UTF-8`).
- Matikan animasi dengan `--no-anim` / `-NoAnim`.
</details>

<details>
<summary><b>Panah keyboard tidak berfungsi.</b></summary>

Pakai `j` (bawah) dan `k` (atas). Di beberapa terminal lewat SSH, kode panah bisa terlambat sampai. Di macOS/Linux, tombol `Esc` menunggu ±1 detik untuk membedakannya dari tombol panah; pakai `q` untuk kembali yang instan.
</details>

<details>
<summary><b>Bisa dipakai tanpa internet?</b></summary>

Tidak. Semua aplikasi diunduh dari sumber resminya saat instalasi.
</details>

## Windows

<details>
<summary><b>"winget tidak ditemukan"</b></summary>

Install atau update **App Installer** dari Microsoft Store: https://apps.microsoft.com/detail/9NBLGGH4NNS1. TIPACK membuka halaman ini otomatis. Di Windows 10 LTSC/Server, winget harus dipasang manual dari rilis GitHub `microsoft/winget-cli`.
</details>

<details>
<summary><b>"running scripts is disabled on this system"</b></summary>

Pakai `JALANKAN.bat` (sudah memakai `-ExecutionPolicy Bypass`) atau jalankan `Set-ExecutionPolicy -Scope Process Bypass -Force` sebelum `.\setup.ps1`. Supaya `npm` / `venv\Scripts\Activate.ps1` jalan permanen, aktifkan tweak **ExecutionPolicy RemoteSigned** di menu Tweak.
</details>

<details>
<summary><b>WSL gagal / "Please enable the Virtual Machine Platform"</b></summary>

1. Pastikan TIPACK berjalan sebagai **Administrator**.
2. Cek *Info Sistem* → *Virtualisasi*. Kalau **TIDAK AKTIF**, masuk BIOS (biasanya F2/Del/F10 saat boot), lalu aktifkan **Intel VT-x / Intel Virtualization Technology** atau **AMD-V / SVM Mode**.
3. **Restart**, lalu jalankan TIPACK lagi untuk memasang distro.
4. Setelah restart pertama, buka **Ubuntu** dari Start Menu untuk membuat username Linux.
</details>

<details>
<summary><b>Windows Sandbox: "tidak tersedia di edisi Windows ini"</b></summary>

Windows Sandbox hanya ada di Windows **Pro, Education dan Enterprise**. Laptop dengan Windows **Home** tidak bisa memakainya.
</details>

<details>
<summary><b>Banyak popup UAC (Yes/No) saat instalasi.</b></summary>

Jalankan TIPACK sebagai Administrator, atau terima tawaran "Jalankan ulang sebagai Administrator" di layar pembuka.
</details>

<details>
<summary><b>XAMPP: Apache/MySQL tidak mau start.</b></summary>

Port 80 atau 3306 dipakai aplikasi lain (Skype lama, IIS, MySQL Server terpisah). Jangan pasang MySQL Server bersamaan dengan XAMPP; TIPACK memperingatkan kombinasi ini di keranjang.
</details>

<details>
<summary><b>"g++ is not recognized" padahal MinGW sudah terpasang.</b></summary>

Buka terminal baru. Kalau masih belum terbaca, cek `where g++`. WinLibs lewat winget menambahkan folder `bin` ke PATH user, dan PATH itu baru terbaca setelah login ulang di beberapa kasus.
</details>

<details>
<summary><b>Python membuka Microsoft Store.</b></summary>

Itu "app execution alias" bawaan Windows. Matikan di Settings → Apps → Advanced app settings → App execution aliases (python.exe / python3.exe). TIPACK sendiri mengabaikan alias ini saat mendeteksi Python.
</details>

## macOS

<details>
<summary><b>Muncul popup "Install Command Line Developer Tools".</b></summary>

Itu Xcode Command Line Tools, yang dibutuhkan Homebrew. Klik **Install** dan tunggu sampai selesai. TIPACK menunggu otomatis lalu melanjutkan.
</details>

<details>
<summary><b>Password diminta tapi saat diketik tidak muncul apa-apa.</b></summary>

Normal. Terminal memang tidak menampilkan karakter password. Ketik lalu tekan Enter.
</details>

<details>
<summary><b>`g++` di Mac ternyata clang.</b></summary>

Benar: di macOS, `g++` adalah alias clang dari Apple. Kalau butuh GCC asli (misalnya untuk `bits/stdc++.h`), pasang **GCC** dari katalog lalu panggil dengan `g++-15` (sesuai versi terbaru).
</details>

<details>
<summary><b>Cask gagal: "It seems there is already an App at ..."</b></summary>

Aplikasinya sudah ada (dipasang manual dari situs resminya), tetapi tidak dikenali dari nama foldernya. Abaikan, atau hapus versi manual lalu install ulang lewat TIPACK supaya bisa di-update lewat brew.
</details>

## Linux

<details>
<summary><b>Paket tidak ditemukan (`Unable to locate package` / `target not found`).</b></summary>

- **Ubuntu:** pastikan repo `universe` aktif: `sudo add-apt-repository universe`.
- **Debian/Ubuntu versi lama:** beberapa paket (misal `fastfetch`, `btop`) baru ada di rilis terbaru. Item lain tetap terpasang.
- **Fedora:** sebagian aplikasi (VirtualBox, codec) ada di RPM Fusion. TIPACK tidak menambahkan repo pihak ketiga ini otomatis.
- Laporkan nama paket yang salah lewat issue, sertakan distro dan versinya (`cat /etc/os-release`).
</details>

<details>
<summary><b>AUR: "Running makepkg as root is not allowed".</b></summary>

Jalankan TIPACK sebagai user biasa, bukan root.
</details>

<details>
<summary><b>Docker: "permission denied while trying to connect to the Docker daemon socket".</b></summary>

User baru ditambahkan ke grup `docker`. **Logout lalu login lagi** (atau jalankan `newgrp docker` untuk sesi saat ini).
</details>

<details>
<summary><b>VS Code / Vite: "ENOSPC: System limit for number of file watchers reached".</b></summary>

Aktifkan tweak **Naikkan batas file watcher (inotify)** di menu Tweak.
</details>

<details>
<summary><b>Aplikasi Flatpak tidak muncul di menu aplikasi.</b></summary>

Logout lalu login lagi. TIPACK sudah menambahkan `XDG_DATA_DIRS`, tetapi desktop environment baru membacanya saat login.
</details>

<details>
<summary><b>Emulator Android / virt-manager lambat atau tidak jalan.</b></summary>

Cek *Info Sistem* → *KVM*. Kalau tidak aktif, aktifkan virtualisasi di BIOS. Untuk virt-manager, aktifkan juga tweak grup `libvirt`.
</details>

<details>
<summary><b>Clipboard SSH key tidak tersalin.</b></summary>

Pasang `wl-clipboard` (Wayland) atau `xclip` (X11), atau copy manual dari layar.
</details>

## Setelah instalasi

<details>
<summary><b>Cara cek semuanya terpasang dengan benar?</b></summary>

```bash
git --version
python --version     # Windows/Linux (macOS: python3)
node -v && npm -v
java -version
g++ --version
code --version
```
</details>

<details>
<summary><b>MariaDB/MySQL: password root?</b></summary>

- **Linux:** jalankan `sudo mysql_secure_installation`, atau masuk dengan `sudo mariadb`.
- **XAMPP:** default user `root` tanpa password, lewat phpMyAdmin di http://localhost/phpmyadmin.
</details>
