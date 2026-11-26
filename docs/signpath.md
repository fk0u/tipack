# Tanda tangan digital Windows lewat SignPath

Installer Windows (`.msi` dan `-setup.exe`) ditandatangani lewat [SignPath](https://signpath.io). Untuk proyek open source, sertifikat code signing disediakan gratis oleh **SignPath Foundation**. Tanpa tanda tangan, Windows SmartScreen menampilkan peringatan "Windows protected your PC".

Workflow `.github/workflows/gui.yml` sudah siap. Langkah SignPath **otomatis aktif** begitu variabel di bawah diisi; selama belum diisi, build tetap berjalan tanpa tanda tangan.

## 1. Di SignPath

1. Masuk ke [app.signpath.io](https://app.signpath.io) dan catat **Organization ID** (di *Settings*).
2. Buat **Project** dengan slug `tipack` dan hubungkan ke repo GitHub `fk0u/tipack` (*Trusted build system: GitHub.com*).
3. **Artifact configuration**: salin isi [`.signpath/artifact-configuration.xml`](../.signpath/artifact-configuration.xml), simpan dengan slug `default`.
4. **Signing policy**: pakai `test-signing` dulu untuk uji coba. Untuk rilis, pakai `release-signing` (sertifikat SignPath Foundation, setelah proyek disetujui).
5. Buat **API token** untuk CI user (*Users → CI user → API token*) dengan izin *Submitter* di proyek ini.

## 2. Di GitHub (Settings → Secrets and variables → Actions)

| Jenis | Nama | Isi |
|---|---|---|
| Secret | `SIGNPATH_API_TOKEN` | API token dari langkah 1.5 |
| Variable | `SIGNPATH_ORGANIZATION_ID` | Organization ID |
| Variable | `SIGNPATH_PROJECT_SLUG` | `tipack` |
| Variable | `SIGNPATH_POLICY_SLUG` | `test-signing` atau `release-signing` |
| Variable | `SIGNPATH_ARTIFACT_CONFIG` | `default` (opsional) |

> [!IMPORTANT]
> Token **selalu** disimpan sebagai *Secret*, jangan pernah di file repo atau di variabel biasa.

## 3. Uji

Jalankan **Actions → Build aplikasi GUI → Run workflow**. Di job `windows-x64` dan `windows-arm64`, langkah *Tanda tangani lewat SignPath* akan:
1. Mengirim zip installer.
2. Menunggu persetujuan atau penandatanganan. Untuk `release-signing`, approver di SignPath harus menyetujuinya dulu.
3. Mengunggah artifact `*-signed`.

Job `release` otomatis memilih versi bertanda tangan kalau ada.

## Catatan

- Kebijakan SignPath Foundation mewajibkan build dari CI publik (GitHub Actions), repo publik, dan lisensi OSI. TIPACK memenuhi ketiganya (MIT).
- macOS butuh **Apple Developer ID ($99/tahun)** untuk tanda tangan dan notarisasi; ini terpisah dari SignPath. Tanpa itu, pengguna membuka aplikasi lewat klik kanan → Open.
