# Website tipack.kousozo.tech

Situs statis tanpa build step dan tanpa framework. Isinya HTML, CSS dan JavaScript murni di folder `web/`.

## Halaman & file

| File | URL | Isi |
|---|---|---|
| `index.html` | `/` | Landing page: hero dengan perintah install (Windows/macOS/Linux, OS terdeteksi otomatis), fitur, profil, isi katalog, cara install, catatan penting |
| `katalog.html` | `/katalog` | Katalog semua aplikasi: pencarian (`/` untuk fokus), filter OS/kategori/profil/rekomendasi, urutan per kategori atau A-Z, detail dengan perintah install per OS dan distro |
| `catalog.json` | `/catalog.json` | Data katalog (dibuat otomatis) |
| `perf.js` | `/perf.js` | Sistem optimisasi animasi |
| `install.sh` | `/install.sh` | Bootstrap macOS & Linux |
| `install.ps1` | `/install.ps1` | Bootstrap Windows |
| `build-catalog.py` | — | Generator `catalog.json` & `docs/katalog.md` (tidak di-deploy) |

Script installer di-deploy ke `/windows/`, `/macos/` dan `/linux/`.

Filter di katalog tersimpan di URL (contoh: `/katalog?os=linux&cat=IDE&rec=1`), dan `#key` langsung membuka detail aplikasi (contoh: `/katalog#vscode`), jadi tautan bisa dibagikan.

## Sistem optimisasi (`perf.js`)

Supaya animasi tidak patah-patah di laptop kentang maupun HP:

| Mekanisme | Cara kerja |
|---|---|
| **Pause di luar layar** | Elemen bertanda `data-anim` diamati `IntersectionObserver`. Saat tidak terlihat, kelas `anim-off` menghentikan semua animasi CSS di dalamnya, dan loop JS (`PERF.loop`, terminal demo, spinner) berhenti. |
| **Pause saat tab tidak aktif** | `visibilitychange` → kelas `tab-hidden` di `<html>`. |
| **Mode lite otomatis** | Aktif kalau: mode hemat data, RAM ≤ 2 GB, CPU ≤ 2 thread, atau pengaturan OS *reduce motion*. |
| **Probe FPS** | Untuk device lain, 95 frame setelah halaman dimuat diukur. Kalau lebih dari 30 frame lebih lambat dari ~35 fps (18 frame untuk device dengan RAM ≤ 4 GB atau ≤ 4 thread), halaman pindah ke lite. |
| **Override manual** | Tombol **Auto / Lite / Full** di footer, atau `?perf=lite`, `?perf=full`, `?perf=auto`. Disimpan di `localStorage`. |
| **`PERF.raf`** | Throttle `pointermove` (cursor glow, efek tilt) ke satu kali per frame. |

Mode **lite** (`html.perf-lite`) mematikan:
- Kolase kartu yang bergulir, orb latar, cincin orbit, scanline pil, badge yang berputar, kubus 3D (jadi statis), cursor glow, overlay noise, efek tilt
- `backdrop-filter` di navigasi

Selain itu, reveal dibuat lebih pendek dan marquee diperlambat.

Optimisasi yang selalu aktif:
- Orb latar memakai `radial-gradient`, bukan `filter: blur()` besar.
- Orbit ikon memakai `transform` dengan ukuran yang di-cache lewat `ResizeObserver`, tanpa membaca layout setiap frame.
- `content-visibility: auto` untuk setiap section dan kartu katalog.
- `contain: layout paint` untuk area animasi.
- `will-change` hanya untuk elemen yang terus bergerak.

## Build katalog

```bash
python3 web/build-catalog.py
```

Script ini membaca katalog dan profil dari `windows/setup.ps1`, `macos/setup.sh` dan `linux/src/linux-parts.sh`, menggabungkan aplikasi berdasarkan `key`, lalu menulis:
- `web/catalog.json`: dipakai `katalog.html`.
- `docs/katalog.md`: tabel dokumentasi.

Jalankan setiap kali katalog di salah satu script berubah.

## Preview lokal

```bash
python3 -m http.server 8787 --directory web
# buka http://localhost:8787  dan  http://localhost:8787/katalog.html
```

`katalog.html` butuh server HTTP karena memuat `catalog.json` lewat `fetch`. Membuka file langsung (`file://`) tidak akan berhasil.

## Deploy

Server: nginx dengan HTTPS dari Let's Encrypt (certbot). Struktur di server:

```
/var/www/tipack.kousozo.tech/
├── index.html  katalog.html  perf.js  catalog.json  install.sh  install.ps1  robots.txt
├── windows/  setup.ps1  JALANKAN.bat
├── macos/    setup.sh
└── linux/    setup.sh
```

Inti konfigurasi nginx:

```nginx
location ~ \.(sh|ps1|bat)$ { default_type text/plain; add_header Cache-Control "no-cache" always; }
location ~ \.(json|js)$    { add_header Cache-Control "no-cache" always; }
location /                 { try_files $uri $uri.html $uri/ =404; }   # /katalog → katalog.html
```

Script dikirim sebagai `text/plain` dengan `no-cache`, supaya pengguna selalu mendapat versi terbaru dan bisa membacanya di browser.

Contoh deploy dengan rsync dari root repo:

```bash
rsync -az web/{index.html,katalog.html,perf.js,catalog.json,install.sh,install.ps1} SERVER:/tmp/tipack/
rsync -az windows/setup.ps1 windows/JALANKAN.bat SERVER:/tmp/tipack/windows/
rsync -az macos/setup.sh SERVER:/tmp/tipack/macos/
rsync -az linux/setup.sh SERVER:/tmp/tipack/linux/
ssh SERVER 'sudo rsync -a /tmp/tipack/ /var/www/tipack.kousozo.tech/ && sudo chown -R www-data:www-data /var/www/tipack.kousozo.tech'
```

Kalau `perf.js` berubah, naikkan versi query di `<script src="perf.js?v=N">` pada kedua halaman.
