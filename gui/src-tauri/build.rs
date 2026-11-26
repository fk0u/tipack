fn main() {
    // Windows: aplikasi meminta hak Administrator sekali saat dibuka (winget, WSL, fitur Windows, Doctor).
    let mut attrs = tauri_build::Attributes::new();
    #[cfg(windows)]
    {
        attrs = attrs.windows_attributes(tauri_build::WindowsAttributes::new().app_manifest(include_str!("windows-app-manifest.xml")));
    }
    tauri_build::try_build(attrs).expect("gagal menjalankan tauri-build");
}
