# Berkontribusi ke TIPACK

Terima kasih sudah mau membantu! Kontribusi apa pun diterima: laporan bug, ID paket yang salah, aplikasi baru, dukungan distro, perbaikan dokumentasi, atau terjemahan.

## Melaporkan masalah

Buka [issue](https://github.com/fk0u/tipack/issues) dan sertakan:

- OS dan versinya (Windows 11 23H2 / macOS 15 / `cat /etc/os-release`)
- Apa yang dipilih dan apa yang terjadi
- Potongan **file log** `devsetup-log-*.txt` di sekitar item yang gagal

Untuk celah keamanan, lihat [docs/keamanan.md](docs/keamanan.md#melaporkan-celah-keamanan). Jangan buka issue publik.

## Alur pull request

1. Fork repo, lalu buat branch: `git checkout -b tambah-insomnia`.
2. Lakukan perubahan. Panduan lengkap: [docs/arsitektur.md](docs/arsitektur.md).
3. Jalankan pengecekan:
   ```bash
   bash linux/src/build.sh          # wajib kalau mengubah linux-parts.sh ATAU macos/setup.sh
   bash -n macos/setup.sh
   python3 web/build-catalog.py     # wajib kalau mengubah katalog/profil
   ```
4. Commit **termasuk file hasil generate** (`linux/setup.sh`, `web/catalog.json`, `docs/katalog.md`).
5. Buka pull request. Jelaskan apa yang diubah, dan di OS/distro mana kamu sudah mengujinya.

## Checklist menambah aplikasi

- [ ] ID paket sudah dicek (`winget search` / `brew search` / repo distro / `flatpak search`)
- [ ] `key` sama di semua OS untuk aplikasi yang sama; huruf kecil, tanpa `-` di macOS/Linux
- [ ] Tooltip berbahasa Indonesia, ASCII saja, tanpa `|` `{` `}`, dan menjelaskan kapan aplikasi ini dipilih
- [ ] `Rek=1` hanya kalau memang dipakai sebagian besar mahasiswa IF
- [ ] Linux: kolom yang tidak tahu diisi `-` (jangan menebak nama paket)
- [ ] `build.sh` dan `build-catalog.py` sudah dijalankan

## Lisensi

Dengan mengirim kontribusi, kamu setuju kontribusimu dirilis di bawah [lisensi MIT](LICENSE).
