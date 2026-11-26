#!/usr/bin/env python3
"""Salin logo brand dari paket simple-icons (CC0) ke web/icons/<key>.svg untuk setiap aplikasi di katalog.
Pakai: python3 tools/build-icons.py /path/ke/simple-icons/package
Hasil: web/icons/*.svg + web/icons/icons.json {key: {"slug","hex","title"}}
Aplikasi tanpa logo di simple-icons memakai monogram di website (tidak dibuat file)."""
import json, pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PKG = pathlib.Path(sys.argv[1])
data = json.loads((PKG / "data/simple-icons.json").read_text())
icons = data if isinstance(data, list) else data["icons"]
by_slug = {i["slug"]: i for i in icons}
by_title = {re.sub(r"[^a-z0-9]", "", i["title"].lower()): i for i in icons}

# key katalog -> slug simple-icons (kalau nama tidak bisa dicocokkan otomatis)
MAP = {
  "chrome": "googlechrome", "firefoxdev": "firefoxbrowser", "firefox": "firefoxbrowser", "brave": "brave", "chromium": "googlechrome",
  "zen": "zenbrowser", "opera": "opera", "operagx": "operagx", "vivaldi": "vivaldi", "tor": "torbrowser", "arc": "arc",
  "7zip": "7zip", "winrar": "winrar", "everything": "voidtools", "unarchiver": "theunarchiver",
  "wt": "windowsterminal", "pwsh": "powershell", "ohmyposh": "ohmyposh", "ohmyzsh": "ohmyzsh", "nerdfont": "nerdfonts",
  "iterm2": "iterm2", "warp": "warp", "ghostty": "ghostty", "starship": "starship", "tmux": "tmux", "kitty": "kitty", "alacritty": "alacritty", "fish": "fishshell", "zsh": "zsh",
  "vscode": "vscodium", "vscodium": "vscodium", "cursor": "cursor", "zed": "zedindustries", "sublime": "sublimetext", "notepadpp": "notepadplusplus", "neovim": "neovim",
  "intellij": "intellijidea", "pycharm": "pycharm", "toolbox": "jetbrains", "netbeans": "apachenetbeanside", "androidstudio": "androidstudio", "xcode": "xcode",
  "mingw": "gnu", "gcc": "gnu", "build": "gnu", "clang": "llvm", "cmake": "cmake", "msys2": "msys2",
  "python": "python", "uv": "uv", "miniconda": "anaconda", "nodejs": "nodedotjs", "node": "nodedotjs", "nvm": "nodedotjs", "fnm": "nodedotjs", "bun": "bun",
  "jdk": "openjdk", "jdk17": "openjdk", "javaruntime": "openjdk", "go": "go", "rust": "rust", "php": "php", "composer": "composer", "dotnet": "dotnet", "dotnetdesktop": "dotnet", "r": "r", "cocoapods": "cocoapods",
  "xampp": "xampp", "laragon": "laragon", "mysql": "mysql", "mariadb": "mariadb", "postgres": "postgresql", "mongodb": "mongodb", "compass": "mongodb", "sqlite": "sqlite", "redis": "redis",
  "dbeaver": "dbeaver", "tableplus": "tableplus", "workbench": "mysql", "heidisql": "mysql", "sequelace": "mysql", "dbngin": "postgresql", "herd": "laravel", "mamp": "mamp", "lamp": "apache",
  "git": "git", "ghdesktop": "github", "ghcli": "github", "lazygit": "git", "postman": "postman", "bruno": "bruno",
  "docker": "docker", "orbstack": "docker", "podman": "podman", "distrobox": "linuxcontainers", "kubectl": "kubernetes", "terraform": "terraform", "awscli": "amazonwebservices",
  "gcloud": "googlecloud", "azcli": "microsoftazure", "ngrok": "ngrok", "ollama": "ollama", "lmstudio": "lmstudio", "claude": "claude", "jupyter": "jupyter", "rstudio": "rstudioide", "chatgpt": "openai", "jan": "jan",
  "flutter": "flutter", "unity": "unity", "godot": "godotengine", "blender": "blender", "arduino": "arduino", "bluestacks": "bluestacks",
  "packettracer": "cisco", "wireshark": "wireshark", "nmap": "nmap", "putty": "putty", "mobaxterm": "mobaxterm", "winscp": "winscp", "filezilla": "filezilla", "cyberduck": "cyberduck",
  "termius": "termius", "burp": "burpsuite", "wireguard": "wireguard", "openssh": "openssh", "remmina": "remmina",
  "wslcore": "linux", "wsl-ubuntu": "ubuntu", "wsl-debian": "debian", "wsl-kali": "kalilinux", "virtualbox": "virtualbox", "utm": "utm", "multipass": "ubuntu", "virtmanager": "qemu", "boxes": "gnome",
  "figma": "figma", "drawio": "diagramsdotnet", "gimp": "gimp", "inkscape": "inkscape", "obs": "obsstudio", "sharex": "sharex", "vlc": "vlcmediaplayer", "iina": "iina", "flameshot": "flameshot",
  "krita": "krita", "canva": "canva", "affinity": "affinity", "upscayl": "upscayl", "kdenlive": "kdenlive", "davinci": "davinciresolve", "capcut": "capcut", "audacity": "audacity", "handbrake": "handbrake", "spotify": "spotify",
  "discord": "discord", "zoom": "zoom", "telegram": "telegram", "slack": "slack", "whatsapp": "whatsapp", "signal": "signal", "thunderbird": "thunderbird",
  "notion": "notion", "obsidian": "obsidian", "zotero": "zotero", "libreoffice": "libreoffice", "onlyoffice": "onlyoffice", "wps": "wps", "anki": "anki", "sumatra": "sumatrapdf", "okular": "kde",
  "gdrive": "googledrive", "dropbox": "dropbox", "mega": "mega", "syncthing": "syncthing",
  "bitwarden": "bitwarden", "keepassxc": "keepassxc", "protonvpn": "protonvpn", "warp": "cloudflare", "malwarebytes": "malwarebytes", "veracrypt": "veracrypt",
  "steam": "steam", "epic": "epicgames", "heroic": "heroicgameslauncher", "gog": "gogdotcom", "eaapp": "ea", "ubisoft": "ubisoft", "playnite": "playnite", "afterburner": "msi", "lutris": "lutris", "prism": "prismlauncher",
  "qbittorrent": "qbittorrent", "jdownloader": "jdownloader", "parsec": "parsec", "anydesk": "anydesk", "rustdesk": "rustdesk", "localsend": "localsend",
  "raycast": "raycast", "rectangle": "rectangle", "stats": "apple", "maccy": "apple", "alttab": "apple", "hiddenbar": "apple", "appcleaner": "apple", "monitorcontrol": "apple", "keka": "apple",
  "cpuz": "cpuid", "hwinfo": "hwinfo", "rufus": "rufus", "ventoy": "ventoy", "nvidiaapp": "nvidia", "flatpak": "flatpak", "fastfetch": "linux", "timeshift": "linux", "gparted": "gnome", "gnometweaks": "gnome", "copyq": "qt",
  "clipack": "gnubash", "nettools": "linux", "steamdeck": "steamdeck",
}
cat = json.loads((ROOT / "web/catalog.json").read_text())
out = ROOT / "web/icons"; out.mkdir(exist_ok=True)
meta, miss = {}, []
for a in cat["apps"]:
    k = a["key"]
    ic = by_slug.get(MAP.get(k, "")) or by_title.get(re.sub(r"[^a-z0-9]", "", a["name"].lower().split(" (")[0]))
    if not ic:
        miss.append(f"{k} ({a['name']})"); continue
    svg = (PKG / "icons" / f"{ic['slug']}.svg").read_text()
    svg = svg.replace("<svg ", f'<svg fill="#{ic["hex"]}" ', 1)
    (out / f"{ic['slug']}.svg").write_text(svg)
    meta[k] = {"slug": ic["slug"], "hex": ic["hex"], "title": ic["title"]}
(out / "icons.json").write_text(json.dumps(meta, separators=(",", ":")))
print(f"logo: {len(meta)}/{len(cat['apps'])} aplikasi, {len(set(m['slug'] for m in meta.values()))} file SVG")
print("tanpa logo (monogram):", ", ".join(miss))
