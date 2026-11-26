# Notulensi Pengembangan TIPACK v2.0.0

| | |
|---|---|
| **Proyek** | TIPACK · DEVSETUP IF: installer, tune-up & debloat dev tools untuk mahasiswa Teknik Informatika |
| **Periode** | 24–26 November 2026 |
| **Pemilik / maintainer** | KouMac ([@fk0u](https://github.com/fk0u)) |
| **Repo** | https://github.com/fk0u/tipack (publik, MIT) |
| **Situs** | https://tipack.kousozo.tech |
| **Rilis** | [v2.0.0](https://github.com/fk0u/tipack/releases/tag/v2.0.0), 26 November 2026 |
| **Status akhir** | Semua 15 job CI lulus (Windows x64/ARM64, macOS arm64/Intel, 9 kombinasi Linux, Termux, katalog) |

---

## 1. Latar belakang & tujuan

Teman satu kelas dan satu prodi baru membeli laptop dan baru memasang WinLibs MinGW, Git, VS Code dan Antigravity. Kebutuhan yang disampaikan:

1. Program berbasis terminal/PowerShell untuk **Windows dan macOS** yang memasang tools dan software untuk mahasiswa Teknik Informatika dan "abang IT", secara detail dan lengkap.
2. Tampilan yang **interaktif, imersif, dengan visual ASCII**: ada pilihan, tooltip, rekomendasi dan preferensi (WinRAR atau 7-Zip, WSL atau tidak, WSA atau tidak), serta **mengecek apakah aplikasi sudah terpasang** sebelum memasang.
3. Di-deploy ke server sendiri dengan halaman web: **tipack.kousozo.tech**.
4. Desain web yang lebih modern dan imersif, mengikuti referensi UI tapi dengan warna brand sendiri.
5. Halaman **katalog** semua aplikasi, dan situs **tidak patah-patah** di perangkat lemah.
6. Dukungan **Linux** untuk semua distro besar (Arch, Debian, Ubuntu, Fedora, dan lainnya).
7. Ditaruh di **GitHub publik**, commit atas nama pemilik saja, **lisensi MIT**, dan dokumentasi lengkap.
8. Memperbaiki **Windows yang stuck**, dukungan perangkat/platform/**arsitektur** yang luas, dan berguna juga untuk **laptop lama** (tune-up, tweak, debloat).
9. Android: kalau tidak bisa langsung, **sarankan Andronix**.
10. Rilis di GitHub beserta dokumentasi dan notulensi lengkap (dokumen ini).

## 2. Kronologi

| # | Tahap | Hasil |
|---|---|---|
| 1 | Versi awal | Script menu sederhana (`setup.ps1`, `setup.sh`) berbasis daftar nomor + README |
| 2 | Versi 2 TUI | Navigasi panah, checklist, panel tooltip, wizard preferensi, profil, keranjang, deteksi terpasang, progress & log, ekstensi VS Code, Git/SSH, tweak |
| 3 | Deploy situs | Situs statis di nginx + Let's Encrypt; bootstrap `install.ps1` / `install.sh` untuk perintah satu baris |
| 4 | Redesign web | Struktur dari referensi UI (hero + kolase, marquee, akordeon, CTA), warna diganti gradasi magenta → violet → biru dari banner ASCII |
| 5 | Katalog & optimisasi | `katalog.html` dari `catalog.json` yang dibuat otomatis dari ketiga script; `perf.js` (pause di luar layar, mode lite, probe FPS) |
| 6 | Linux | `linux/setup.sh` dirakit dari bagian khusus Linux + mesin TUI macOS; uji 6 distro di container |
| 7 | GitHub & dokumentasi | Repo publik `fk0u/tipack`, commit hanya atas nama pemilik, lisensi MIT, `docs/` lengkap |
| 8 | Perbaikan besar | Akar masalah Windows stuck ditemukan lewat CI; Tune-Up, Debloat, Kelola Startup; ARM64, Termux, immutable, ChromeOS, Raspberry Pi; GitHub Actions 15 job |
| 9 | Android | Saran Andronix/proot-distro di Termux; deteksi Linux di dalam proot |
| 10 | Rilis | v2.0.0 dengan lampiran installer + SHA256SUMS, CHANGELOG, notulensi |

## 3. Keputusan teknis

| Keputusan | Alasan |
|---|---|
| Satu file installer per OS, tanpa dependensi | Harus jalan di laptop yang baru diinstall: cukup PowerShell bawaan atau bash bawaan |
| Package manager resmi (winget, Homebrew, apt/dnf/pacman/zypper/apk, Flathub) | Aman, bisa di-update, tanpa file `.exe` dari situs acak |
| macOS kompatibel **bash 3.2** | Versi bawaan macOS; bash 4+ tidak tersedia di Mac baru |
| `linux/setup.sh` **dirakit** dari mesin TUI macOS | Satu sumber untuk widget, jadi perbaikan TUI berlaku di dua OS sekaligus |
| Urutan metode Linux: repo distro → AUR → script resmi → Flatpak → manual; item tanpa metode disembunyikan | Integrasi terbaik dulu; pengguna tidak pernah melihat pilihan yang pasti gagal |
| Paket alternatif `a/b/c` | Versi paket berbeda antar rilis distro (contoh: Debian 12 belum punya JDK 21) |
| Katalog web & `docs/katalog.md` **dibuat otomatis** dari script | Situs dan dokumentasi tidak pernah berbeda dengan isi installer |
| WSA diarahkan ke Android Studio Emulator / BlueStacks | WSA dihentikan Microsoft pada 5 Maret 2025 |
| Debloat Windows selalu didahului restore point; Startup memakai `StartupApproved` | Semua perubahan bisa dibatalkan |
| Tune-Up menampilkan ukuran sebelum menghapus; Recycle Bin/Trash tidak dicentang otomatis | Pengguna tahu persis apa yang dihapus; penghapusan permanen harus dipilih sadar |
| Uji di **GitHub Actions**, bukan server produksi | Uji di server sempat membuat disk hampir penuh (96%); CI menyediakan Windows/macOS/ARM sungguhan secara gratis |
| Antrean tombol `TIPACK_KEYS` | TUI bisa diuji otomatis sampai ke setiap menu |
| Android lewat **Andronix** | Termux murni hanya punya paket CLI terbatas; Andronix memberi Linux utuh sehingga katalog lengkap tersedia |
| Commit hanya atas nama pemilik, tanpa `Co-Authored-By` | Permintaan pemilik |

## 4. Masalah yang ditemukan & akar masalahnya

| # | Gejala | Akar masalah | Perbaikan | Ditemukan lewat |
|---|---|---|---|---|
| 1 | **Windows stuck / error berulang sejak awal** | `$C = @{}; foreach ($c in $Catalog) { $C[$c.Key] = $c }`: PowerShell **tidak membedakan huruf besar-kecil**, jadi `$C` dan `$c` adalah variabel yang sama dan katalog tertimpa | `$C` → `$Apps`; semua tabrakan nama dipindai | CI Windows (128× error *CannotIndex*) |
| 2 | Tune-Up Windows akan menjalankan aksi yang salah | Tabrakan `$T` / `$t` di fungsi yang sama | `$T` → `$TuneList` | Pemindaian tabrakan nama |
| 3 | Berpotensi menggantung di layar pembuka | `winget source update ... *> $null` bisa menanyakan persetujuan sumber secara tersembunyi | Semua program luar memakai stdin kosong + batas waktu + taskkill pohon proses | Audit kode |
| 4 | Berpotensi menggantung saat memindai | Stub `wsl.exe` di Windows tanpa WSL menunggu "press any key" | WSL dideteksi lewat registry & file | Audit kode |
| 5 | Self-test PowerShell 7 gagal | `Clear-Host` melempar error tanpa jendela konsol | `Clear-Scr` (VT / `[Console]::Clear` / abaikan) | CI Windows |
| 6 | `-Install` ditolak di CI | Pengaman "input keyboard tidak tersedia" juga berlaku di mode tanpa menu | Pengaman hanya untuk mode interaktif | CI Windows |
| 7 | Install Termux gagal | Folder script tidak bisa ditulisi, jadi redirect ke log gagal dan bash tidak menjalankan perintahnya | Log pindah ke folder temp (ketiga OS) | CI Termux |
| 8 | Beberapa paket Linux gagal | Nama paket berbeda/berubah di rilis distro terbaru | Nama diperbaiki + paket alternatif | Uji 6 distro (server, lalu CI) |
| 9 | Katalog web: Linux 99 aplikasi, seharusnya 105 | `build-catalog.py` belum menyesuaikan kolom Termux baru | Parser diperbarui | Pengecekan angka sebelum rilis |
| 10 | Situs selalu mode lite | Ambang "≤ 4 core" terlalu agresif (perangkat 16 GB RAM ikut kena) | Lite langsung hanya untuk RAM ≤ 2 GB / ≤ 2 core / hemat data / reduce motion; lainnya lewat probe FPS | Uji di browser |
| 11 | Disk server 96% | Image Docker untuk uji distro | Uji dipindah ke GitHub Actions; image dibersihkan pemilik server | Pemantauan `df` |
| 12 | Judul hero patah baris, kartu profil terlalu sempit, overflow di HP | CSS ukuran font, `flex`, `min-width` grid | Diperbaiki & dicek di 1440 px dan 375 px | Uji tampilan |

## 5. Hasil pengujian

### GitHub Actions (run terakhir sebelum rilis: semua lulus)

| Job | Mesin | Yang diverifikasi |
|---|---|---|
| Windows x64 | `windows-2025` | Parser PS, self-test PS 5.1 & 7, navigasi semua menu, **install SumatraPDF via winget (5 detik, berhasil)** |
| Windows ARM64 | `windows-11-arm` | Sama; katalog otomatis 125 aplikasi; **install SumatraPDF berhasil (4 detik)** |
| macOS arm64 / Intel | `macos-15`, `macos-15-intel` | `bash -n` (3.2), self-test, navigasi, install `lazygit` via Homebrew |
| Linux x64 | Ubuntu 24.04, Debian 12, Fedora, Arch, openSUSE Tumbleweed, Alpine | Validasi nama paket, self-test, navigasi, install `git, python, build, nmap` |
| Linux ARM64 | Ubuntu 24.04, Fedora, Debian 12 | Sama |
| Termux | `termux-docker` x86_64 | Self-test (32 aplikasi tersedia), install `git, python` |
| Katalog | Ubuntu | `catalog.json` & `docs/katalog.md` sinkron |

### Uji manual
- TUI macOS dijalankan dengan antrean tombol di Mac pengembang (bash 3.2): menu Info, Tune-Up (menemukan 7,1 GB cache), Debloat, Status, Wizard dan Profil berjalan tanpa error.
- Situs dicek di desktop 1440 px dan HP 375 px; konsol browser bersih; probe FPS mengukur 56 fps di perangkat uji.
- Semua file di situs diverifikasi identik dengan repo lewat checksum di server.

## 6. Yang belum diuji / risiko yang diketahui

| Area | Status | Mitigasi |
|---|---|---|
| **Aksi** Tune-Up & Debloat (yang benar-benar menghapus/mengubah sistem) | Hanya layar menunya yang diuji di CI | Restore point (Windows), Trash (macOS), ukuran ditampilkan dulu; uji di satu laptop sebelum disebar |
| Android via Andronix | Deteksi proot belum diuji di HP sungguhan | Kalau tidak terdeteksi, script tetap jalan sebagai Linux biasa |
| Distro immutable (Silverblue, SteamOS) | Belum ada di CI | Hanya memakai Flatpak & script di home, tanpa mengubah sistem |
| ID winget yang berubah di masa depan | Langkah validasi ID di CI berjalan setiap push | Item gagal tampil jelas di ringkasan & tetap di keranjang |
| Tampilan di Windows console lama (conhost tanpa VT) | Jalur fallback `Write-Host` ada, belum diuji visual | Disarankan Windows Terminal |

## 7. Tindak lanjut

- [ ] Uji Tune-Up & Debloat di satu laptop Windows lama dan satu laptop Linux sebelum dibagikan ke kelas.
- [ ] Uji Android lewat Andronix (Ubuntu) di satu HP.
- [ ] Pertimbangkan uji Fedora Silverblue di VM.
- [ ] Pantau hasil langkah *Validasi semua ID winget* di CI; perbarui ID yang berubah.
- [ ] Opsional: bersihkan Docker build cache di server (sekitar 4 GB) bila disk kembali menipis.

## 8. Perintah penting

```powershell
irm https://tipack.kousozo.tech/install.ps1 | iex                 # Windows
setup.ps1 -Install git,vscode,7zip                                # pasang tertentu tanpa menu
setup.ps1 -SelfTest                                               # cek tanpa memasang
```
```bash
curl -fsSL https://tipack.kousozo.tech/install.sh | bash          # macOS / Linux
bash setup.sh --install git,vscode,python
bash linux/src/build.sh                                           # rakit linux/setup.sh
python3 web/build-catalog.py                                      # regenerasi katalog web & docs
TIPACK_KEYS="Up,Up,Enter,Esc" bash macos/setup.sh                 # uji TUI otomatis
```
