# Arsitektur & Cara Menambah Aplikasi

- [Gambaran besar](#gambaran-besar)
- [Struktur repo](#struktur-repo)
- [Mesin TUI](#mesin-tui)
- [Format katalog](#format-katalog)
- [Menambah aplikasi](#menambah-aplikasi)
- [Menambah profil atau pertanyaan wizard](#menambah-profil-atau-pertanyaan-wizard)
- [Menambah package manager Linux](#menambah-package-manager-linux)
- [Build & pengujian](#build--pengujian)
- [Aturan gaya](#aturan-gaya)

## Gambaran besar

```
 Pengguna
   │  irm .../install.ps1 | iex            curl .../install.sh | bash
   ▼                                        ▼
 web/install.ps1 ──► windows/setup.ps1     web/install.sh ──┬─► macos/setup.sh
                      (PowerShell 5.1)                       └─► linux/setup.sh
                                                                   ▲
                                                linux/src/build.sh │ rakit
                                     linux-parts.sh + mesin TUI dari macos/setup.sh

 Katalog di ketiga script ──► web/build-catalog.py ──► web/catalog.json (dipakai web/katalog.html)
                                                  └──► docs/katalog.md
```

Setiap installer adalah **satu file mandiri** tanpa dependensi (cukup PowerShell bawaan atau bash), supaya bisa diunduh dan dijalankan di laptop yang benar-benar baru.

## Struktur repo

| Path | Isi |
|---|---|
| `windows/setup.ps1` | Installer Windows: katalog, widget TUI (`Select-List` + `Paint`), deteksi (`Scan-Installed`), instalasi (`Install-Cart`) dan semua menu. **UTF-8 dengan BOM.** |
| `windows/JALANKAN.bat` | Launcher: membuka Windows Terminal kalau ada dan melewati ExecutionPolicy. CRLF. |
| `macos/setup.sh` | Installer macOS **dan** sumber mesin TUI bash. Kompatibel **bash 3.2**. |
| `linux/src/linux-parts.sh` | Bagian khusus Linux: katalog, deteksi distro, resolver metode, installer per package manager, menu Linux. |
| `linux/src/build.sh` | Merakit `linux/setup.sh`. |
| `linux/setup.sh` | **Hasil rakitan, jangan diedit langsung.** |
| `linux/src/test-distro.sh` | Uji di container: deteksi, validasi nama paket, install sungguhan. |
| `web/` | Situs: `index.html`, `katalog.html`, `perf.js`, bootstrap `install.sh`/`install.ps1`, `build-catalog.py`, `catalog.json`. Lihat [website.md](website.md). |

## Mesin TUI

Ketiga installer memakai pola yang sama:

1. **Katalog** sebagai teks berformat `|` di dalam script, di-parse saat start ke array paralel (`K_KEY`, `K_NAME`, ...) atau objek PowerShell.
2. **Widget daftar generik**: `Select-List` (PowerShell) atau `select_list` (bash) dengan mode `single`, `radio` dan `multi`. Item didefinisikan lewat `MkItem` / `opt_add`: label, tooltip, nilai, badge, tercentang, terkunci, rekomendasi, pemisah.
3. **Render satu layar penuh per tombol**: kursor ke kiri-atas, baris ditulis ulang, sisa layar dibersihkan. Tidak memakai `clear` setiap frame, jadi tidak berkedip.
   - PowerShell: markup warna dalam teks, misalnya `"{Cyan}teks {Gray}teks"`, di-parse oleh `Paint`.
   - bash: escape ANSI dikumpulkan ke satu buffer lalu dicetak sekali; auto-wrap terminal dimatikan (`\e[?7l`) supaya baris panjang terpotong, bukan turun baris.
4. **Keranjang**: `OrderedDictionary` (PowerShell) atau array `CART[i]=1` (bash). `Sync-Cart` / `sync_cart` menyelaraskan pilihan dari wizard, profil dan kategori.
5. **Instalasi dengan spinner**: proses dijalankan di background dengan output ke log, lalu loop spinner dan timer berjalan sampai proses selesai.

### Bagaimana `linux/setup.sh` dirakit

`build.sh` mengambil `macos/setup.sh` dari fungsi `log()` sampai sebelum `install_ohmyzsh()`. Bagian ini berisi utilitas, `opt_*`, `read_key`, `select_list`, `spin`, `show_banner`, wizard, profil, kategori, status dan keranjang. Blok itu disisipkan di penanda `#@@MAC_ENGINE@@` dalam `linux-parts.sh`.

Fungsi khusus Linux (`cat_opt`, `get_sysinfo`, `scan_installed`, `boot`, `install_cart`, `setup_git`, dan lainnya) didefinisikan **setelah** blok itu, jadi otomatis menimpa versi macOS. Hasilnya, perbaikan widget di macOS ikut ke Linux setelah rebuild.

## Format katalog

### Windows (`$CatalogRaw` di `windows/setup.ps1`)

```
key|Kategori|ID|Nama|Rek|Tooltip
7zip|Arsip & File|7zip.7zip|7-Zip|1|Gratis dan open source. ...
```

| Kolom | Isi |
|---|---|
| `key` | ID unik huruf kecil (`a-z0-9-`). Dipakai di profil dan wizard. Usahakan sama dengan key di OS lain untuk aplikasi yang sama. |
| `Kategori` | Salah satu kategori yang sudah ada (urutan kategori mengikuti kemunculan pertama). |
| `ID` | winget ID (cek dengan `winget search nama`), atau `wsl:core` / `wsl:<Distro>`, `feat:<FeatureName>`, `info:<url>`. |
| `Rek` | `1` = rekomendasi, `0` = biasa. |
| `Tooltip` | Penjelasan dan rekomendasi untuk pemula. **Tanpa** karakter `\|`, `{` dan `}`. |

Deteksi tambahan untuk aplikasi yang mungkin diinstall manual: `$CmdProbe` (nama perintah) dan `$PathProbe` (path file).

### macOS (`CATALOG_RAW` di `macos/setup.sh`)

```
key|Kategori|tipe|id|Nama|Rek|deteksi|Tooltip
vscode|Editor Kode|cask|visual-studio-code|Visual Studio Code|1|Visual Studio Code|Editor paling populer...
```

| Kolom | Isi |
|---|---|
| `tipe` | `formula`, `cask`, `info` (id = url) atau `custom` (fungsi khusus, saat ini `ohmyzsh`). |
| `id` | Nama formula/cask (`brew search`). Boleh berisi tap (`hashicorp/tap/terraform`) atau beberapa formula dipisah spasi. |
| `deteksi` | Nama `.app` di `/Applications` (tanpa `.app`), `cmd:perintah`, `dir:path`, atau kosong. |

Key **tanpa tanda minus**, karena dipakai sebagai nama variabel bash (`IDX_key`).

### Linux (`CATALOG_RAW` di `linux/src/linux-parts.sh`)

```
key|Kategori|Nama|Rek|deteksi|apt|dnf|pacman|zypper|apk|flatpak|universal|Tooltip
jdk|Bahasa & Runtime|Java JDK 21 (OpenJDK)|1|cmd:javac|openjdk-21-jdk|java-21-openjdk-devel|jdk21-openjdk|java-21-openjdk-devel|openjdk21|-|-|JDK LTS...
```

| Kolom | Nilai yang valid |
|---|---|
| `apt` … `apk` | `-` (tidak ada di repo), `pkg1 pkg2` (paket native), `a/b` (alternatif: pakai yang pertama tersedia), `aur:pkg` (hanya kolom pacman), `sh:fungsi` (memanggil `inst_fungsi`) |
| `flatpak` | ID Flathub atau `-` |
| `universal` | `sh:fungsi`, `info:url` atau `-` |
| `deteksi` | `cmd:perintah`, `dir:path` atau kosong |

Urutan pemilihan metode: kolom distro → flatpak → universal. Kalau semuanya `-`, aplikasi disembunyikan di distro itu.

## Menambah aplikasi

Contoh: menambah **Insomnia** (API client).

**1. Cari ID paketnya:**

```bash
winget search insomnia            # Windows → Insomnia.Insomnia
brew search insomnia              # macOS   → cask insomnia
flatpak search insomnia           # Linux   → rest.insomnia.Insomnia
```

**2. Tambahkan satu baris di masing-masing katalog**, di dekat aplikasi sekategori:

```text
# windows/setup.ps1 ($CatalogRaw)
insomnia|Git & API|Insomnia.Insomnia|Insomnia|0|API client ringan, alternatif Postman. Mendukung REST, GraphQL dan gRPC.

# macos/setup.sh (CATALOG_RAW)
insomnia|Git & API|cask|insomnia|Insomnia|0|Insomnia|API client ringan, alternatif Postman. Mendukung REST, GraphQL dan gRPC.

# linux/src/linux-parts.sh (CATALOG_RAW)
insomnia|Git & API|Insomnia|0||-|-|aur:insomnia-bin|-|-|rest.insomnia.Insomnia|-|API client ringan, alternatif Postman. Mendukung REST, GraphQL dan gRPC.
```

**3. (Opsional)** Masukkan `insomnia` ke daftar pertanyaan wizard yang relevan (`$Wizard` / `WIZ`) atau ke profil.

**4. Build & cek:**

```bash
bash linux/src/build.sh            # rakit linux/setup.sh + cek syntax
bash -n macos/setup.sh
python3 web/build-catalog.py       # perbarui web/catalog.json & docs/katalog.md
```

## Menambah profil atau pertanyaan wizard

- **Profil Windows:** tambah entri `@{ K = 'kunci'; N = 'Nama'; T = 'Deskripsi'; L = 'key1,key2' }` di `$Profiles`.
- **Profil macOS/Linux:** tambah `"kunci|Nama|Deskripsi|key1 key2"` di `PROFILES`.
- **Wizard Windows:** `@{ Q = 'Pertanyaan?'; M = $true; L = 'key1,key2'; T = 'Penjelasan' }`. `M = $false` berarti pilih satu. Placeholder `__RAM__` dan `__VIRT__` diganti otomatis.
- **Wizard macOS/Linux:** `"Pertanyaan?|m|key1 key2|Penjelasan"`. Pakai `s` untuk pilih satu.

Gunakan key profil yang sama di ketiga OS supaya `--preset` konsisten, lalu jalankan `build-catalog.py` (profil ikut tampil di katalog web dan docs).

## Menambah package manager Linux

Contoh: `xbps` (Void Linux).

1. **`detect_distro`**: tambahkan pola `*" void "*) PM=xbps ;;` dan fallback `xbps-install:xbps`.
2. **Katalog**: tambah kolom baru setelah `apk`. Update `read -r` di loop parsing (`papk`, lalu `pxbps`) dan semua baris katalog (gunakan `-` kalau tidak tahu).
3. **`resolve_methods`**: `xbps) v=${K_XBPS[$i]} ;;`
4. **`pm_refresh`, `pm_install`, `pm_upgrade`**: perintah `xbps-install -S`, `xbps-install -y`, `xbps-install -Su`.
5. **`scan_installed`**: daftar paket terpasang (`xbps-query -l | awk '{print $2}' | sed 's/-[^-]*$//'`).
6. **`test-distro.sh`**: tambah cara cek paket ada di repo, lalu uji di container `ghcr.io/void-linux/void-glibc`.
7. **`web/build-catalog.py`**: tambahkan nama PM di parsing Linux.

## Build & pengujian

| Perintah | Fungsi |
|---|---|
| `bash linux/src/build.sh` | Rakit `linux/setup.sh` dan `bash -n` |
| `bash -n macos/setup.sh` | Cek syntax macOS (pakai `/bin/bash` 3.2 di Mac untuk menguji kompatibilitas) |
| `python3 web/build-catalog.py` | Regenerasi `web/catalog.json` dan `docs/katalog.md` |
| `docker run --rm -v "$PWD/linux:/t" <image> bash /t/src/test-distro.sh` | Uji Linux di container (salin `src/test-distro.sh` ke samping `setup.sh`). Image yang dipakai: `ubuntu:24.04`, `debian:12`, `fedora:latest`, `archlinux:latest`, `opensuse/tumbleweed`, `alpine:latest` (Alpine: `apk add bash` dulu) |

`test-distro.sh` mencetak:
- `METODE`: jumlah item per metode.
- `PAKET-TIDAK-ADA`: nama paket native yang **tidak ditemukan** di repo distro. Ini yang harus diperbaiki.
- `INSTALL`: hasil memasang `git`, `clipack`, `build` dan `python` sungguhan.
- `TERDETEKSI-TERPASANG`: hasil `scan_installed` setelahnya.

Untuk Windows belum ada uji otomatis. Uji manual di VM/laptop Windows dan perhatikan ringkasan instalasi. Item dengan ID salah akan muncul sebagai `GAGAL: paket tidak ditemukan di winget`.

## Uji otomatis (GitHub Actions)

`.github/workflows/test.yml` berjalan setiap push dan pull request:

| Job | Mesin | Isi |
|---|---|---|
| Windows | `windows-2025` (x64), `windows-11-arm` (ARM64) | Parser PowerShell, `-SelfTest` di PS 5.1 & 7, navigasi semua menu dengan antrean tombol, `-Install 7zip` sungguhan, validasi semua ID winget |
| macOS | `macos-15` (Apple Silicon), `macos-15-intel` | `bash -n` dengan bash 3.2, `--self-test`, navigasi menu, `--install lazygit` |
| Linux | Container Ubuntu, Debian, Fedora, Arch, openSUSE, Alpine di runner x64 + Ubuntu/Fedora/Debian di runner ARM64 | `build.sh` harus sinkron, `test-distro.sh`, self-test, navigasi, `--install git,python,build,nmap` |
| Termux | `termux/termux-docker` | self-test & install |
| Katalog | — | `catalog.json` dan `docs/katalog.md` harus sinkron |

### Antrean tombol (`TIPACK_KEYS`)

Semua installer membaca tombol dari variabel `TIPACK_KEYS` kalau variabel itu ada, sehingga TUI bisa dikendalikan tanpa keyboard:

```bash
TIPACK_KEYS="Up,Up,Enter,Esc" bash macos/setup.sh
```

Nama tombol: `Up Down Enter Esc Space PgUp PgDn Home End Back`, atau satu huruf (`a`, `n`, `r`, `q`). Dalam mode ini:
- Semua pertanyaan teks memakai jawaban default.
- Browser tidak dibuka.
- Saat antrean habis, script mencetak `SELFTEST-TOMBOL-SELESAI` dan keluar dengan kode 0. Error apa pun akan menghasilkan kode selain 0.

## Aturan gaya

- **Bahasa UI:** Bahasa Indonesia yang santai tapi jelas. Tooltip menjelaskan *fungsinya* dan *kapan dipilih*.
- **Tooltip** hanya karakter ASCII (padding kotak info di bash menghitung byte) dan tanpa `|`. Di PowerShell juga tanpa `{` `}` karena dipakai sebagai markup warna.
- **macOS:** jangan pakai fitur bash 4+ (associative array, `${var,,}`, `mapfile`, `read -t` desimal).
- **PowerShell:** target 5.1. Jangan pakai `?.`, `??`, operator ternary, atau `-Parallel`. Simpan dengan BOM.
- **Jangan menambah dependensi** ke installer. Semua harus jalan di OS yang baru diinstall.
- **Rekomendasi (`Rek=1`)** hanya untuk aplikasi yang memang dipakai sebagian besar mahasiswa IF.
