#!/usr/bin/env python3
"""Menambahkan katalog software umum (ala Ninite, tren 2026) ke ketiga installer.
Sekali jalan; idempoten (key yang sudah ada dilewati).

Format per aplikasi:
  key, Kategori, Nama, rek(0/1), Tooltip,
  win  : winget ID | "msstore:ID" | "info:url" | None
  mac  : ("formula"|"cask"|"info", id, deteksi) | None
  linux: dict kolom apt/dnf/pac/zyp/apk/tmx/flat/uni (default "-") | None
"""
import pathlib, re

ROOT = pathlib.Path(__file__).resolve().parent.parent

def L(**k):
    base = dict(apt="-", dnf="-", pac="-", zyp="-", apk="-", tmx="-", flat="-", uni="-", det="")
    base.update(k); return base

APPS = [
  # ---------------- Browser
  ("zen", "Browser", "Zen Browser", 0, "Browser berbasis Firefox dengan tab vertikal dan workspace ala Arc. Arc sudah tidak dikembangkan, Zen penggantinya yang sedang naik daun.",
   "Zen-Team.Zen-Browser", ("cask", "zen", "Zen"), L(pac="aur:zen-browser-bin", flat="app.zen_browser.zen")),
  ("vivaldi", "Browser", "Vivaldi", 0, "Browser Chromium yang sangat bisa dikustom: tab bertumpuk, panel samping, email dan kalender bawaan.",
   "Vivaldi.Vivaldi", ("cask", "vivaldi", "Vivaldi"), L(pac="vivaldi", flat="com.vivaldi.Vivaldi")),
  ("opera", "Browser", "Opera", 0, "Browser dengan VPN gratis bawaan dan sidebar WhatsApp/Telegram.",
   "Opera.Opera", ("cask", "opera", "Opera"), L(pac="aur:opera", flat="com.opera.Opera")),
  ("edge", "Browser", "Microsoft Edge", 0, "Bawaan Windows. Di Mac/Linux berguna untuk tes tampilan web di Edge.",
   "Microsoft.Edge", ("cask", "microsoft-edge", "Microsoft Edge"), L(pac="aur:microsoft-edge-stable-bin", flat="com.microsoft.Edge")),
  ("tor", "Browser", "Tor Browser", 0, "Browsing anonim lewat jaringan Tor.",
   "TorProject.TorBrowser", ("cask", "tor-browser", "Tor Browser"), L(apt="torbrowser-launcher", pac="torbrowser-launcher", flat="org.torproject.torbrowser-launcher")),
  # ---------------- Komunikasi
  ("whatsapp", "Komunikasi", "WhatsApp Desktop", 1, "WhatsApp resmi untuk laptop: chat, telepon dan video call. Di Linux pakai web.whatsapp.com.",
   "msstore:9NKSQGP7F2NH", None, L(uni="info:https://web.whatsapp.com")),
  ("signal", "Komunikasi", "Signal", 0, "Chat terenkripsi end-to-end, standar privasi tertinggi.",
   "OpenWhisperSystems.Signal", ("cask", "signal", "Signal"), L(pac="signal-desktop", flat="org.signal.Signal")),
  ("thunderbird", "Komunikasi", "Thunderbird", 0, "Aplikasi email gratis untuk banyak akun sekaligus (Gmail, email kampus, Outlook).",
   "Mozilla.Thunderbird", ("cask", "thunderbird", "Thunderbird"), L(apt="thunderbird", dnf="thunderbird", pac="thunderbird", zyp="MozillaThunderbird", apk="thunderbird", flat="org.mozilla.Thunderbird")),
  # ---------------- Media & Hiburan
  ("spotify", "Media & Hiburan", "Spotify", 1, "Streaming musik dan podcast.",
   "Spotify.Spotify", ("cask", "spotify", "Spotify"), L(pac="aur:spotify", flat="com.spotify.Client")),
  ("audacity", "Media & Hiburan", "Audacity", 0, "Rekam dan edit audio gratis: podcast, voice over, tugas presentasi.",
   "Audacity.Audacity", ("cask", "audacity", "Audacity"), L(apt="audacity", dnf="audacity", pac="audacity", zyp="audacity", flat="org.audacityteam.Audacity")),
  ("handbrake", "Media & Hiburan", "HandBrake", 0, "Kompres dan konversi video (misal video tugas terlalu besar untuk diunggah).",
   "HandBrake.HandBrake", ("cask", "handbrake-app", "HandBrake"), L(apt="handbrake", pac="handbrake", flat="fr.handbrake.ghb")),
  ("capcut", "Media & Hiburan", "CapCut", 0, "Editor video populer untuk konten TikTok/Reels/YouTube Shorts.",
   "ByteDance.CapCut", ("cask", "capcut", "CapCut"), None),
  ("davinci", "Media & Hiburan", "DaVinci Resolve", 0, "Editor video profesional gratis kelas Hollywood. Butuh GPU yang cukup.",
   "info:https://www.blackmagicdesign.com/products/davinciresolve", ("cask", "davinci-resolve", "DaVinci Resolve"), L(uni="info:https://www.blackmagicdesign.com/products/davinciresolve")),
  ("kdenlive", "Media & Hiburan", "Kdenlive", 0, "Editor video open source yang ringan, alternatif gratis untuk editing serius.",
   "KDE.Kdenlive", ("cask", "kdenlive", "kdenlive"), L(apt="kdenlive", dnf="kdenlive", pac="kdenlive", zyp="kdenlive", flat="org.kde.kdenlive")),
  ("klite", "Media & Hiburan", "K-Lite Codec Pack", 0, "Codec video lengkap supaya semua format bisa diputar di pemutar bawaan Windows.",
   "CodecGuide.K-LiteCodecPack.Standard", None, None),
  # ---------------- Desain
  ("krita", "Desain & Multimedia", "Krita", 0, "Aplikasi menggambar digital gratis, favorit ilustrator dan pengguna pen tablet.",
   "KDE.Krita", ("cask", "krita", "krita"), L(apt="krita", dnf="krita", pac="krita", zyp="krita", flat="org.kde.krita")),
  ("paintnet", "Desain & Multimedia", "Paint.NET", 0, "Editor gambar ringan dan cepat, di antara Paint dan Photoshop.",
   "dotPDN.PaintDotNet", None, None),
  ("affinity", "Desain & Multimedia", "Affinity (gratis)", 0, "Desain foto, vektor dan layout setara Adobe, sekarang gratis setelah diakuisisi Canva.",
   "info:https://www.affinity.studio", ("info", "https://www.affinity.studio", "Affinity"), None),
  ("canva", "Desain & Multimedia", "Canva", 1, "Desain poster, presentasi dan konten sosmed dengan template. Mahasiswa sering dapat Canva Pro gratis lewat kampus.",
   "Canva.Canva", ("cask", "canva", "Canva"), L(uni="info:https://www.canva.com")),
  ("upscayl", "Desain & Multimedia", "Upscayl", 0, "Perbesar dan pertajam foto dengan AI secara offline dan gratis.",
   "Upscayl.Upscayl", ("cask", "upscayl", "Upscayl"), L(flat="org.upscayl.Upscayl")),
  # ---------------- Office
  ("wps", "Kuliah & Produktivitas", "WPS Office", 0, "Office gratis yang sangat mirip Microsoft Office, populer di Indonesia. Ringan untuk laptop lama.",
   "Kingsoft.WPSOffice", ("cask", "wpsoffice", "wpsoffice"), L(pac="aur:wps-office", flat="com.wps.Office")),
  ("onlyoffice", "Kuliah & Produktivitas", "ONLYOFFICE", 0, "Office gratis open source dengan kompatibilitas file Word/Excel/PowerPoint terbaik.",
   "ONLYOFFICE.DesktopEditors", ("cask", "onlyoffice", "ONLYOFFICE"), L(pac="aur:onlyoffice-bin", flat="org.onlyoffice.desktopeditors")),
  ("anki", "Kuliah & Produktivitas", "Anki", 0, "Flashcard dengan pengulangan berjeda: cara belajar paling efektif untuk hafalan dan ujian.",
   "Anki.Anki", ("cask", "anki", "Anki"), L(apt="anki", pac="anki", flat="net.ankiweb.Anki")),
  # ---------------- Keamanan & Privasi
  ("bitwarden", "Keamanan & Privasi", "Bitwarden", 1, "Password manager gratis dan open source. Satu password kuat untuk semua akun, sinkron ke HP.",
   "Bitwarden.Bitwarden", ("cask", "bitwarden", "Bitwarden"), L(pac="bitwarden", flat="com.bitwarden.desktop")),
  ("keepassxc", "Keamanan & Privasi", "KeePassXC", 0, "Password manager offline, database terenkripsi disimpan sendiri.",
   "KeePassXCTeam.KeePassXC", ("cask", "keepassxc", "KeePassXC"), L(apt="keepassxc", dnf="keepassxc", pac="keepassxc", zyp="keepassxc", apk="keepassxc", flat="org.keepassxc.KeePassXC")),
  ("protonvpn", "Keamanan & Privasi", "Proton VPN", 0, "VPN gratis tanpa batas kuota dari pembuat Proton Mail. Aman untuk WiFi publik.",
   "Proton.ProtonVPN", ("cask", "protonvpn", "Proton VPN"), L(flat="com.protonvpn.www")),
  ("warp", "Keamanan & Privasi", "Cloudflare WARP (1.1.1.1)", 0, "DNS cepat + enkripsi koneksi dari Cloudflare. Sering membantu kalau internet kampus/ISP lambat membuka situs tertentu.",
   "Cloudflare.Warp", ("cask", "cloudflare-warp", "Cloudflare WARP"), L(uni="info:https://pkg.cloudflareclient.com")),
  ("malwarebytes", "Keamanan & Privasi", "Malwarebytes", 0, "Pemindai malware/adware gratis, pendamping Windows Defender untuk membersihkan laptop yang terinfeksi.",
   "Malwarebytes.Malwarebytes", ("cask", "malwarebytes", "Malwarebytes"), None),
  ("veracrypt", "Keamanan & Privasi", "VeraCrypt", 0, "Enkripsi flashdisk/folder supaya data aman kalau hilang.",
   "IDRIX.VeraCrypt", ("cask", "veracrypt", "VeraCrypt"), L(pac="veracrypt", uni="info:https://www.veracrypt.fr/en/Downloads.html")),
  # ---------------- Cloud
  ("dropbox", "Cloud & Sinkronisasi", "Dropbox", 0, "Sinkronisasi file ke cloud.",
   "Dropbox.Dropbox", ("cask", "dropbox", "Dropbox"), L(pac="aur:dropbox", flat="com.dropbox.Client")),
  ("onedrive", "Cloud & Sinkronisasi", "OneDrive", 0, "Cloud Microsoft, 1 TB gratis dengan Microsoft 365 email kampus.",
   "Microsoft.OneDrive", ("cask", "onedrive", "OneDrive"), None),
  ("mega", "Cloud & Sinkronisasi", "MEGA", 0, "Cloud dengan 20 GB gratis dan enkripsi end-to-end.",
   "Mega.MEGASync", ("cask", "megasync", "MEGAsync"), L(flat="nz.mega.MEGAsync")),
  ("syncthing", "Cloud & Sinkronisasi", "Syncthing", 0, "Sinkron folder antar laptop/HP langsung tanpa cloud, open source.",
   "Syncthing.Syncthing", ("formula", "syncthing", "cmd:syncthing"), L(apt="syncthing", dnf="syncthing", pac="syncthing", zyp="syncthing", apk="syncthing", tmx="syncthing")),
  # ---------------- Gaming
  ("steam", "Gaming", "Steam", 1, "Toko dan launcher game PC terbesar. Di Linux, banyak game Windows jalan lewat Proton.",
   "Valve.Steam", ("cask", "steam", "Steam"), L(flat="com.valvesoftware.Steam")),
  ("epic", "Gaming", "Epic Games Launcher", 0, "Launcher Epic dengan game gratis setiap minggu.",
   "EpicGames.EpicGamesLauncher", ("cask", "epic-games", "Epic Games Launcher"), None),
  ("heroic", "Gaming", "Heroic Games Launcher", 0, "Launcher open source untuk game Epic, GOG dan Amazon. Cara terbaik main game Epic di Linux.",
   "HeroicGamesLauncher.HeroicGamesLauncher", ("cask", "heroic", "Heroic"), L(pac="aur:heroic-games-launcher-bin", flat="com.heroicgameslauncher.hgl")),
  ("gog", "Gaming", "GOG Galaxy", 0, "Launcher GOG, game tanpa DRM.",
   "GOG.Galaxy", ("cask", "gog-galaxy", "GOG Galaxy"), None),
  ("eaapp", "Gaming", "EA app", 0, "Launcher game EA (FC, Battlefield, The Sims).",
   "ElectronicArts.EADesktop", None, None),
  ("ubisoft", "Gaming", "Ubisoft Connect", 0, "Launcher game Ubisoft (Assassin's Creed, Rainbow Six).",
   "Ubisoft.Connect", None, None),
  ("playnite", "Gaming", "Playnite", 0, "Satu perpustakaan untuk semua game dari semua launcher.",
   "Playnite.Playnite", None, None),
  ("afterburner", "Gaming", "MSI Afterburner", 0, "Pantau FPS, suhu GPU/CPU di dalam game, dan atur kipas.",
   "Guru3D.Afterburner", None, None),
  ("lutris", "Gaming", "Lutris", 0, "Pengelola game Linux: menjalankan game Windows, emulator dan launcher lain.",
   None, None, L(apt="lutris", dnf="lutris", pac="lutris", zyp="lutris", flat="net.lutris.Lutris")),
  ("prism", "Gaming", "Prism Launcher (Minecraft)", 0, "Launcher Minecraft Java open source: banyak instance dan modpack dengan mudah.",
   "PrismLauncher.PrismLauncher", ("cask", "prismlauncher", "Prism Launcher"), L(pac="prismlauncher", flat="org.prismlauncher.PrismLauncher")),
  # ---------------- AI
  ("chatgpt", "AI & Data", "ChatGPT Desktop", 0, "Aplikasi resmi ChatGPT dengan shortcut cepat dan mode suara.",
   "msstore:9NT1R1C2HH7J", ("cask", "chatgpt", "ChatGPT"), L(uni="info:https://chatgpt.com")),
  ("jan", "AI & Data", "Jan", 0, "Chat dengan LLM lokal yang open source dan 100% offline. Alternatif LM Studio.",
   "Jan.Jan", ("cask", "jan", "Jan"), L(flat="ai.jan.Jan")),
  # ---------------- Download
  ("qbittorrent", "Download & Transfer", "qBittorrent", 0, "Klien torrent open source tanpa iklan. Unduh ISO Linux dengan cepat.",
   "qBittorrent.qBittorrent", ("cask", "qbittorrent", "qBittorrent"), L(apt="qbittorrent", dnf="qbittorrent", pac="qbittorrent", zyp="qbittorrent", apk="qbittorrent", flat="org.qbittorrent.qBittorrent")),
  ("idm", "Download & Transfer", "Internet Download Manager", 0, "Download manager paling populer di Indonesia: mempercepat dan melanjutkan unduhan. Berbayar (trial 30 hari).",
   "Tonec.InternetDownloadManager", None, None),
  ("fdm", "Download & Transfer", "Free Download Manager", 0, "Download manager gratis: percepat unduhan, jadwal, dan lanjutkan unduhan putus.",
   "SoftDeluxe.FreeDownloadManager", ("cask", "free-download-manager", "Free Download Manager"), L(uni="info:https://www.freedownloadmanager.org/download.htm")),
  ("jdownloader", "Download & Transfer", "JDownloader 2", 0, "Download manager untuk banyak file sekaligus dari situs hosting.",
   "AppWork.JDownloader", ("cask", "jdownloader", "JDownloader2"), L(flat="org.jdownloader.JDownloader")),
  # ---------------- Utilitas
  ("wiztree", "Utilitas Sistem", "WizTree", 1, "Lihat folder apa yang menghabiskan disk dalam hitungan detik. Wajib untuk laptop yang disknya penuh.",
   "AntibodySoftware.WizTree", None, None),
  ("flowlauncher", "Utilitas Sistem", "Flow Launcher", 0, "Launcher cepat ala Spotlight/Raycast untuk Windows (Alt+Spasi).",
   "Flow-Launcher.Flow-Launcher", None, None),
  ("ditto", "Utilitas Sistem", "Ditto (riwayat clipboard)", 0, "Riwayat copy-paste yang bisa dicari, jauh lebih lengkap dari Win+V.",
   "Ditto.Ditto", None, None),
  ("teracopy", "Utilitas Sistem", "TeraCopy", 0, "Copy file besar lebih cepat dan bisa dijeda/dilanjutkan, dengan verifikasi hasil copy.",
   "CodeSector.TeraCopy", None, None),
  ("twinkletray", "Utilitas Sistem", "Twinkle Tray", 0, "Atur brightness monitor eksternal langsung dari taskbar.",
   "xanderfrangos.twinkletray", None, None),
  ("parsec", "Utilitas Sistem", "Parsec", 0, "Remote desktop super mulus (bisa untuk main game dari laptop lain).",
   "Parsec.Parsec", ("cask", "parsec", "Parsec"), L(flat="com.parsecgaming.parsec")),
  # ---------------- Runtime
  ("dotnetdesktop", "Runtime & Driver", ".NET Desktop Runtime 8", 1, "Dibutuhkan banyak aplikasi Windows modern. Kalau ada aplikasi minta .NET, ini jawabannya.",
   "Microsoft.DotNet.DesktopRuntime.8", None, None),
  ("javaruntime", "Runtime & Driver", "Java Runtime (Temurin JRE 21)", 0, "Untuk menjalankan aplikasi .jar (misal Minecraft lama, aplikasi kampus berbasis Java). Developer pilih JDK saja.",
   "EclipseAdoptium.Temurin.21.JRE", None, None),
  ("directx", "Runtime & Driver", "DirectX End-User Runtime", 0, "Library lama yang masih dibutuhkan banyak game.",
   "Microsoft.DirectX", None, None),
  ("nvidiaapp", "Runtime & Driver", "NVIDIA App (driver GPU)", 0, "Update driver GPU NVIDIA dan pengaturan grafis. Hanya untuk laptop dengan GPU NVIDIA.",
   "info:https://www.nvidia.com/en-us/software/nvidia-app/", None, None),
]

PROFILES = {
  "umum": ("Paket Umum (ala Ninite)", "Software sehari-hari untuk siapa saja: browser, chat, musik, video, office, PDF, password manager, cloud dan utilitas.",
           "chrome firefox 7zip unarchiver vlc iina spotify whatsapp telegram discord zoom libreoffice wps sumatra bitwarden gdrive localsend sharex flameshot everything powertoys wiztree rectangle stats raycast appcleaner dotnetdesktop vcredist"),
  "gamer": ("Gamer", "Launcher game, overlay performa, voice chat, rekam gameplay dan runtime yang dibutuhkan game.",
            "steam epic heroic gog eaapp ubisoft playnite afterburner discord obs vcredist directx dotnetdesktop lutris prism parsec"),
  "kreator": ("Konten Kreator", "Edit video, audio dan gambar, desain sosial media dan rekam layar.",
              "obs capcut davinci kdenlive audacity handbrake krita gimp inkscape canva figma upscayl sharex flameshot spotify"),
}

WIZ_ADD = [
  ("Media & hiburan?", "spotify vlc iina audacity handbrake capcut davinci kdenlive klite", "Spotify untuk musik, CapCut/DaVinci/Kdenlive untuk video, Audacity untuk audio, HandBrake untuk kompres video."),
  ("Keamanan & privasi?", "bitwarden keepassxc protonvpn warp malwarebytes veracrypt", "Password manager (Bitwarden) sangat disarankan untuk semua orang. Proton VPN gratis untuk WiFi publik."),
  ("Cloud & sinkronisasi?", "gdrive onedrive dropbox mega syncthing", "Google Drive/OneDrive biasanya dapat kuota besar dari email kampus."),
  ("Gaming?", "steam epic heroic gog eaapp ubisoft playnite afterburner lutris prism", "Steam paling umum. Di Linux, Heroic dan Lutris membantu menjalankan game Windows."),
  ("Download & transfer?", "qbittorrent idm fdm jdownloader localsend", "Free Download Manager gratis, IDM berbayar tapi populer. LocalSend untuk kirim file HP-laptop."),
]

def ps_line(a):
    key, cat, name, rec, tip, win, mac, lx = a
    return f"{key}|{cat}|{win}|{name}|{rec}|{tip}"
def mac_line(a):
    key, cat, name, rec, tip, win, mac, lx = a
    t, i, det = mac
    return f"{key}|{cat}|{t}|{i}|{name}|{rec}|{det}|{tip}"
def lx_line(a):
    key, cat, name, rec, tip, win, mac, lx = a
    return f"{key}|{cat}|{name}|{rec}|{lx['det']}|{lx['apt']}|{lx['dnf']}|{lx['pac']}|{lx['zyp']}|{lx['apk']}|{lx['tmx']}|{lx['flat']}|{lx['uni']}|{tip}"

def insert_lines(text, start_pat, end_pat, new_lines, existing_keys):
    m = re.search(start_pat, text, re.M); s = m.end()
    e = text.index(end_pat, s)
    block = text[s:e].rstrip("\n")
    add = [l for l in new_lines if l.split("|")[0] not in existing_keys]
    return text[:s] + block + ("\n" + "\n".join(add) if add else "") + "\n" + text[e:], len(add)

# ---------------- Windows
p = ROOT / "windows/setup.ps1"; s = p.read_text(encoding="utf-8-sig")
keys = set(re.findall(r"^([a-z0-9-]+)\|", s[s.index("$CatalogRaw = @'"):s.index("\n'@", s.index("$CatalogRaw = @'"))], re.M))
lines = [ps_line(a) for a in APPS if a[5]]
s, n = insert_lines(s, r"^\$CatalogRaw = @'\n", "\n'@", lines, keys)
for k, (nm, desc, lst) in PROFILES.items():
    if f"K = '{k}'" not in s:
        s = s.replace("\n)\n\n$Wizard = @(", f"\n  @{{ K = '{k}'; N = '{nm}'; T = '{desc}'; L = '{','.join(lst.split())}' }}\n)\n\n$Wizard = @(", 1)
for q, lst, tip in WIZ_ADD:
    if f"Q = '{q}'" not in s:
        s = s.replace("\n)\n\n$VSExt = @(", f"\n  @{{ Q = '{q}'; M = $true; L = '{','.join(lst.split())}'; T = '{tip}' }}\n)\n\n$VSExt = @(", 1)
p.write_text(s, encoding="utf-8-sig"); print(f"Windows: +{n} aplikasi")

# ---------------- macOS
p = ROOT / "macos/setup.sh"; s = p.read_text()
a0 = s.index("CATALOG_RAW='\n"); keys = set(re.findall(r"^([a-z0-9]+)\|", s[a0:s.index("\n'", a0 + 14)], re.M))
lines = [mac_line(a) for a in APPS if a[6]]
s, n = insert_lines(s, r"^CATALOG_RAW='\n", "\n'\n", lines, keys)
for k, (nm, desc, lst) in PROFILES.items():
    if f'"{k}|' not in s:
        s = s.replace('\n)\n\nWIZ=(', f'\n"{k}|{nm}|{desc}|{lst}"\n)\n\nWIZ=(', 1)
for q, lst, tip in WIZ_ADD:
    if f'"{q}|' not in s:
        s = s.replace('\n)\n\nVSEXT=(', f'\n"{q}|m|{lst}|{tip}"\n)\n\nVSEXT=(', 1)
p.write_text(s); print(f"macOS: +{n} aplikasi")

# ---------------- Linux
p = ROOT / "linux/src/linux-parts.sh"; s = p.read_text()
a0 = s.index("CATALOG_RAW='\n"); keys = set(re.findall(r"^([a-z0-9]+)\|", s[a0:s.index("\n'", a0 + 14)], re.M))
lines = [lx_line(a) for a in APPS if a[7]]
s, n = insert_lines(s, r"^CATALOG_RAW='\n", "\n'\n", lines, keys)
for k, (nm, desc, lst) in PROFILES.items():
    if f'"{k}|' not in s:
        s = s.replace('\n)\n\nWIZ=(', f'\n"{k}|{nm}|{desc}|{lst}"\n)\n\nWIZ=(', 1)
for q, lst, tip in WIZ_ADD:
    if f'"{q}|' not in s:
        s = s.replace('\n)\n\nVSEXT=(', f'\n"{q}|m|{lst}|{tip}"\n)\n\nVSEXT=(', 1)
p.write_text(s); print(f"Linux: +{n} aplikasi")
