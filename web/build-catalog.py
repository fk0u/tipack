#!/usr/bin/env python3
"""Bangun web/catalog.json dari isi windows/setup.ps1 dan macos/setup.sh.
Jalankan ulang setiap kali katalog di script berubah:  python3 web/build-catalog.py
"""
import json, re, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
ps1 = (ROOT / "windows/setup.ps1").read_text(encoding="utf-8-sig")
sh = (ROOT / "macos/setup.sh").read_text(encoding="utf-8")
lx = (ROOT / "linux/src/linux-parts.sh").read_text(encoding="utf-8")

apps, order = {}, []
# key macOS yang sama dengan key Windows
ALIAS = {"node": "nodejs", "iterm2": "iterm2"}

def get(key, name, cat, tip, rec):
    if key not in apps:
        apps[key] = {"key": key, "name": name, "cat": cat, "tip": tip, "rec": rec, "win": None, "mac": None, "linux": None, "profiles": []}
        order.append(key)
    a = apps[key]
    a["rec"] = a["rec"] or rec
    return a

# ---- Windows: key|Kategori|ID|Nama|Rek|Tooltip
win_raw = re.search(r"\$CatalogRaw = @'\n(.*?)\n'@", ps1, re.S).group(1)
for line in win_raw.splitlines():
    p = line.strip().split("|", 5)
    if len(p) < 6:
        continue
    key, cat, wid, name, rec, tip = p
    kind = "wsl" if wid.startswith("wsl:") else "feat" if wid.startswith("feat:") else "info" if wid.startswith("info:") else "winget"
    a = get(key, name, cat, tip, rec == "1")
    if kind == "winget":
        cmd = f"winget install --id {wid} -e"
    elif kind == "wsl":
        cmd = "wsl --install --no-distribution" if wid == "wsl:core" else f"wsl --install -d {wid[4:]}"
    elif kind == "feat":
        cmd = f"Enable-WindowsOptionalFeature -Online -FeatureName {wid[5:]} -All"
    else:
        cmd = None
    a["win"] = {"kind": kind, "id": wid.split(":", 1)[1] if kind != "winget" else wid, "cmd": cmd, "name": name}

# ---- macOS: key|Kategori|tipe|id|Nama|Rek|deteksi|Tooltip
mac_raw = re.search(r"^CATALOG_RAW='\n(.*?)\n'", sh, re.S | re.M).group(1)
for line in mac_raw.splitlines():
    p = line.strip().split("|", 7)
    if len(p) < 8:
        continue
    key, cat, typ, mid, name, rec, _det, tip = p
    key = ALIAS.get(key, key)
    a = get(key, name, cat, tip, rec == "1")
    if a["win"] is None:
        a["tip"] = tip
    cmd = {"formula": f"brew install {mid}", "cask": f"brew install --cask {mid}"}.get(typ)
    if typ == "custom":
        cmd = "(dipasang oleh installer TIPACK)"
    a["mac"] = {"kind": typ, "id": mid, "cmd": cmd, "name": name, "tip": tip}

# ---- Linux: key|Kategori|Nama|Rek|deteksi|apt|dnf|pacman|zypper|apk|flatpak|universal|Tooltip
PMCMD = {"apt": "sudo apt install {}", "dnf": "sudo dnf install {}", "pacman": "sudo pacman -S {}", "zypper": "sudo zypper install {}", "apk": "sudo apk add {}"}
lx_raw = re.search(r"^CATALOG_RAW='\n(.*?)\n'", lx, re.S | re.M).group(1)
for line in lx_raw.splitlines():
    p = line.strip().split("|", 12)
    if len(p) < 13:
        continue
    key, cat, name, rec, _det, *cols, flat, uni, tip = p
    a = get(key, name, cat, tip, rec == "1")
    if a["win"] is None and a["mac"] is None:
        a["tip"] = tip
    methods = {}
    for pm, v in zip(["apt", "dnf", "pacman", "zypper", "apk"], cols):
        if v == "-":
            continue
        if v.startswith("aur:"):
            methods[pm] = {"via": "AUR", "cmd": f"yay -S {v[4:]}"}
        elif v.startswith("sh:"):
            methods[pm] = {"via": "script/repo resmi", "cmd": "(dipasang oleh installer TIPACK)"}
        else:
            methods[pm] = {"via": pm, "cmd": PMCMD[pm].format(" ".join(t.split("/")[0] for t in v.split()))}
    if flat != "-":
        methods["flatpak"] = {"via": "Flathub", "cmd": f"flatpak install flathub {flat}"}
    info = uni[5:] if uni.startswith("info:") else None
    if uni.startswith("sh:") and not methods:
        methods["semua"] = {"via": "script resmi", "cmd": "(dipasang oleh installer TIPACK)"}
    if not methods and not info:
        continue
    a["linux"] = {"kind": "info" if (info and not methods) else "multi", "id": info or "", "name": name, "methods": methods}

# ---- Profil
profiles = []
for m in re.finditer(r"@\{ K = '(\w+)'; N = '([^']+)'; T = '([^']+)'\s*;?\s*L = '([^']+)' \}", ps1):
    k, n, t, l = m.groups()
    profiles.append({"key": k, "name": n, "desc": t})
    for key in l.split(","):
        if key in apps:
            apps[key]["profiles"].append(k)
for m in re.finditer(r'^"(\w+)\|([^|]+)\|([^|]+)\|([^"]+)"$', sh, re.M):
    k, _n, _t, l = m.groups()
    for key in l.split():
        key = ALIAS.get(key, key)
        if key in apps and k not in apps[key]["profiles"]:
            apps[key]["profiles"].append(k)

for m in re.finditer(r'^"(\w+)\|([^|]+)\|([^|]+)\|([^"]+)"$', lx, re.M):
    k, _n, _t, l = m.groups()
    for key in l.split():
        if key in apps and k not in apps[key]["profiles"]:
            apps[key]["profiles"].append(k)

cats = []
for k in order:
    if apps[k]["cat"] not in cats:
        cats.append(apps[k]["cat"])

out = {"apps": [apps[k] for k in order], "categories": cats, "profiles": profiles,
       "counts": {"total": len(order), "win": sum(1 for k in order if apps[k]["win"]), "mac": sum(1 for k in order if apps[k]["mac"]), "linux": sum(1 for k in order if apps[k]["linux"])}}
dst = pathlib.Path(__file__).resolve().parent / "catalog.json"
dst.write_text(json.dumps(out, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
print(f"catalog.json: {out['counts']} · {len(cats)} kategori · {len(profiles)} profil")

# ---- docs/katalog.md (dokumentasi daftar aplikasi, dibuat otomatis)
def md_cell(a, o):
    d = a[o]
    if not d:
        return "—"
    if d["kind"] == "info":
        return "manual"
    if o == "linux":
        return " · ".join(sorted({m["via"].split("/")[0] for m in d["methods"].values()}))
    return {"winget": "winget", "wsl": "WSL", "feat": "fitur Windows", "formula": "brew", "cask": "brew cask", "custom": "installer"}.get(d["kind"], d["kind"])

prof_name = {p["key"]: p["name"] for p in profiles}
L = ["# Katalog Aplikasi", "",
     "> File ini dibuat otomatis oleh `web/build-catalog.py` dari isi ketiga installer. Jangan diedit manual.", "",
     f"Total **{out['counts']['total']}** aplikasi unik: Windows {out['counts']['win']}, macOS {out['counts']['mac']}, Linux {out['counts']['linux']}.", "",
     "Legenda: ★ = rekomendasi · `—` = tidak tersedia di OS itu · `manual` = download manual (link dibuka di akhir instalasi).", "",
     "Versi interaktif dengan pencarian: https://tipack.kousozo.tech/katalog", "", "## Daftar isi", ""]
L += [f"- [{c}](#{re.sub(r'[^a-z0-9 -]', '', c.lower()).replace(' ', '-')})" for c in cats]
for c in cats:
    L += ["", f"## {c}", "", "| Aplikasi | Windows | macOS | Linux | Keterangan |", "|---|---|---|---|---|"]
    for k in order:
        a = apps[k]
        if a["cat"] != c:
            continue
        tip = a["tip"].replace("|", "/")
        L.append(f"| {'★ ' if a['rec'] else ''}**{a['name']}** | {md_cell(a, 'win')} | {md_cell(a, 'mac')} | {md_cell(a, 'linux')} | {tip} |")
L += ["", "## Profil", "", "| Preset | Nama | Isi |", "|---|---|---|"]
for p in profiles:
    members = [apps[k]["name"] for k in order if p["key"] in apps[k]["profiles"]]
    L.append(f"| `{p['key']}` | {p['name']} | {', '.join(members)} |")
docs = ROOT / "docs"
docs.mkdir(exist_ok=True)
(docs / "katalog.md").write_text("\n".join(L) + "\n", encoding="utf-8")
print("docs/katalog.md ditulis")
