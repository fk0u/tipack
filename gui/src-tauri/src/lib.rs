//! TIPACK GUI: "kulit" grafis untuk mesin TIPACK (setup.ps1 / setup.sh).
//! Aplikasi ini TIDAK punya logika instalasi sendiri. Ia menjalankan mesin yang sama dengan versi
//! terminal dalam mode `--json`, lalu meneruskan setiap baris `@@TIPACK {...}` ke antarmuka sebagai event.

use serde::Serialize;
use std::io::{BufRead, BufReader};
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Mutex;
use tauri::{AppHandle, Emitter, Manager, State};
use tauri_plugin_dialog::DialogExt;

#[derive(Default)]
struct Engine {
    busy: AtomicBool,
    child: Mutex<Option<u32>>,
}

#[derive(Serialize, Clone)]
struct Platform {
    os: &'static str,
    arch: &'static str,
    version: &'static str,
}

#[tauri::command]
fn platform() -> Platform {
    let os = if cfg!(target_os = "windows") { "win" } else if cfg!(target_os = "macos") { "mac" } else { "linux" };
    Platform { os, arch: std::env::consts::ARCH, version: env!("CARGO_PKG_VERSION") }
}

fn engine_dir(app: &AppHandle) -> Result<PathBuf, String> {
    app.path().resource_dir().map(|d| d.join("engine")).map_err(|e| format!("folder resource tidak ditemukan: {e}"))
}

#[cfg(unix)]
fn make_exec(p: &PathBuf) {
    use std::os::unix::fs::PermissionsExt;
    if let Ok(meta) = std::fs::metadata(p) {
        let mut perm = meta.permissions();
        perm.set_mode(perm.mode() | 0o755);
        let _ = std::fs::set_permissions(p, perm);
    }
}

/// Bangun perintah untuk menjalankan mesin di OS ini.
fn build_command(app: &AppHandle, args: &[String]) -> Result<Command, String> {
    let dir = engine_dir(app)?;
    #[cfg(target_os = "windows")]
    {
        use std::os::windows::process::CommandExt;
        let script = dir.join("setup.ps1");
        let mut c = Command::new("powershell.exe");
        c.args(["-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File"]).arg(&script).arg("-Json").arg("-NoAnim");
        for a in args {
            // argumen gaya bash (--install x) diterjemahkan ke gaya PowerShell (-Install x)
            let mapped = match a.as_str() {
                "--install" => "-Install", "--config" => "-Config", "--preset" => "-Preset", "--scan-json" => "-ScanJson",
                "--doctor" => "-Doctor", "--doctor-fix" => "-DoctorFix", "--report" => "-Report", other => other,
            };
            c.arg(mapped);
        }
        c.creation_flags(0x0800_0000); // CREATE_NO_WINDOW
        return Ok(c);
    }
    #[cfg(not(target_os = "windows"))]
    {
        let (script, askpass) = if cfg!(target_os = "macos") {
            (dir.join("macos.sh"), dir.join("askpass-macos.sh"))
        } else {
            (dir.join("linux.sh"), dir.join("askpass-linux.sh"))
        };
        #[cfg(unix)]
        {
            make_exec(&script);
            make_exec(&askpass);
        }
        let mut c = Command::new("/bin/bash");
        c.arg(&script).arg("--json").arg("--no-anim").args(args);
        c.env("SUDO_ASKPASS", &askpass).env("TERM", "xterm-256color");
        // Homebrew (macOS) & PATH GUI yang minim
        let path = std::env::var("PATH").unwrap_or_default();
        c.env("PATH", format!("/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:{path}"));
        Ok(c)
    }
}

/// Jalankan mesin dan streaming event ke UI. Mengembalikan exit code.
#[tauri::command]
async fn run_engine(app: AppHandle, state: State<'_, Engine>, args: Vec<String>) -> Result<i32, String> {
    if state.busy.swap(true, Ordering::SeqCst) {
        return Err("Masih ada proses yang berjalan. Tunggu sampai selesai.".into());
    }
    let result = (|| -> Result<i32, String> {
        let mut cmd = build_command(&app, &args)?;
        cmd.stdin(Stdio::null()).stdout(Stdio::piped()).stderr(Stdio::piped());
        let mut child = cmd.spawn().map_err(|e| format!("gagal menjalankan mesin TIPACK: {e}"))?;
        *state.child.lock().unwrap() = Some(child.id());
        let _ = app.emit("engine-start", &args);

        let stderr = child.stderr.take();
        let app_err = app.clone();
        let err_thread = std::thread::spawn(move || {
            if let Some(e) = stderr {
                for line in BufReader::new(e).lines().map_while(Result::ok) {
                    let _ = app_err.emit("engine-log", line);
                }
            }
        });
        if let Some(out) = child.stdout.take() {
            let reader = BufReader::new(out);
            for raw in reader.split(b'\n').map_while(Result::ok) {
                let line = String::from_utf8_lossy(&raw).replace('\r', "");
                if let Some(json) = line.find("@@TIPACK ").map(|i| &line[i + 9..]) {
                    match serde_json::from_str::<serde_json::Value>(json.trim()) {
                        Ok(v) => { let _ = app.emit("engine-event", v); }
                        Err(_) => { let _ = app.emit("engine-log", line.clone()); }
                    }
                } else if !line.trim().is_empty() {
                    let _ = app.emit("engine-log", strip_ansi(&line));
                }
            }
        }
        let status = child.wait().map_err(|e| e.to_string())?;
        let _ = err_thread.join();
        Ok(status.code().unwrap_or(-1))
    })();
    *state.child.lock().unwrap() = None;
    state.busy.store(false, Ordering::SeqCst);
    let code = result.as_ref().map(|c| *c).unwrap_or(-1);
    let _ = app.emit("engine-exit", code);
    result
}

/// Hentikan proses mesin yang sedang berjalan.
#[tauri::command]
fn stop_engine(state: State<'_, Engine>) -> bool {
    if let Some(pid) = *state.child.lock().unwrap() {
        #[cfg(target_os = "windows")]
        {
            use std::os::windows::process::CommandExt;
            let _ = Command::new("taskkill").args(["/PID", &pid.to_string(), "/T", "/F"]).creation_flags(0x0800_0000).status();
        }
        #[cfg(not(target_os = "windows"))]
        {
            let _ = Command::new("kill").arg(pid.to_string()).status();
        }
        return true;
    }
    false
}

fn strip_ansi(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let mut it = s.chars().peekable();
    while let Some(c) = it.next() {
        if c == '\u{1b}' {
            if it.peek() == Some(&'[') {
                it.next();
                while let Some(n) = it.next() { if n.is_ascii_alphabetic() { break; } }
            }
        } else if !c.is_control() || c == '\t' {
            out.push(c);
        }
    }
    out
}

/// Simpan tipack.json lewat dialog "Save as".
#[tauri::command]
async fn save_config(app: AppHandle, content: String) -> Result<Option<String>, String> {
    let picked = app.dialog().file().set_file_name("tipack.json").add_filter("Konfigurasi TIPACK", &["json"]).blocking_save_file();
    match picked.and_then(|p| p.into_path().ok()) {
        Some(path) => { std::fs::write(&path, content).map_err(|e| e.to_string())?; Ok(Some(path.display().to_string())) }
        None => Ok(None),
    }
}

/// Buka tipack.json lewat dialog, kembalikan isi + path.
#[tauri::command]
async fn open_config(app: AppHandle) -> Result<Option<(String, String)>, String> {
    let picked = app.dialog().file().add_filter("Konfigurasi TIPACK", &["json"]).blocking_pick_file();
    match picked.and_then(|p| p.into_path().ok()) {
        Some(path) => { let text = std::fs::read_to_string(&path).map_err(|e| e.to_string())?; Ok(Some((path.display().to_string(), text))) }
        None => Ok(None),
    }
}

/// Tulis konfigurasi sementara (untuk --config) dan kembalikan path-nya.
#[tauri::command]
fn temp_config(content: String) -> Result<String, String> {
    let p = std::env::temp_dir().join("tipack-gui-config.json");
    std::fs::write(&p, content).map_err(|e| e.to_string())?;
    Ok(p.display().to_string())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_opener::init())
        .manage(Engine::default())
        .invoke_handler(tauri::generate_handler![platform, run_engine, stop_engine, save_config, open_config, temp_config])
        .run(tauri::generate_context!())
        .expect("gagal menjalankan TIPACK");
}
