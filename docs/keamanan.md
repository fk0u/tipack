# Keamanan

Menjalankan script dari internet adalah keputusan yang patut dipikirkan. Dokumen ini menjelaskan dengan jujur apa yang dilakukan TIPACK, supaya kamu bisa memutuskan sendiri.

## Prinsip

1. **Hanya sumber resmi.** Paket diambil dari winget (sumber `winget`), Homebrew, repo resmi distro, AUR, Flathub, atau installer resmi vendor. Tidak ada file `.exe`/`.dmg` dari situs acak dan tidak ada mirror pihak ketiga.
2. **Tidak ada yang tersembunyi.** Semua kode ada di repo ini dalam bentuk teks biasa (PowerShell & bash), tanpa binary dan tanpa obfuscation.
3. **Tidak mengumpulkan data.** TIPACK tidak mengirim telemetri, analytics, atau data apa pun ke server mana pun. Satu-satunya koneksi keluar adalah untuk mengunduh paket dan cek koneksi ke `github.com`.
4. **Kamu yang memutuskan.** Tidak ada yang dipasang tanpa dicentang dan dikonfirmasi di layar keranjang.

## Hak akses yang dipakai

| OS | Hak akses | Dipakai untuk |
|---|---|---|
| Windows | Administrator (opsional, disarankan) | winget installer tingkat sistem, WSL, Windows Optional Features, tweak di HKLM (Long Paths, Developer Mode), service ssh-agent |
| macOS | `sudo` (password Mac) | Instalasi Homebrew dan cask yang memasang paket `.pkg` |
| Linux | `sudo` | Package manager, repo VS Code/Chrome, service (mariadb, docker), `/etc/sysctl.d` (inotify), menambah user ke grup |

Di macOS/Linux, sesi sudo dijaga tetap hidup **hanya selama proses instalasi**, dan proses penjaga itu dihentikan begitu instalasi selesai atau script keluar.

## Perubahan yang dibuat di sistem

Selain memasang aplikasi pilihanmu, TIPACK bisa mengubah hal berikut. Semua perubahan yang bukan bagian langsung dari instalasi harus dipilih manual di menu Tweak atau Git:

- **File konfigurasi shell** (`~/.zshrc`, `~/.bashrc`, `~/.zprofile`): baris PATH, alias `python=python3`, inisialisasi Oh My Zsh/Starship/zoxide. Baris hanya ditambahkan kalau belum ada.
- **Konfigurasi Git global**, hanya lewat menu *Setup Git*.
- **SSH key** baru di `~/.ssh/id_ed25519`, hanya kalau belum ada dan kamu menyetujuinya. Key lama tidak pernah ditimpa.
- **Repo paket tambahan (Linux):** repo Microsoft untuk VS Code (`/etc/apt/sources.list.d/vscode.list`, `/etc/yum.repos.d/vscode.repo`, `/etc/zypp/repos.d/vscode.repo`), hanya kalau VS Code dipilih.
- **Tweak OS:** registry HKCU/HKLM (Windows), `defaults write` (macOS), `gsettings` dan `/etc/sysctl.d/60-devsetup-inotify.conf` (Linux), hanya yang dicentang.

## Script pihak ketiga yang mungkin dijalankan

Beberapa tool resmi hanya menyediakan installer berbentuk script. Script ini dijalankan **hanya kalau aplikasinya dipilih**:

| Tool | URL |
|---|---|
| Homebrew | `raw.githubusercontent.com/Homebrew/install/HEAD/install.sh` |
| Oh My Zsh | `raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh` |
| Docker (Debian/Fedora) | `get.docker.com` |
| rustup | `sh.rustup.rs` |
| uv | `astral.sh/uv/install.sh` |
| Bun | `bun.sh/install` |
| fnm | `fnm.vercel.app/install` |
| Ollama | `ollama.com/install.sh` |
| Starship | `starship.rs/install.sh` |

## Cara mengaudit sebelum menjalankan

```bash
# macOS / Linux
curl -fsSL https://tipack.kousozo.tech/install.sh            # baca bootstrap (±25 baris)
curl -fsSL https://tipack.kousozo.tech/linux/setup.sh | less  # baca installer
```

```powershell
# Windows
irm https://tipack.kousozo.tech/install.ps1                   # baca bootstrap
irm https://tipack.kousozo.tech/windows/setup.ps1             # baca installer
```

File di situs identik dengan file di repo GitHub. Kalau lebih nyaman, clone repo, baca, lalu jalankan dari sana (lihat [instalasi.md](instalasi.md#dari-repo-git)).

## Tool keamanan di katalog

Katalog berisi tool seperti Nmap, Wireshark, Burp Suite dan Kali Linux (WSL) untuk keperluan **belajar** di matkul Jaringan Komputer dan Keamanan Informasi. Gunakan hanya pada jaringan dan sistem milik sendiri atau yang sudah memberi izin tertulis. Memindai atau menyadap jaringan orang lain tanpa izin melanggar hukum (di Indonesia, antara lain UU ITE).

## Melaporkan celah keamanan

Kalau menemukan masalah keamanan di TIPACK (misalnya ID paket yang mengarah ke paket berbahaya), **jangan** buka issue publik. Hubungi pemilik repo lewat profil GitHub [@fk0u](https://github.com/fk0u).
