# Aplikasi GUI TIPACK

Aplikasi desktop untuk yang lebih suka klik daripada mengetik perintah. Dibangun dengan [Tauri 2](https://tauri.app) sehingga ukurannya kecil (beberapa MB, bukan ratusan MB seperti aplikasi Electron).

## Unduh

Ambil installer dari [halaman rilis terbaru](https://github.com/fk0u/tipack/releases/latest):

| OS | File | Catatan |
|---|---|---|
| Windows x64 / ARM64 | `tipack-gui_*_x64_en-US.msi` atau `*-setup.exe` | Minta izin Administrator saat dibuka (dibutuhkan winget, WSL dan Doctor) |
| macOS (Apple Silicon & Intel) | `tipack-gui_*_universal.dmg` | Satu file untuk kedua jenis chip |
| Linux x64 / ARM64 | `.deb` (Debian/Ubuntu), `.rpm` (Fedora/openSUSE), `.AppImage` (semua distro) | Butuh `zenity` atau `kdialog` untuk dialog password |

> [!NOTE]
> **Peringatan saat pertama dibuka.**
> - **Windows:** selama installer belum ditandatangani lewat SignPath, SmartScreen bisa menampilkan "Windows protected your PC". Klik **More info → Run anyway**.
> - **macOS:** tanpa notarisasi Apple, buka lewat **klik kanan → Open**, atau izinkan di System Settings → Privacy & Security.

## Fitur

| Menu | Isi |
|---|---|
| **Pasang aplikasi** | Katalog lengkap dengan logo, kategori dan pencarian. Aplikasi yang sudah terpasang ditandai *✓ ada*. Centang aplikasi lalu tekan **Pasang**: progres tiap aplikasi tampil langsung, dan ada tombol **Hentikan**. |
| **Profil** | 14 profil (Starter IF, Web, Data/AI, Umum, Gamer, Kreator, dan lainnya). Klik untuk mencentang isinya. |
| **Konfigurasi** | Simpan pilihan ke `tipack.json`, atau buka `tipack.json` dari dosen/asisten lab. |
| **Doctor** | Periksa masalah lalu perbaiki yang dicentang. |
| **Laporkan masalah** | Buat laporan yang sudah disensor dan buka form GitHub Issue yang sudah terisi. |
| **Tune-Up & Debloat** | Menampilkan perintah untuk menjalankan fitur ini di mode terminal, karena tiap item punya detail (ukuran, status, butuh admin) yang dirancang untuk TUI. |

## Cara kerja

```
UI (HTML/JS)  ──invoke──▶  Rust (Tauri)  ──spawn──▶  setup.ps1 / setup.sh --json
      ▲                                                     │
      └───────── event "engine-event" ◀── baris "@@TIPACK {...}" di stdout
```

- GUI **tidak punya logika instalasi sendiri**. Ia menjalankan mesin yang sama dengan versi terminal (`windows/setup.ps1`, `macos/setup.sh`, `linux/setup.sh`), yang dibundel sebagai resource.
- Mesin dijalankan dengan mode `--json` / `-Json`. Setiap event (`sys`, `scan`, `start`, `done`, `summary`, `doctor`, `fixed`, `report`) dicetak sebagai satu baris `@@TIPACK {json}`, lalu diteruskan Rust ke UI.
- Password admin:
  - **Windows:** aplikasi berjalan sebagai Administrator lewat manifest.
  - **macOS/Linux:** dialog password grafis (`SUDO_ASKPASS` dengan `osascript` / `zenity` / `kdialog`), lalu mesin memakai `sudo -A`.
- Karena mesinnya sama, semua yang lulus uji CI di versi terminal juga berlaku untuk GUI.

## Build sendiri

Butuh Node.js 20+ dan Rust stable. Di Linux juga butuh paket WebKitGTK (lihat `.github/workflows/gui.yml`).

```bash
cd gui
npm install
npm run dev      # mode pengembangan
npm run build    # installer di gui/src-tauri/target/release/bundle/
```

`npm run prepare-ui` menyalin `web/catalog.json`, `web/icons/` dan logo ke `gui/ui/`, jadi GUI selalu memakai katalog yang sama dengan website dan mesin.

## Build otomatis & tanda tangan digital

Workflow `.github/workflows/gui.yml` berjalan setiap tag `v*` (atau manual lewat *Run workflow*). Ia membangun installer untuk Windows x64/ARM64, macOS universal dan Linux x64/ARM64, lalu melampirkannya ke rilis.

Penandatanganan Windows lewat **SignPath** aktif otomatis setelah variabel repo diisi. Lihat [signpath.md](signpath.md).
