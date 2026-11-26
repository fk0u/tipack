#!/bin/bash
# =====================================================================================
#  DEVSETUP IF v2 - Installer interaktif untuk Mahasiswa Teknik Informatika & Abang IT (macOS)
#  Kompatibel bash 3.2 bawaan macOS, Intel & Apple Silicon. Pakai Homebrew.
#  Navigasi: panah atas/bawah (atau j/k), Spasi = centang, Enter = lanjut, Esc/q = kembali.
#
#  Jalankan:   chmod +x setup.sh && ./setup.sh
#  Langsung:   ./setup.sh --preset starter     (tanpa menu)
#              ./setup.sh --no-anim
# =====================================================================================

PRESET=""; NOANIM=0; INSTALL_KEYS=""; SELFTEST=0
while [ $# -gt 0 ]; do case "$1" in --preset) PRESET="$2"; shift ;; --install) INSTALL_KEYS="$2"; shift ;; --self-test) SELFTEST=1 ;; --no-anim) NOANIM=1 ;; esac; shift; done
TEST_MODE=0; KEYQ=(); KEYI=0
if [ -n "$TIPACK_KEYS" ]; then IFS=',' read -r -a KEYQ <<< "$TIPACK_KEYS"; TEST_MODE=1; fi
[ $SELFTEST = 1 ] && TEST_MODE=1
[ $TEST_MODE = 1 ] && NOANIM=1
UNATTENDED=0; { [ -n "$INSTALL_KEYS" ] || [ -n "$PRESET" ]; } && UNATTENDED=1
INSTALL_FAIL=0

[ "$(uname)" = Darwin ] || { echo "Script ini khusus macOS. Untuk Windows pakai windows/setup.ps1"; exit 1; }
export LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1 HOMEBREW_NO_INSTALL_CLEANUP=1
ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG="$ROOT/devsetup-log-$(date +%Y%m%d-%H%M%S).txt"
# folder script tidak bisa ditulisi (flashdisk read-only, folder milik root, dll) -> log ke folder temp
( : >> "$LOG" ) 2>/dev/null || { LOG="${TMPDIR:-/tmp}/devsetup-log-$(date +%Y%m%d-%H%M%S).txt"; ROOT="${TMPDIR:-/tmp}"; }

E=$'\e'; R0="$E[0m"; B="$E[1m"; RED="$E[31m"; GRN="$E[32m"; YEL="$E[33m"; BLU="$E[34m"; MAG="$E[35m"; CYN="$E[36m"
WHT="$E[97m"; GRY="$E[37m"; DIM="$E[90m"; ORG="$E[38;5;208m"; PNK="$E[38;5;213m"; INV="$E[7m"

# =====================================================================================
#  KATALOG   key | Kategori | tipe (formula/cask/info/custom) | id | Nama | Rek | deteksi | Tooltip
#  deteksi: "Nama App" (cek /Applications/Nama App.app), "cmd:perintah", "dir:path", atau kosong
# =====================================================================================
CATALOG_RAW='
chrome|Browser|cask|google-chrome|Google Chrome|1|Google Chrome|Browser paling umum dengan DevTools terlengkap. Wajib untuk debugging web. Safari sudah bawaan Mac.
firefox|Browser|cask|firefox|Mozilla Firefox|0|Firefox|Open source dan menjaga privasi. DevTools CSS Grid/Flexbox paling enak. Cocok jadi browser kedua untuk tes kompatibilitas.
firefoxdev|Browser|cask|firefox@developer-edition|Firefox Developer Edition|0|Firefox Developer Edition|Firefox khusus developer dengan fitur DevTools eksperimental.
brave|Browser|cask|brave-browser|Brave|0|Brave Browser|Berbasis Chromium dengan adblock bawaan, lebih hemat RAM dari Chrome.
arc|Browser|cask|arc|Arc|0|Arc|Browser dengan sidebar dan workspace, favorit banyak developer Mac.
unarchiver|Arsip & File|cask|the-unarchiver|The Unarchiver|1|The Unarchiver|Buka rar/7z/zip/iso dan lainnya. Gratis. Pengganti WinRAR di Mac. REKOMENDASI.
keka|Arsip & File|cask|keka|Keka|0|Keka|Bisa MEMBUAT arsip 7z/zip dengan password, bukan cuma mengekstrak.
raycast|Arsip & File|cask|raycast|Raycast|1|Raycast|Pengganti Spotlight super lengkap: launcher, clipboard history, window manager, snippet, kalkulator.
appcleaner|Arsip & File|cask|appcleaner|AppCleaner|1|AppCleaner|Uninstall aplikasi Mac sampai bersih ke file sisa.
localsend|Arsip & File|cask|localsend|LocalSend|1|LocalSend|Kirim file HP Android/Windows ke Mac lewat WiFi, seperti AirDrop lintas platform.
iterm2|Terminal & Shell|cask|iterm2|iTerm2|1|iTerm|Terminal Mac paling populer: split pane, pencarian, profil. Lebih lengkap dari Terminal bawaan.
warp|Terminal & Shell|cask|warp|Warp|0|Warp|Terminal modern dengan AI dan blok perintah ala IDE.
ghostty|Terminal & Shell|cask|ghostty|Ghostty|0|Ghostty|Terminal super cepat berbasis GPU, minimalis.
ohmyzsh|Terminal & Shell|custom|ohmyzsh|Oh My Zsh + autosuggest + syntax highlight|1|dir:~/.oh-my-zsh|Framework zsh dengan tema dan plugin, plus saran perintah otomatis dan pewarnaan perintah.
starship|Terminal & Shell|formula|starship|Starship prompt|0|cmd:starship|Prompt cantik yang menampilkan branch git dan versi bahasa. Butuh Nerd Font.
nerdfont|Terminal & Shell|cask|font-jetbrains-mono-nerd-font|JetBrains Mono Nerd Font|0||Font coding dengan ligature dan ikon untuk terminal modern.
clipack|Terminal & Shell|formula|wget tree htop btop jq tldr ripgrep bat eza fzf zoxide|CLI Power Pack (wget, htop, jq, tldr, dll)|1|cmd:tldr|Paket 11 tool terminal wajib: wget, tree, htop, btop, jq, tldr (contoh perintah), ripgrep, bat, eza, fzf, zoxide.
vscode|Editor Kode|cask|visual-studio-code|Visual Studio Code|1|Visual Studio Code|Editor paling populer: ringan dan ekstensinya melimpah. Standar mahasiswa IF.
cursor|Editor Kode|cask|cursor|Cursor|0|Cursor|Fork VS Code dengan AI terintegrasi. Ada tier gratis.
antigravity|Editor Kode|info|https://antigravity.google|Google Antigravity|0|Antigravity|IDE agentic dari Google (berbasis VS Code). Download manual dari situs resminya.
zed|Editor Kode|cask|zed|Zed|0|Zed|Editor super cepat (Rust) dengan kolaborasi realtime dan AI.
sublime|Editor Kode|cask|sublime-text|Sublime Text|0|Sublime Text|Editor ringan dan sangat cepat.
neovim|Editor Kode|formula|neovim|Neovim|0|cmd:nvim|Editor di terminal untuk yang mau jadi keyboard warrior. Kurva belajar tinggi.
intellij|IDE|cask|intellij-idea-ce|IntelliJ IDEA Community|0|IntelliJ IDEA CE|IDE terbaik untuk Java/Kotlin, wajib untuk matkul PBO. Ultimate gratis lewat JetBrains Student Pack.
pycharm|IDE|cask|pycharm-ce|PyCharm Community|0|PyCharm CE|IDE khusus Python dengan debugger dan pengelola virtualenv.
toolbox|IDE|cask|jetbrains-toolbox|JetBrains Toolbox|0|JetBrains Toolbox|Satu aplikasi untuk install/update semua IDE JetBrains. Bagus kalau punya lisensi Student.
netbeans|IDE|cask|netbeans|Apache NetBeans|0|Apache NetBeans|IDE Java yang masih sering dipakai dosen untuk Java Swing/GUI.
xcode|IDE|info|https://apps.apple.com/app/xcode/id497799835|Xcode (App Store)|0|Xcode|Wajib untuk develop aplikasi iOS/macOS dan Flutter iOS. Ukuran 10GB+, install dari App Store.
gcc|Bahasa & Runtime|formula|gcc|GCC (g++ asli GNU)|1|cmd:gcc-15|Di Mac, perintah g++ sebenarnya clang. GCC asli dibutuhkan kalau dosen memakai bits/stdc++.h. Panggil dengan g++-15.
cmake|Bahasa & Runtime|formula|cmake|CMake|0|cmd:cmake|Build system untuk proyek C/C++.
python|Bahasa & Runtime|formula|python|Python 3 (terbaru)|1|cmd:python3|Bahasa wajib untuk algoritma, data science, AI dan scripting. Alias python/pip disiapkan otomatis.
uv|Bahasa & Runtime|formula|uv|uv (Python package manager)|0|cmd:uv|Pengganti pip + venv yang 10-100x lebih cepat.
miniconda|Bahasa & Runtime|cask|miniconda|Miniconda|0|cmd:conda|Manajer environment Python untuk data science/ML.
node|Bahasa & Runtime|formula|node@22|Node.js 22 LTS|1|cmd:node|Runtime JavaScript + npm. Wajib untuk web dev. PATH diatur otomatis.
fnm|Bahasa & Runtime|formula|fnm|fnm (Node version manager)|0|cmd:fnm|Untuk gonta-ganti versi Node.js. Pilih ini ATAU Node.js LTS.
bun|Bahasa & Runtime|formula|oven-sh/bun/bun|Bun|0|cmd:bun|Runtime JS super cepat sekaligus package manager.
jdk|Bahasa & Runtime|cask|temurin@21|Java JDK 21 (Temurin)|1|cmd:javac|JDK LTS gratis. Wajib untuk PBO/Java dan Android.
jdk17|Bahasa & Runtime|cask|temurin@17|Java JDK 17 (Temurin)|0||Versi LTS lama, kadang diminta dosen atau proyek lama.
go|Bahasa & Runtime|formula|go|Go|0|cmd:go|Bahasa backend modern: cepat dan simpel.
rust|Bahasa & Runtime|formula|rustup|Rust (rustup)|0|cmd:rustup|Bahasa sistem yang aman memori. Jalankan rustup-init setelah install.
php|Bahasa & Runtime|formula|php|PHP|0|cmd:php|PHP CLI terbaru.
composer|Bahasa & Runtime|formula|composer|Composer|0|cmd:composer|Package manager PHP, wajib untuk Laravel.
dotnet|Bahasa & Runtime|cask|dotnet-sdk|.NET SDK|0|cmd:dotnet|Untuk C#, ASP.NET dan Blazor.
r|Bahasa & Runtime|cask|r|R|0|R|Bahasa statistik untuk matkul Statistika/Data Mining.
cocoapods|Bahasa & Runtime|formula|cocoapods|CocoaPods|0|cmd:pod|Dependency manager iOS, dibutuhkan Flutter untuk build iOS.
herd|Web Server & Database|cask|herd|Laravel Herd|0|Herd|Server PHP/Laravel paling mudah di Mac: PHP, nginx dan domain .test otomatis. Favorit anak Laravel.
mamp|Web Server & Database|cask|mamp|MAMP|0|MAMP|Apache + MySQL + PHP, mirip XAMPP versi Mac. Cocok untuk praktikum Pemrograman Web.
xampp|Web Server & Database|info|https://www.apachefriends.org/download.html|XAMPP (download manual)|0|XAMPP|Sama seperti di lab kampus. Versi Mac di-download manual dari Apache Friends.
dbngin|Web Server & Database|cask|dbngin|DBngin|1|DBngin|Jalankan MySQL/PostgreSQL/Redis dengan satu klik, bisa banyak versi. Paling praktis di Mac.
mysql|Web Server & Database|formula|mysql@8.4|MySQL 8.4 (brew)|0|cmd:mysql|MySQL server lewat Homebrew. Start: brew services start mysql@8.4
postgres|Web Server & Database|formula|postgresql@16|PostgreSQL 16 (brew)|0|cmd:psql|Database relasional open source paling canggih. Start: brew services start postgresql@16
sqlite|Web Server & Database|formula|sqlite|SQLite|0||Database satu file untuk aplikasi kecil dan mobile.
dbeaver|Web Server & Database|cask|dbeaver-community|DBeaver Community|1|DBeaver|Satu aplikasi untuk SEMUA database. Bisa bikin ERD otomatis.
tableplus|Web Server & Database|cask|tableplus|TablePlus|0|TablePlus|Client database dengan UI paling cantik. Gratis dibatasi 2 tab.
sequelace|Web Server & Database|cask|sequel-ace|Sequel Ace|0|Sequel Ace|Client MySQL/MariaDB gratis, native dan ringan.
workbench|Web Server & Database|cask|mysqlworkbench|MySQL Workbench|0|MySQLWorkbench|Tool resmi MySQL untuk desain ERD.
compass|Web Server & Database|cask|mongodb-compass|MongoDB Compass|0|MongoDB Compass|GUI untuk MongoDB.
git|Git & API|formula|git|Git (terbaru)|1|cmd:git|Git versi terbaru (bawaan Xcode CLT biasanya versi lama).
ghdesktop|Git & API|cask|github|GitHub Desktop|1|GitHub Desktop|Git versi GUI, cocok untuk pemula.
ghcli|Git & API|formula|gh|GitHub CLI (gh)|1|cmd:gh|Login GitHub, clone, bikin repo dan PR dari terminal.
lazygit|Git & API|formula|lazygit|lazygit|0|cmd:lazygit|UI Git di terminal.
postman|Git & API|cask|postman|Postman|1|Postman|Tes REST API. Standar industri untuk matkul Web Service/Backend.
bruno|Git & API|cask|bruno|Bruno|0|Bruno|Alternatif Postman yang open source dan offline.
orbstack|DevOps & Cloud|cask|orbstack|OrbStack|1|OrbStack|Docker + Linux VM untuk Mac. Jauh lebih ringan dan cepat dari Docker Desktop. Juga bisa jadi pengganti WSL di Mac.
docker|DevOps & Cloud|cask|docker|Docker Desktop|0|Docker|Docker resmi. Pilih ini ATAU OrbStack, jangan keduanya.
kubectl|DevOps & Cloud|formula|kubernetes-cli|kubectl|0|cmd:kubectl|CLI untuk Kubernetes.
terraform|DevOps & Cloud|formula|hashicorp/tap/terraform|Terraform|0|cmd:terraform|Infrastructure as Code.
awscli|DevOps & Cloud|formula|awscli|AWS CLI|0|cmd:aws|CLI Amazon Web Services.
gcloud|DevOps & Cloud|cask|google-cloud-sdk|Google Cloud SDK|0|cmd:gcloud|CLI Google Cloud.
azcli|DevOps & Cloud|formula|azure-cli|Azure CLI|0|cmd:az|CLI Azure. Mahasiswa dapat kredit gratis lewat Azure for Students.
ngrok|DevOps & Cloud|cask|ngrok|ngrok|0|cmd:ngrok|Membuat localhost bisa diakses publik untuk demo.
ollama|AI & Data|cask|ollama|Ollama|0|Ollama|Jalankan LLM lokal. Apple Silicon + RAM 16GB sangat nyaman.
lmstudio|AI & Data|cask|lm-studio|LM Studio|0|LM Studio|GUI untuk download dan chat dengan LLM lokal (dukungan MLX di Apple Silicon).
claude|AI & Data|cask|claude|Claude Desktop|0|Claude|Aplikasi desktop Claude.
rstudio|AI & Data|cask|rstudio|RStudio|0|RStudio|IDE untuk R.
androidstudio|Mobile & Game|cask|android-studio|Android Studio|0|Android Studio|IDE resmi Android + emulator (di Apple Silicon emulatornya cepat).
flutter|Mobile & Game|cask|flutter|Flutter SDK|0|cmd:flutter|Framework mobile cross-platform. Untuk build iOS butuh Xcode + CocoaPods.
unity|Mobile & Game|cask|unity-hub|Unity Hub|0|Unity Hub|Engine game 2D/3D paling populer.
godot|Mobile & Game|cask|godot|Godot Engine|0|Godot|Engine game open source, ringan.
blender|Mobile & Game|cask|blender|Blender|0|Blender|Modeling dan animasi 3D gratis.
arduino|Mobile & Game|cask|arduino-ide|Arduino IDE|0|Arduino IDE|Untuk matkul IoT/Sistem Embedded.
packettracer|Jaringan & Keamanan|info|https://www.netacad.com/resources/lab-downloads|Cisco Packet Tracer|0|Cisco Packet Tracer|Simulasi jaringan Cisco. Download manual (butuh akun NetAcad gratis).
wireshark|Jaringan & Keamanan|cask|wireshark|Wireshark|0|Wireshark|Analisis paket jaringan. Wajib untuk matkul Jarkom/Keamanan.
nmap|Jaringan & Keamanan|formula|nmap|Nmap|0|cmd:nmap|Port scanner. Pakai hanya di jaringan sendiri atau yang sudah diizinkan.
termius|Jaringan & Keamanan|cask|termius|Termius|0|Termius|Klien SSH cantik dengan SFTP. Gratis untuk mahasiswa (GitHub Student Pack).
cyberduck|Jaringan & Keamanan|cask|cyberduck|Cyberduck|0|Cyberduck|Klien FTP/SFTP/S3 untuk upload ke server.
burp|Jaringan & Keamanan|cask|burp-suite|Burp Suite Community|0|Burp Suite Community Edition|Proxy untuk pentest aplikasi web. Gunakan secara etis.
utm|Virtualisasi & Linux|cask|utm|UTM|1|UTM|Mesin virtual gratis untuk Mac (Apple Silicon & Intel). Install Ubuntu/Kali/Windows ARM.
multipass|Virtualisasi & Linux|cask|multipass|Multipass|0|cmd:multipass|VM Ubuntu instan dari terminal (multipass launch). Cocok untuk matkul SO/Server.
figma|Desain & Multimedia|cask|figma|Figma|1|Figma|Desain UI/UX dan prototipe. Ada Figma Education gratis.
drawio|Desain & Multimedia|cask|drawio|draw.io Desktop|1|draw.io|Flowchart, UML, ERD dan DFD offline. Wajib untuk matkul RPL/Analisis Sistem.
gimp|Desain & Multimedia|cask|gimp|GIMP|0|GIMP|Edit foto gratis, alternatif Photoshop.
inkscape|Desain & Multimedia|cask|inkscape|Inkscape|0|Inkscape|Desain vektor gratis.
obs|Desain & Multimedia|cask|obs|OBS Studio|0|OBS|Rekam layar dan live streaming untuk video demo tugas.
iina|Desain & Multimedia|cask|iina|IINA|1|IINA|Video player modern untuk Mac, semua format.
discord|Komunikasi|cask|discord|Discord|1|Discord|Grup kelas, komunitas programmer, voice call kerja kelompok.
zoom|Komunikasi|cask|zoom|Zoom|1|zoom.us|Kuliah online dan sidang.
telegram|Komunikasi|cask|telegram|Telegram|0|Telegram|Banyak grup/komunitas IT.
whatsapp|Komunikasi|cask|whatsapp|WhatsApp|0|WhatsApp|Grup kelas dan koordinasi tugas.
slack|Komunikasi|cask|slack|Slack|0|Slack|Komunikasi tim ala industri dan magang.
teams|Komunikasi|cask|microsoft-teams|Microsoft Teams|0|Microsoft Teams|Dipakai beberapa kampus untuk kelas online.
notion|Kuliah & Produktivitas|cask|notion|Notion|0|Notion|Catatan, task manager dan wiki. Plan Education gratis.
obsidian|Kuliah & Produktivitas|cask|obsidian|Obsidian|0|Obsidian|Catatan Markdown offline dengan graph view.
zotero|Kuliah & Produktivitas|cask|zotero|Zotero|0|Zotero|Manajer referensi dan sitasi otomatis untuk skripsi.
office|Kuliah & Produktivitas|info|https://www.office.com|Microsoft 365 (email kampus)|0|Microsoft Word|Biasanya GRATIS pakai email kampus. Login di office.com lalu Install Apps.
libreoffice|Kuliah & Produktivitas|cask|libreoffice|LibreOffice|0|LibreOffice|Office gratis. Tidak perlu kalau sudah punya Microsoft 365.
gdrive|Kuliah & Produktivitas|cask|google-drive|Google Drive|0|Google Drive|Sinkronisasi file tugas ke cloud.
rectangle|Utilitas Sistem|cask|rectangle|Rectangle|1|Rectangle|Atur jendela kiri/kanan dengan shortcut, seperti Snap di Windows. WAJIB.
alttab|Utilitas Sistem|cask|alt-tab|AltTab|0|AltTab|Alt-Tab ala Windows dengan preview jendela.
stats|Utilitas Sistem|cask|stats|Stats|1|Stats|Monitor CPU, RAM, suhu dan jaringan di menu bar.
maccy|Utilitas Sistem|cask|maccy|Maccy|0|Maccy|Riwayat clipboard (copy-paste) yang ringan.
hiddenbar|Utilitas Sistem|cask|hiddenbar|Hidden Bar|0|Hidden Bar|Sembunyikan ikon menu bar yang terlalu ramai.
monitorcontrol|Utilitas Sistem|cask|monitorcontrol|MonitorControl|0|MonitorControl|Atur brightness/volume monitor eksternal dari keyboard.
'

i=0
while IFS='|' read -r k cat typ id name rec det tip; do
  [ -z "$k" ] && continue
  K_KEY[$i]=$k; K_CAT[$i]=$cat; K_TYPE[$i]=$typ; K_ID[$i]=$id; K_NAME[$i]=$name; K_REC[$i]=$rec; K_DET[$i]=$det; K_TIP[$i]=$tip
  INST[$i]=0; CART[$i]=0; eval "IDX_$k=$i"
  i=$((i+1))
done <<< "$CATALOG_RAW"
NCAT=$i
CATS=(); for ((i=0;i<NCAT;i++)); do f=0; for c in "${CATS[@]}"; do [ "$c" = "${K_CAT[$i]}" ] && f=1; done; [ $f = 0 ] && CATS+=("${K_CAT[$i]}"); done
HEAVY=" docker androidstudio unity ollama lmstudio "
ix() { eval "echo \${IDX_$1}"; }

PROFILES=(
"starter|Starter Pack Mahasiswa IF (Semester 1-2)|Paket aman untuk semua mahasiswa IF baru: browser, editor, compiler, Python, Java, Node, Git, database, tool diagram dan komunikasi kuliah.|chrome unarchiver raycast appcleaner localsend iterm2 ohmyzsh clipack vscode gcc python node jdk git ghdesktop ghcli dbngin dbeaver postman drawio figma discord zoom rectangle stats iina"
"cpp|C/C++ & Algoritma|Untuk praktikum Dasar Pemrograman, Algoritma dan Struktur Data.|gcc cmake vscode git"
"java|Java & PBO|Untuk matkul Pemrograman Berorientasi Objek.|jdk intellij netbeans vscode git"
"web|Web Developer (Fullstack)|Laravel/PHP, Node.js/React, database, API testing, container dan tunneling.|chrome firefoxdev vscode node bun git ghcli herd composer dbngin tableplus postman orbstack figma ngrok"
"mobile|Mobile Developer (Android/iOS/Flutter)|Android Studio, Flutter, Xcode dan CocoaPods.|androidstudio jdk flutter xcode cocoapods vscode git ghcli figma postman"
"data|Data Science & AI|Python + uv/conda, R/RStudio, database dan LLM lokal.|python uv miniconda r rstudio vscode git dbeaver postgres ollama lmstudio"
"net|Jaringan & Keamanan Siber|Packet Tracer, Wireshark, Nmap, SSH/SFTP, Burp dan VM untuk Kali Linux.|packettracer wireshark nmap termius cyberduck burp utm"
"devops|DevOps & Cloud|Container, Kubernetes, Terraform dan CLI cloud.|orbstack kubectl terraform awscli gcloud azcli git ghcli lazygit vscode multipass"
"game|Game Developer|Unity, Godot, Blender dan tool aset.|unity godot blender vscode gimp inkscape git obs"
"design|UI/UX & Konten Kreator|Figma, desain vektor/raster, rekam layar.|figma drawio gimp inkscape obs iina blender"
"tech|Abang IT / Power User Mac|Toolkit wajib Mac: launcher, window manager, monitor, clipboard, uninstaller.|raycast rectangle alttab stats maccy hiddenbar appcleaner unarchiver keka localsend clipack monitorcontrol"
)

WIZ=(
"Browser utama?|s|chrome brave firefox arc|Safari sudah bawaan Mac. Chrome = DevTools terlengkap, Brave = hemat RAM + adblock, Arc = workflow modern."
"Aplikasi ekstrak/kompres arsip (pengganti WinRAR)?|s|unarchiver keka|The Unarchiver gratis untuk membuka semua format. Keka kalau perlu MEMBUAT 7z/zip berpassword."
"Terminal & shell?|m|iterm2 warp ghostty ohmyzsh starship nerdfont clipack|iTerm2 + Oh My Zsh + CLI Power Pack = setup terminal standar developer Mac."
"Editor kode? (boleh lebih dari satu)|m|vscode cursor antigravity zed sublime neovim|VS Code cukup untuk 90% matkul. Cursor/Antigravity kalau mau coding dibantu AI."
"IDE tambahan sesuai matkul?|m|intellij pycharm toolbox netbeans xcode|Java/PBO -> IntelliJ/NetBeans. iOS -> Xcode (dari App Store)."
"Bahasa pemrograman & runtime?|m|gcc python uv node fnm bun jdk jdk17 go rust php composer dotnet r cmake miniconda|Minimal untuk mahasiswa IF: GCC, Python, Java JDK dan Node.js."
"Web server lokal (PHP/MySQL)?|s|dbngin herd mamp xampp|DBngin = database 1 klik. Herd = PHP/Laravel paling mudah. MAMP/XAMPP = mirip lab kampus."
"Database & client database?|m|dbeaver tableplus sequelace workbench mysql postgres sqlite compass|DBeaver bisa untuk semua jenis database. Sequel Ace ringan khusus MySQL."
"Git & API tools?|m|git ghdesktop ghcli lazygit postman bruno|Git wajib. GitHub Desktop membantu pemula. Postman untuk tes API."
"Container / Linux di Mac (pengganti WSL)?|s|orbstack docker utm multipass|Di Mac tidak ada WSL. OrbStack = Docker + Linux VM paling ringan (rekomendasi). UTM untuk VM full GUI."
"Virtual machine tambahan?|m|utm multipass|UTM untuk install Ubuntu/Kali/Windows ARM. Multipass untuk VM Ubuntu instan dari terminal."
"Jaringan & keamanan?|m|packettracer wireshark nmap termius cyberduck burp|Untuk matkul Jaringan Komputer dan Keamanan Informasi. Gunakan secara etis."
"DevOps & Cloud?|m|kubectl terraform awscli gcloud azcli ngrok|Opsional. Ngrok berguna untuk demo localhost ke dosen."
"AI di laptop?|m|ollama lmstudio claude|Apple Silicon sangat bagus untuk LLM lokal. RAM Mac ini: __RAM__ GB."
"Mobile & game development?|m|androidstudio flutter cocoapods unity godot blender arduino|Android Studio untuk Android, Flutter untuk cross-platform (iOS butuh Xcode)."
"Desain & multimedia?|m|figma drawio gimp inkscape obs iina|draw.io wajib untuk UML/ERD/flowchart. Figma untuk tugas UI/UX."
"Komunikasi?|m|discord zoom whatsapp telegram slack teams|Sesuaikan dengan platform kelas dan dosen."
"Kuliah & produktivitas?|m|notion obsidian zotero office libreoffice gdrive|Microsoft 365 biasanya gratis dari email kampus. Zotero menyelamatkan saat skripsi."
"Utilitas Mac?|m|raycast rectangle alttab stats maccy hiddenbar appcleaner localsend monitorcontrol|Rectangle + Raycast + Stats = trio wajib pengguna Mac."
)

VSEXT=(
"ms-vscode.cpptools-extension-pack|C/C++ Extension Pack|1|IntelliSense, debugging dan CMake untuk C/C++."
"formulahendry.code-runner|Code Runner|1|Tombol Run untuk menjalankan file C/C++/Python/Java/JS sekali klik."
"ms-python.python|Python|1|Dukungan Python lengkap: Pylance, debugger, venv."
"ms-toolsai.jupyter|Jupyter|0|Notebook .ipynb di VS Code."
"vscjava.vscode-java-pack|Extension Pack for Java|1|Java: Maven/Gradle, debugger, test runner."
"esbenp.prettier-vscode|Prettier|1|Format otomatis JS/TS/HTML/CSS/JSON."
"dbaeumer.vscode-eslint|ESLint|0|Linting JavaScript/TypeScript."
"ritwickdey.LiveServer|Live Server|1|Preview HTML dengan auto-reload."
"formulahendry.auto-rename-tag|Auto Rename Tag|0|Tag penutup HTML ikut berubah otomatis."
"bradlc.vscode-tailwindcss|Tailwind CSS IntelliSense|0|Autocomplete class Tailwind."
"dsznajder.es7-react-js-snippets|ES7+ React Snippets|0|Snippet React (rafce, useState...)."
"bmewburn.vscode-intelephense-client|PHP Intelephense|0|IntelliSense PHP terbaik untuk Laravel."
"eamodio.gitlens|GitLens|1|Blame per baris dan riwayat commit."
"mhutchie.git-graph|Git Graph|1|Visualisasi branch dan commit."
"ms-azuretools.vscode-docker|Docker|0|Kelola container dan Dockerfile."
"ms-vscode-remote.remote-ssh|Remote - SSH|0|Coding langsung di server lewat SSH."
"mtxr.sqltools|SQLTools|0|Query database dari VS Code."
"humao.rest-client|REST Client|0|Tes API dari file .http."
"usernamehw.errorlens|Error Lens|1|Error dan warning tampil langsung di baris kode."
"christian-kohler.path-intellisense|Path Intellisense|1|Autocomplete nama file/path."
"streetsidesoftware.code-spell-checker|Code Spell Checker|0|Cek typo di kode."
"yzhang.markdown-all-in-one|Markdown All in One|0|Shortcut dan preview README.md."
"hediet.vscode-drawio|Draw.io Integration|0|Edit diagram draw.io di VS Code."
"Dart-Code.flutter|Flutter|0|Dukungan Flutter/Dart."
"MS-vsliveshare.vsliveshare|Live Share|0|Ngoding bareng teman secara realtime."
"GitHub.copilot|GitHub Copilot|0|AI autocomplete. Gratis untuk mahasiswa lewat GitHub Student Pack."
"PKief.material-icon-theme|Material Icon Theme|1|Ikon file yang cantik."
"zhuangtongfa.material-theme|One Dark Pro|0|Tema gelap paling populer."
)

BANNER=(
'██████╗ ███████╗██╗   ██╗███████╗███████╗████████╗██╗   ██╗██████╗ '
'██╔══██╗██╔════╝██║   ██║██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗'
'██║  ██║█████╗  ██║   ██║███████╗█████╗     ██║   ██║   ██║██████╔╝'
'██║  ██║██╔══╝  ╚██╗ ██╔╝╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ '
'██████╔╝███████╗ ╚████╔╝ ███████║███████╗   ██║   ╚██████╔╝██║     '
'╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     '
)
BCOL=("$E[38;5;201m" "$E[38;5;165m" "$E[38;5;129m" "$E[38;5;93m" "$E[38;5;57m" "$E[38;5;33m")

# =====================================================================================
#  UTILITAS
# =====================================================================================
log() { echo "[$(date +%H:%M:%S)] $*" >> "$LOG"; }
cleanup() { printf '%s' "$E[?25h$E[?7h$R0"; stty echo 2>/dev/null; [ -n "$SUDO_PID" ] && kill "$SUDO_PID" 2>/dev/null; }
trap cleanup EXIT
trap 'cleanup; echo; exit 130' INT
hide_cur() { printf '%s' "$E[?25l"; }
show_cur() { printf '%s' "$E[?25h"; }
pause_key() { printf '\n  %sTekan tombol apa saja untuk kembali...%s' "$DIM" "$R0"; read_key; }
ask() { # ask "pertanyaan" "default" -> REPLY_VAL
  if [ "$TEST_MODE" = 1 ] || [ "$UNATTENDED" = 1 ]; then REPLY_VAL="$2"; log "ASK $1 -> $2"; return; fi
  show_cur; printf '  %s?%s %s%s%s' "$MAG" "$R0" "$WHT" "$1" "$R0"; [ -n "$2" ] && printf ' %s[%s]%s' "$DIM" "$2" "$R0"; printf ': '
  IFS= read -r REPLY_VAL; [ -z "$REPLY_VAL" ] && REPLY_VAL="$2"
}
yesno() { ask "$1 (y/n)" "${2:-y}"; case "$REPLY_VAL" in y|Y|ya|yes) return 0 ;; *) return 1 ;; esac; }
repeat() { local s="" n=$2; while [ $n -gt 0 ]; do s="$s$1"; n=$((n-1)); done; printf '%s' "$s"; }
human() { local b=${1:-0}; if [ "$b" -ge 1073741824 ]; then awk -v b="$b" 'BEGIN{printf "%.1f GB", b/1073741824}'; elif [ "$b" -ge 1048576 ]; then echo "$((b/1048576)) MB"; else echo "$((b/1024)) KB"; fi; }
dir_bytes() { local t=0 p k; for p in "$@"; do [ -e "$p" ] || continue; k=$(du -sk "$p" 2>/dev/null | awk '{print $1}'); t=$((t + ${k:-0}*1024)); done; echo $t; }
bar() { local d=$1 t=$2 w=${3:-34} f=0 p=0; [ "$t" -gt 0 ] && { f=$((w*d/t)); p=$((100*d/t)); }; printf '%s%s %3d%%' "$(repeat '█' $f)" "$(repeat '░' $((w-f)))" $p; }
in_list() { case " $2 " in *" $1 "*) return 0 ;; esac; return 1; }
cart_count() { local n=0 i; for ((i=0;i<NCAT;i++)); do [ "${CART[$i]}" = 1 ] && n=$((n+1)); done; echo $n; }
inst_count() { local n=0 i; for ((i=0;i<NCAT;i++)); do [ "${INST[$i]}" = 1 ] && n=$((n+1)); done; echo $n; }

# ---------- daftar opsi generik untuk widget ----------
opt_reset() { O_LABEL=(); O_TIP=(); O_VAL=(); O_BADGE=(); O_CHK=(); O_LOCK=(); O_REC=(); O_SEP=(); }
opt_add() { # label tip val badge chk lock rec sep
  local n=${#O_LABEL[@]}
  O_LABEL[$n]=$1; O_TIP[$n]=$2; O_VAL[$n]=$3; O_BADGE[$n]=$4; O_CHK[$n]=${5:-0}; O_LOCK[$n]=${6:-0}; O_REC[$n]=${7:-0}; O_SEP[$n]=${8:-0}
}
cat_opt() { # tambahkan item katalog berdasarkan key
  local i; i=$(ix "$1"); [ -z "$i" ] && return
  local b="" src st
  if [ "${INST[$i]}" = 1 ]; then b="${GRN}✓ terpasang  "; elif [ "${CART[$i]}" = 1 ]; then b="${CYN}+ keranjang  "; fi
  [ "${K_REC[$i]}" = 1 ] && b="$b${YEL}★ rekomendasi  "
  [ "${K_TYPE[$i]}" = info ] && b="$b${ORG}ⓘ manual  "
  in_list "$1" "$HEAVY" && [ "${SYS_RAM:-16}" -lt 12 ] && b="$b${RED}! berat untuk RAM ${SYS_RAM}GB"
  case "${K_TYPE[$i]}" in
    formula) src="brew install ${K_ID[$i]}" ;; cask) src="brew install --cask ${K_ID[$i]}" ;;
    info) src="Download manual: ${K_ID[$i]}" ;; custom) src="installer resmi" ;;
  esac
  if [ "${INST[$i]}" = 1 ]; then st="Status: SUDAH TERPASANG di Mac ini."; else st="Status: belum terpasang."; fi
  opt_add "${K_NAME[$i]}" "${K_TIP[$i]}\n$st  |  $src" "$1" "$b" "${CART[$i]}" "${INST[$i]}" "${K_REC[$i]}"
}

# ---------- input keyboard ----------
read_key() {
  local k r
  if [ "$TEST_MODE" = 1 ]; then
    if [ $KEYI -ge ${#KEYQ[@]} ]; then printf '\nSELFTEST-TOMBOL-SELESAI\n'; exit 0; fi
    k=${KEYQ[$KEYI]}; KEYI=$((KEYI+1)); log "KEY $k"
    case "$k" in Up) KEY=UP ;; Down) KEY=DOWN ;; Enter) KEY=ENTER ;; Esc) KEY=ESC ;; Space) KEY=SPACE ;; PgDn) KEY=PGDN ;; PgUp) KEY=PGUP ;; Home) KEY=HOME ;; End) KEY=END ;; *) KEY=$(printf '%s' "$k" | tr 'A-Z' 'a-z') ;; esac
    return
  fi
  IFS= read -rsn1 k
  if [ "$k" = "$E" ]; then
    IFS= read -rsn1 -t 1 r || { KEY=ESC; return; }
    if [ "$r" = "[" ] || [ "$r" = "O" ]; then
      IFS= read -rsn1 r
      case "$r" in A) KEY=UP ;; B) KEY=DOWN ;; H) KEY=HOME ;; F) KEY=END ;; 5) read -rsn1; KEY=PGUP ;; 6) read -rsn1; KEY=PGDN ;; *) KEY=NONE ;; esac
    else KEY=ESC; fi
  elif [ -z "$k" ]; then KEY=ENTER
  elif [ "$k" = " " ]; then KEY=SPACE
  elif [ "$k" = $'\x7f' ]; then KEY=ESC
  else KEY=$(printf '%s' "$k" | tr 'A-Z' 'a-z'); fi
}

# ---------- widget utama: daftar interaktif + panel tooltip ----------
# select_list "judul" "sub" mode(single|multi|radio) start "teks enter"
# hasil: RES_OK (1/0), RES_VALUE, RES_VALUES (dipisah spasi)
HDR=()
select_list() {
  local title=$1 sub=$2 mode=$3 idx=${4:-0} et=${5:-pilih} top=0 n=${#O_LABEL[@]}
  local rows cols view i end tw line ptr box nc lbl cc
  while [ $idx -lt $((n-1)) ] && [ "${O_SEP[$idx]}" = 1 ]; do idx=$((idx+1)); done
  printf '%s' "$E[2J$E[?7l"; hide_cur
  while true; do
    rows=$(tput lines 2>/dev/null || echo 30); cols=$(tput cols 2>/dev/null || echo 100); [ "${rows:-0}" -lt 10 ] && rows=30; [ "${cols:-0}" -lt 40 ] && cols=100; OUT="$E[H"; LN=0
    ln() { OUT="$OUT$1$E[K"$'\n'; LN=$((LN+1)); }
    for line in "${HDR[@]}"; do ln "$line"; done
    cc=$(cart_count)
    ln "${PNK}▓▒░ ${WHT}${B}DEVSETUP IF${R0} ${DIM}│ ${CYN}${title}${R0}$( [ "$cc" -gt 0 ] && printf '   %s│ %sKeranjang: %s item%s' "$DIM" "$GRN" "$cc" "$R0")"
    ln "${DIM}$(repeat '─' $((cols-1)))${R0}"
    if [ -n "$sub" ]; then while IFS= read -r line; do ln " ${GRY}${line}${R0}"; done <<< "$(printf '%b\n' "$sub" | fold -s -w $((cols-3)))"; fi
    view=$((rows - LN - 11)); [ $view -lt 3 ] && view=3
    [ $idx -lt $top ] && top=$idx
    [ $idx -ge $((top+view)) ] && top=$((idx-view+1))
    if [ $top -gt 0 ]; then ln "     ${DIM}▲ $top lagi di atas${R0}"; else ln ""; fi
    end=$((top+view)); [ $end -gt $n ] && end=$n
    for ((i=top;i<end;i++)); do
      if [ "${O_SEP[$i]}" = 1 ]; then ln "   ${ORG}── ${YEL}${B}${O_LABEL[$i]}${R0} ${ORG}$(repeat '─' $((48-${#O_LABEL[$i]})))${R0}"; continue; fi
      if [ $i = $idx ]; then ptr="${YEL} ❯ "; nc="${WHT}${B}"; else ptr="   "; nc="$GRY"; fi
      box=""
      if [ "$mode" = multi ]; then
        if [ "${O_LOCK[$i]}" = 1 ]; then box="${GRN}✓ "; nc="$DIM"; [ $i = $idx ] && nc="$WHT"
        elif [ "${O_CHK[$i]}" = 1 ]; then box="${GRN}◉ "; else box="${DIM}◯ "; fi
      elif [ "$mode" = radio ]; then
        if [ "${O_CHK[$i]}" = 1 ]; then box="${GRN}● "; else box="${DIM}○ "; fi
      fi
      lbl=$(printf '%-38s' "${O_LABEL[$i]}")
      if [ $i = $idx ]; then ln "$ptr$box$nc$INV $lbl $R0 ${O_BADGE[$i]}$R0"; else ln "$ptr$box$nc $lbl $R0 ${O_BADGE[$i]}$R0"; fi
    done
    for ((i=end-top;i<view;i++)); do ln ""; done
    if [ $end -lt $n ]; then ln "     ${DIM}▼ $((n-end)) lagi di bawah${R0}"; else ln ""; fi
    tw=$((cols-5))
    local tt=" ${O_LABEL[$idx]} "
    ln "${CYN}╭─${WHT}${B}${tt}${R0}${CYN}$(repeat '─' $((tw-${#tt})))─╮${R0}"
    local tl=(); while IFS= read -r line; do tl+=("$line"); done <<< "$(printf '%b\n' "${O_TIP[$idx]}" | fold -s -w $tw)"
    for ((i=0;i<5;i++)); do
      line="${tl[$i]}"; local col=$GRY
      case "$line" in "Status: SUDAH"*) col=$GRN ;; "Status:"*) col=$DIM ;; esac
      ln "${CYN}│${R0} ${col}$(printf "%-${tw}s" "$line")${R0} ${CYN}│${R0}"
    done
    ln "${CYN}╰$(repeat '─' $((tw+2)))╯${R0}"
    if [ "$mode" = multi ]; then
      ln " ${WHT}↑↓${DIM} gerak  ${WHT}Spasi${DIM} centang  ${WHT}a${DIM} semua  ${WHT}n${DIM} kosongkan  ${WHT}r${DIM} rekomendasi  ${WHT}Enter${DIM} $et  ${WHT}Esc/q${DIM} kembali${R0}"
    else
      ln " ${WHT}↑↓${DIM} gerak  ${WHT}Enter${DIM} $et  ${WHT}Esc/q${DIM} kembali${R0}"
    fi
    printf '%s%s' "$OUT" "$E[J"

    read_key
    local mv=0
    case "$KEY" in
      UP|k) mv=-1 ;; DOWN|j) mv=1 ;; PGUP) mv=-$view ;; PGDN) mv=$view ;;
      HOME) idx=0; [ "${O_SEP[0]}" = 1 ] && mv=1 ;; END) idx=$((n-1)) ;;
      ESC|q) RES_OK=0; printf '%s' "$E[?7h"; return ;;
      ENTER)
        RES_OK=1; RES_VALUE=${O_VAL[$idx]}; RES_VALUES=""
        if [ "$mode" = multi ]; then for ((i=0;i<n;i++)); do [ "${O_CHK[$i]}" = 1 ] && [ "${O_SEP[$i]}" != 1 ] && RES_VALUES="$RES_VALUES ${O_VAL[$i]}"; done; fi
        printf '%s' "$E[?7h"; return ;;
      SPACE) [ "$mode" = multi ] && [ "${O_LOCK[$idx]}" != 1 ] && { [ "${O_CHK[$idx]}" = 1 ] && O_CHK[$idx]=0 || O_CHK[$idx]=1; } ;;
      a) [ "$mode" = multi ] && for ((i=0;i<n;i++)); do [ "${O_LOCK[$i]}" != 1 ] && [ "${O_SEP[$i]}" != 1 ] && O_CHK[$i]=1; done ;;
      n) [ "$mode" = multi ] && for ((i=0;i<n;i++)); do [ "${O_LOCK[$i]}" != 1 ] && O_CHK[$i]=0; done ;;
      r) [ "$mode" = multi ] && for ((i=0;i<n;i++)); do [ "${O_LOCK[$i]}" != 1 ] && [ "${O_SEP[$i]}" != 1 ] && O_CHK[$i]=${O_REC[$i]}; done ;;
    esac
    if [ $mv != 0 ]; then
      local step=1 t=$((idx+mv)) g=0; [ $mv -lt 0 ] && step=-1
      if [ $mv -gt 1 ] || [ $mv -lt -1 ]; then [ $t -lt 0 ] && t=0; [ $t -ge $n ] && t=$((n-1))
      else [ $t -lt 0 ] && t=$((n-1)); [ $t -ge $n ] && t=0; fi
      while [ "${O_SEP[$t]}" = 1 ] && [ $g -lt $n ]; do t=$((t+step)); [ $t -lt 0 ] && t=$((n-1)); [ $t -ge $n ] && t=0; g=$((g+1)); done
      idx=$t
    fi
  done
}

# =====================================================================================
#  SISTEM & DETEKSI
# =====================================================================================
get_sysinfo() {
  SYS_OS="macOS $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
  SYS_ARCH=$(uname -m)
  SYS_CPU=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
  SYS_CORES="$(sysctl -n hw.physicalcpu) core / $(sysctl -n hw.logicalcpu) thread"
  SYS_RAM=$(( $(sysctl -n hw.memsize) / 1073741824 ))
  SYS_MODEL=$(sysctl -n hw.model)
  SYS_DISKFREE=$(df -g / | awk 'NR==2{print $4}'); SYS_DISKTOT=$(df -g / | awk 'NR==2{print $2}')
  [ "$SYS_ARCH" = arm64 ] && SYS_CHIP="Apple Silicon" || SYS_CHIP="Intel"
  SYS_NET=0; /usr/bin/curl -sI --max-time 5 https://github.com >/dev/null 2>&1 && SYS_NET=1
}

spin() { # spin "label" cmd args...  -> SPIN_RC, SPIN_SECS
  local label=$1; shift
  local start=$SECONDS fr=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏) i=0
  echo "=== $* ===" >> "$LOG"
  "$@" >> "$LOG" 2>&1 < /dev/null &
  local pid=$!
  while kill -0 $pid 2>/dev/null; do
    local s=$((SECONDS-start))
    printf '\r   %s%s %s  %02d:%02d %s' "$CYN" "${fr[$((i%10))]}" "$label" $((s/60)) $((s%60)) "$R0"
    i=$((i+1)); sleep 0.1
  done
  wait $pid; SPIN_RC=$?; SPIN_SECS=$((SECONDS-start))
}

ensure_brew() {
  if ! xcode-select -p >/dev/null 2>&1; then
    printf '  %s[ .... ]%s Xcode Command Line Tools belum ada. Popup instalasi akan muncul...\n' "$YEL" "$R0"
    xcode-select --install 2>/dev/null
    printf '  Klik "Install" di popup, tunggu sampai selesai'
    until xcode-select -p >/dev/null 2>&1; do printf '.'; sleep 5; done; echo
  fi
  if ! command -v brew >/dev/null 2>&1; then
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && eval "$("$b" shellenv)"; done
  fi
  if ! command -v brew >/dev/null 2>&1; then
    printf '\n  %sHomebrew belum terpasang. Menginstall (akan minta password Mac kamu)...%s\n\n' "$CYN" "$R0"
    show_cur
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "Gagal install Homebrew."; exit 1; }
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      if [ -x "$b" ]; then eval "$("$b" shellenv)"; grep -q 'brew shellenv' ~/.zprofile 2>/dev/null || echo "eval \"\$($b shellenv)\"" >> ~/.zprofile; fi
    done
  fi
}

scan_installed() {
  local BF BC i det id
  BF=$'\n'"$(brew list --formula -1 2>/dev/null)"$'\n'; BC=$'\n'"$(brew list --cask -1 2>/dev/null)"$'\n'
  for ((i=0;i<NCAT;i++)); do
    local hit=0; id=${K_ID[$i]##*/}; id=${id%% *}
    case "${K_TYPE[$i]}" in
      formula) case "$BF" in *$'\n'"$id"$'\n'*) hit=1 ;; esac ;;
      cask) case "$BC" in *$'\n'"$id"$'\n'*) hit=1 ;; esac ;;
    esac
    det=${K_DET[$i]}
    if [ $hit = 0 ] && [ -n "$det" ]; then
      case "$det" in
        cmd:*) command -v "${det#cmd:}" >/dev/null 2>&1 && hit=1 ;;
        dir:*) eval "[ -d ${det#dir:} ]" && hit=1 ;;
        *) { [ -d "/Applications/$det.app" ] || [ -d "$HOME/Applications/$det.app" ] || [ -d "/Applications/$det" ]; } && hit=1 ;;
      esac
    fi
    INST[$i]=$hit; [ $hit = 1 ] && CART[$i]=0
  done
  # git dan python3 bawaan Xcode CLT tidak dihitung (versinya lama / stub)
  i=$(ix git); case "$BF" in *$'\n'git$'\n'*) ;; *) INST[$i]=0 ;; esac
  i=$(ix python); case "$BF" in *$'\n'python@3*) ;; *) [ "$(command -v python3)" = /usr/bin/python3 ] && INST[$i]=0 ;; esac
}

sync_cart() { # sync_cart "keys" "chosen"
  local k i
  for k in $1; do i=$(ix "$k"); [ -z "$i" ] && continue
    if in_list "$k" "$2" && [ "${INST[$i]}" != 1 ]; then CART[$i]=1; else CART[$i]=0; fi
  done
}

# =====================================================================================
#  LAYAR
# =====================================================================================
show_banner() { local i; echo; for ((i=0;i<6;i++)); do printf '  %s%s%s\n' "${BCOL[$i]}" "${BANNER[$i]}" "$R0"; [ $NOANIM = 0 ] && sleep 0.07; done; }

boot() {
  printf '%s' "$E[2J$E[H"; hide_cur
  show_banner
  local tag="      I F   ·   Installer Toolkit Mahasiswa Teknik Informatika & Abang IT   ·   v2.0 macOS"
  echo
  if [ $NOANIM = 1 ]; then printf '%s%s%s\n' "$DIM" "$tag" "$R0"; else
    printf '%s' "$DIM"; local j; for ((j=0;j<${#tag};j++)); do printf '%s' "${tag:$j:1}"; sleep 0.004; done; printf '%s\n' "$R0"; fi
  echo
  chk() { printf '  %s[ .... ]%s %s' "$DIM" "$R0" "$1"; [ $NOANIM = 0 ] && sleep 0.15
    if [ "$2" = 1 ]; then printf '\r  %s[  OK  ]%s %s\n' "$GRN" "$R0" "$1"; else printf '\r  %s[ WARN ]%s %s\n' "$YEL" "$R0" "$1"; fi; }
  get_sysinfo
  chk "Membaca informasi sistem" 1
  chk "Koneksi internet" $SYS_NET
  xcode-select -p >/dev/null 2>&1 && chk "Xcode Command Line Tools" 1 || chk "Xcode Command Line Tools (akan dipasang)" 0
  command -v brew >/dev/null 2>&1 || [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ] && chk "Homebrew" 1 || chk "Homebrew (akan dipasang)" 0
  echo
  printf '     %sMac    : %s (%s, %s)\n' "$CYN" "$SYS_MODEL" "$SYS_CHIP" "$SYS_ARCH"
  printf '     OS     : %s\n' "$SYS_OS"
  printf '     CPU    : %s (%s)\n' "$SYS_CPU" "$SYS_CORES"
  printf '     RAM    : %s GB      Disk: %s GB kosong dari %s GB%s\n\n' "$SYS_RAM" "$SYS_DISKFREE" "$SYS_DISKTOT" "$R0"
  [ $SYS_NET = 0 ] && printf '  %sTidak ada internet. Instalasi butuh koneksi, cek WiFi dulu ya.%s\n' "$YEL" "$R0"
  [ "${SYS_DISKFREE:-99}" -lt 20 ] && printf '  %sDisk tinggal %s GB. Xcode/Android Studio bisa gagal.%s\n' "$YEL" "$SYS_DISKFREE" "$R0"
  ensure_brew
  hide_cur
  spin "Memperbarui daftar paket Homebrew..." brew update
  printf '\r%s' "$E[K"
  spin "Memindai aplikasi yang sudah terpasang..." true
  scan_installed
  printf '\r   %s✓ Pemindaian selesai: %s dari %s aplikasi di katalog sudah terpasang.%s%s\n' "$GRN" "$(inst_count)" "$NCAT" "$R0" "$E[K"
  [ $NOANIM = 0 ] && sleep 0.9
}

run_wizard() {
  local q=0 total=${#WIZ[@]} entry Q M L T prog i j start
  while [ $q -lt $total ]; do
    entry=${WIZ[$q]}
    Q=${entry%%|*}; entry=${entry#*|}; M=${entry%%|*}; entry=${entry#*|}; L=${entry%%|*}; T=${entry#*|}
    T=${T//__RAM__/$SYS_RAM}
    prog="Pertanyaan $((q+1))/$total  $(repeat '●' $((q+1)))$(repeat '○' $((total-q-1)))"
    opt_reset; for k in $L; do cat_opt "$k"; done
    if [ "$M" = m ]; then
      select_list "Wizard │ $prog" "${WHT}${B}$Q${R0}\n$T" multi 0 "simpan & lanjut"
    else
      start=-1
      for ((j=0;j<${#O_VAL[@]};j++)); do i=$(ix "${O_VAL[$j]}"); { [ "${CART[$i]}" = 1 ] || [ "${INST[$i]}" = 1 ]; } && { O_CHK[$j]=1; [ $start -lt 0 ] && start=$j; }; done
      if [ $start -lt 0 ]; then for ((j=0;j<${#O_VAL[@]};j++)); do [ "${O_REC[$j]}" = 1 ] && { start=$j; break; }; done; fi
      [ $start -lt 0 ] && start=0
      opt_add "Lewati / tidak perlu" "Tidak memilih apa pun untuk pertanyaan ini." "__skip"
      select_list "Wizard │ $prog" "${WHT}${B}$Q${R0}\n$T" radio $start "pilih & lanjut"
      RES_VALUES=$RES_VALUE
    fi
    if [ "$RES_OK" != 1 ]; then [ $q = 0 ] && return; q=$((q-1)); continue; fi
    sync_cart "$L" "$RES_VALUES"
    q=$((q+1))
  done
  review_install
}

pick_profile() {
  local p key name desc list k ins names
  while true; do
    opt_reset
    for p in "${PROFILES[@]}"; do
      key=${p%%|*}; p=${p#*|}; name=${p%%|*}; p=${p#*|}; desc=${p%%|*}; list=${p#*|}
      ins=0; names=""; local cnt=0
      for k in $list; do cnt=$((cnt+1)); i=$(ix "$k"); [ "${INST[$i]}" = 1 ] && ins=$((ins+1)); names="$names${names:+, }${K_NAME[$i]}"; done
      opt_add "$name" "$desc\nIsi: $names" "$key" "${DIM}$cnt aplikasi  $( [ $ins -gt 0 ] && printf '%s%s sudah ada' "$GRN" "$ins")"
    done
    select_list "Profil Siap Pakai" "Pilih profil sesuai minat/peminatan. Isinya masih bisa kamu centang/hapus sebelum masuk keranjang." single 0 "lihat isi"
    [ "$RES_OK" != 1 ] && return
    for p in "${PROFILES[@]}"; do [ "${p%%|*}" = "$RES_VALUE" ] && { list=${p##*|}; name=${p#*|}; name=${name%%|*}; }; done
    opt_reset; for k in $list; do cat_opt "$k"; done
    for ((j=0;j<${#O_VAL[@]};j++)); do [ "${O_LOCK[$j]}" != 1 ] && O_CHK[$j]=1; done
    select_list "Profil │ $name" "Semua sudah dicentang. Hapus centang yang tidak perlu, lalu Enter untuk memasukkan ke keranjang." multi 0 "masukkan keranjang"
    if [ "$RES_OK" = 1 ]; then sync_cart "$list" "$RES_VALUES"; printf '%s' "$E[2J$E[H"; echo
      yesno "Langsung ke keranjang & install sekarang?" y && { review_install; return; }; fi
  done
}

browse_category() {
  local c i keys tot ins inc names
  while true; do
    opt_reset
    for c in "${CATS[@]}"; do
      tot=0; ins=0; inc=0; names=""
      for ((i=0;i<NCAT;i++)); do [ "${K_CAT[$i]}" = "$c" ] || continue; tot=$((tot+1)); [ "${INST[$i]}" = 1 ] && ins=$((ins+1)); [ "${CART[$i]}" = 1 ] && inc=$((inc+1)); names="$names${names:+, }${K_NAME[$i]}"; done
      opt_add "$c" "$names" "$c" "${DIM}$tot app  ${GRN}$ins terpasang  $( [ $inc -gt 0 ] && printf '%s%s di keranjang' "$CYN" "$inc")"
    done
    opt_add "» Semua aplikasi (satu daftar panjang)" "Tampilkan seluruh katalog sekaligus, dikelompokkan per kategori." "__all"
    select_list "Pilih Manual per Kategori" "Pilih kategori untuk melihat isinya. Yang sudah terpasang ditandai ✓ dan tidak bisa dicentang." single 0 "buka"
    [ "$RES_OK" != 1 ] && return
    [ "$RES_VALUE" = __all ] && { show_all; continue; }
    c=$RES_VALUE; keys=""; opt_reset
    for ((i=0;i<NCAT;i++)); do [ "${K_CAT[$i]}" = "$c" ] && { keys="$keys ${K_KEY[$i]}"; cat_opt "${K_KEY[$i]}"; }; done
    select_list "Kategori │ $c" "" multi 0 "simpan"
    [ "$RES_OK" = 1 ] && sync_cart "$keys" "$RES_VALUES"
  done
}

show_all() {
  local c i keys="" ins tot
  opt_reset
  for c in "${CATS[@]}"; do
    tot=0; ins=0; for ((i=0;i<NCAT;i++)); do [ "${K_CAT[$i]}" = "$c" ] && { tot=$((tot+1)); [ "${INST[$i]}" = 1 ] && ins=$((ins+1)); }; done
    opt_add "$c  ($ins/$tot)" "" "" "" 0 1 0 1
    for ((i=0;i<NCAT;i++)); do [ "${K_CAT[$i]}" = "$c" ] && { cat_opt "${K_KEY[$i]}"; keys="$keys ${K_KEY[$i]}"; }; done
  done
  select_list "Cek Status │ $(inst_count)/$NCAT terpasang" "Semua aplikasi di katalog beserta statusnya. Centang yang belum ada untuk dimasukkan keranjang." multi 0 "simpan ke keranjang"
  [ "$RES_OK" = 1 ] && sync_cart "$keys" "$RES_VALUES"
  { echo "LAPORAN DEVSETUP IF - $(date)"; echo "Mac: $SYS_MODEL | $SYS_OS | RAM $SYS_RAM GB"; echo
    for c in "${CATS[@]}"; do echo "[$c]"; for ((i=0;i<NCAT;i++)); do [ "${K_CAT[$i]}" = "$c" ] && { [ "${INST[$i]}" = 1 ] && echo "  [v] ${K_NAME[$i]}" || echo "  [ ] ${K_NAME[$i]}"; }; done; done
  } > "$ROOT/laporan-status.txt"
}

review_install() {
  local i keys="" sub heavy="" n
  n=$(cart_count)
  if [ "$n" = 0 ]; then printf '%s' "$E[2J$E[H"; printf '\n  %sKeranjang masih kosong. Pilih aplikasi lewat Wizard, Profil, atau Kategori dulu.%s\n' "$YEL" "$R0"; pause_key; return; fi
  opt_reset
  for ((i=0;i<NCAT;i++)); do [ "${CART[$i]}" = 1 ] && { keys="$keys ${K_KEY[$i]}"; cat_opt "${K_KEY[$i]}"; in_list "${K_KEY[$i]}" "$HEAVY" && heavy="$heavy${heavy:+, }${K_NAME[$i]}"; }; done
  sub="$n aplikasi siap dipasang. Hapus centang untuk membatalkan item. Enter = MULAI INSTALL."
  [ -n "$heavy" ] && sub="$sub\nPaket berat: $heavy (download besar, butuh waktu)."
  in_list node "$keys" && in_list fnm "$keys" && sub="$sub\n${YEL}PERINGATAN: Node.js LTS dan fnm sebaiknya pilih salah satu.${R0}"
  in_list docker "$keys" && in_list orbstack "$keys" && sub="$sub\n${YEL}PERINGATAN: Docker Desktop dan OrbStack bentrok, pilih salah satu.${R0}"
  select_list "Keranjang Instalasi" "$sub" multi 0 "MULAI INSTALL"
  [ "$RES_OK" != 1 ] && return
  sync_cart "$keys" "$RES_VALUES"
  [ "$(cart_count)" -gt 0 ] && install_cart
}

install_ohmyzsh() {
  if [ ! -d ~/.oh-my-zsh ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || return 1
  fi
  brew install zsh-autosuggestions zsh-syntax-highlighting || return 1
  local p; p=$(brew --prefix)
  grep -q 'oh-my-zsh.sh' ~/.zshrc 2>/dev/null || printf '\nexport ZSH="$HOME/.oh-my-zsh"\nZSH_THEME="agnoster"\nplugins=(git)\nsource $ZSH/oh-my-zsh.sh\n' >> ~/.zshrc
  grep -q zsh-autosuggestions.zsh ~/.zshrc 2>/dev/null || echo "source $p/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
  grep -q zsh-syntax-highlighting.zsh ~/.zshrc 2>/dev/null || echo "source $p/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
}

post_install() {
  local p; p=$(brew --prefix)
  touch ~/.zshrc
  for k in node@22 mysql@8.4 postgresql@16; do
    if [ -d "$p/opt/$k/bin" ] && ! grep -q "opt/$k/bin" ~/.zshrc; then echo "export PATH=\"$p/opt/$k/bin:\$PATH\"" >> ~/.zshrc; fi
  done
  if brew list --formula python >/dev/null 2>&1 && ! grep -q 'alias python=' ~/.zshrc; then echo 'alias python=python3; alias pip=pip3' >> ~/.zshrc; fi
  if [ -d /Library/Java/JavaVirtualMachines ] && ls /Library/Java/JavaVirtualMachines | grep -q temurin && ! grep -q JAVA_HOME ~/.zshrc; then echo 'export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)' >> ~/.zshrc; fi
  grep -q 'zoxide init' ~/.zshrc || { command -v zoxide >/dev/null && echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc; }
  grep -q 'starship init' ~/.zshrc || { command -v starship >/dev/null && echo 'eval "$(starship init zsh)"' >> ~/.zshrc; }
}

install_cart() {
  local order="" i n=0 total ok=0 skip=0 fail=0 info=0 failed="" notes="" t0=$SECONDS status msg
  for t in custom formula cask info; do for ((i=0;i<NCAT;i++)); do [ "${CART[$i]}" = 1 ] && [ "${K_TYPE[$i]}" = $t ] && order="$order $i"; done; done
  total=$(echo $order | wc -w | tr -d ' ')
  printf '%s' "$E[2J$E[H"; show_banner
  printf '\n  %s═══ INSTALASI DIMULAI · %s item · log: %s%s\n\n' "$MAG" "$total" "$LOG" "$R0"
  if echo "$order" | grep -q . && ! sudo -n true 2>/dev/null; then
    printf '  %sBeberapa aplikasi (cask) butuh password Mac. Masukkan sekali di sini:%s\n' "$DIM" "$R0"; show_cur
    sudo -v && { ( while true; do sudo -n true; sleep 50; kill -0 $$ 2>/dev/null || exit; done ) 2>/dev/null & SUDO_PID=$!; }
    hide_cur; echo
  fi
  for i in $order; do
    n=$((n+1)); status=fail; msg=""
    printf '  %s%s  [%s/%s] %s%s%s\n' "$MAG" "$(bar $((n-1)) $total)" $n $total "$DIM" "${K_CAT[$i]}" "$R0"
    case "${K_TYPE[$i]}" in
      formula) spin "Menginstall ${K_NAME[$i]}" brew install ${K_ID[$i]} ;;
      cask) spin "Menginstall ${K_NAME[$i]}" brew install --cask "${K_ID[$i]}" ;;
      custom) spin "Menginstall ${K_NAME[$i]}" install_ohmyzsh ;;
      info) SPIN_RC=0; status=info; notes="$notes${K_NAME[$i]}|${K_ID[$i]}"$'\n' ;;
    esac
    [ "$status" != info ] && { [ "$SPIN_RC" = 0 ] && status=ok || msg="exit $SPIN_RC, lihat log"; }
    case $status in
      ok) printf '\r   %s✓ %s  (%ss)%s%s\n' "$GRN" "${K_NAME[$i]}" "$SPIN_SECS" "$R0" "$E[K"; ok=$((ok+1)); INST[$i]=1; CART[$i]=0 ;;
      info) printf '\r   %sⓘ %s  -> perlu download manual (lihat catatan di akhir)%s%s\n' "$ORG" "${K_NAME[$i]}" "$R0" "$E[K"; info=$((info+1)); CART[$i]=0 ;;
      fail) printf '\r   %s✗ %s  GAGAL: %s%s%s\n' "$RED" "${K_NAME[$i]}" "$msg" "$R0" "$E[K"; fail=$((fail+1)); failed="$failed${failed:+, }${K_NAME[$i]}" ;;
    esac
    log "${K_KEY[$i]}: $status $msg"
  done
  post_install
  [ -n "$SUDO_PID" ] && { kill $SUDO_PID 2>/dev/null; SUDO_PID=""; }
  printf '  %s%s%s\n\n' "$MAG" "$(bar $total $total)" "$R0"
  local mins=$(( (SECONDS-t0)/60 ))
  printf '  %s╔══════════════════════════════════════════════════════════╗\n' "$MAG"
  printf '  ║  RINGKASAN  ·  waktu total ~%-3s menit                     ║\n' "$mins"
  printf '  ╠══════════════════════════════════════════════════════════╣%s\n' "$R0"
  printf '  %s║%s   %s✓ Berhasil        : %-4s%s                               %s║%s\n' "$MAG" "$R0" "$GRN" "$ok" "$R0" "$MAG" "$R0"
  printf '  %s║%s   %sⓘ Manual/catatan  : %-4s%s                               %s║%s\n' "$MAG" "$R0" "$ORG" "$info" "$R0" "$MAG" "$R0"
  printf '  %s║%s   %s✗ Gagal           : %-4s%s                               %s║%s\n' "$MAG" "$R0" "$RED" "$fail" "$R0" "$MAG" "$R0"
  printf '  %s╚══════════════════════════════════════════════════════════╝%s\n' "$MAG" "$R0"
  [ -n "$failed" ] && printf '  %sGagal: %s\n  Item yang gagal tetap di keranjang dan bisa dicoba lagi. Detail ada di log.%s\n' "$RED" "$failed" "$R0"
  if [ -n "$notes" ]; then
    printf '\n  %sPerlu download/instal manual:%s\n' "$YEL" "$R0"
    echo "$notes" | while IFS='|' read -r nm url; do [ -n "$nm" ] && printf '   • %s: %s\n' "$nm" "$url"; done
    if [ "$UNATTENDED$TEST_MODE" = 00 ] && yesno "Buka semua link di browser?" y; then echo "$notes" | while IFS='|' read -r nm url; do [ -n "$url" ] && open "$url"; done; fi
  fi
  INSTALL_FAIL=$fail
  printf '\n  %sTip: buka tab Terminal baru (atau jalankan: source ~/.zshrc) supaya PATH baru terbaca.%s\n' "$CYN" "$R0"
  [ "$UNATTENDED" = 1 ] || pause_key
}

setup_vscode_ext() {
  local code="" e have id nm rec tip ins
  command -v code >/dev/null && code=code
  [ -z "$code" ] && [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ] && code="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  if [ -z "$code" ]; then printf '%s' "$E[2J$E[H"; printf '\n  %sVS Code belum terpasang. Install dulu lewat menu lain.%s\n' "$RED" "$R0"; pause_key; return; fi
  printf '%s\n   %sMembaca ekstensi yang sudah terpasang...%s' "$E[2J$E[H" "$DIM" "$R0"
  have=" $("$code" --list-extensions 2>/dev/null | tr 'A-Z' 'a-z' | tr '\n' ' ') "
  opt_reset
  for e in "${VSEXT[@]}"; do
    IFS='|' read -r id nm rec tip <<< "$e"
    ins=0; in_list "$(echo "$id" | tr 'A-Z' 'a-z')" "$have" && ins=1
    local b=""; [ $ins = 1 ] && b="${GRN}✓ terpasang  "; [ "$rec" = 1 ] && b="$b${YEL}★ rekomendasi"
    local chk=0; [ "$rec" = 1 ] && [ $ins = 0 ] && chk=1
    opt_add "$nm" "$tip\nID: $id" "$id" "$b" $chk $ins "$rec"
  done
  select_list "Ekstensi VS Code" "Yang direkomendasikan sudah dicentang. Enter untuk memasang." multi 0 "pasang"
  [ "$RES_OK" != 1 ] && return
  printf '%s\n' "$E[2J$E[H"
  local n=0 t; t=$(echo $RES_VALUES | wc -w | tr -d ' ')
  for e in $RES_VALUES; do n=$((n+1)); spin "[$n/$t] $e" "$code" --install-extension "$e" --force
    [ "$SPIN_RC" = 0 ] && printf '\r   %s✓ %s%s%s\n' "$GRN" "$e" "$R0" "$E[K" || printf '\r   %s✗ %s (gagal)%s%s\n' "$RED" "$e" "$R0" "$E[K"; done
  pause_key
}

setup_git() {
  printf '%s' "$E[2J$E[H"; show_cur
  printf '\n  %s═══ SETUP GIT & SSH KEY ═══%s\n\n' "$MAG" "$R0"
  local cn ce; cn=$(git config --global user.name); ce=$(git config --global user.email)
  printf '  %sKonfigurasi sekarang: %s%s\n\n' "$DIM" "${cn:+$cn <$ce>}${cn:-(belum ada)}" "$R0"
  ask "Nama lengkap (tampil di commit)" "$cn"; local name=$REPLY_VAL
  ask "Email (SAMA dengan email akun GitHub)" "$ce"; local mail=$REPLY_VAL
  git config --global user.name "$name"; git config --global user.email "$mail"
  git config --global init.defaultBranch main; git config --global core.autocrlf input; git config --global pull.rebase false
  command -v code >/dev/null && git config --global core.editor "code --wait"
  printf '  %s✓ user.name, user.email, defaultBranch=main, autocrlf=input%s\n' "$GRN" "$R0"
  if [ ! -f ~/.ssh/id_ed25519 ]; then
    if yesno "Buat SSH key baru (ed25519) untuk GitHub?" y; then mkdir -p ~/.ssh; ssh-keygen -t ed25519 -C "$mail" -f ~/.ssh/id_ed25519 -N "" -q; fi
  else printf '  %sSSH key sudah ada, dipakai ulang.%s\n' "$DIM" "$R0"; fi
  if [ -f ~/.ssh/id_ed25519.pub ]; then
    grep -q UseKeychain ~/.ssh/config 2>/dev/null || printf 'Host github.com\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519\n' >> ~/.ssh/config
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null
    pbcopy < ~/.ssh/id_ed25519.pub
    printf '\n  %sSSH public key (sudah DICOPY ke clipboard):%s\n  %s%s%s\n' "$GRN" "$R0" "$WHT" "$(cat ~/.ssh/id_ed25519.pub)" "$R0"
    printf '\n  %s1. Buka github.com/settings/ssh/new  2. Paste (Cmd+V)  3. Add SSH key%s\n' "$YEL" "$R0"
    yesno "Buka halaman GitHub SSH sekarang?" y && open "https://github.com/settings/ssh/new"
    yesno "Tes koneksi ke GitHub (setelah key ditambahkan)?" n && ssh -T -o StrictHostKeyChecking=accept-new git@github.com
  fi
  command -v gh >/dev/null && yesno "Login GitHub CLI (gh auth login) juga?" n && gh auth login
  printf '\n  %sBonus: GitHub Student Developer Pack (Copilot, JetBrains, domain gratis): https://education.github.com/pack%s\n' "$CYN" "$R0"
  pause_key
}

setup_tweaks() {
  rd() { defaults read "$1" "$2" 2>/dev/null; }
  local TW=(
    "ext|Tampilkan semua ekstensi file|Supaya terlihat .py, .java, .sh dan tidak tertipu nama file palsu.|$( [ "$(rd NSGlobalDomain AppleShowAllExtensions)" = 1 ] && echo 1 || echo 0)"
    "hid|Tampilkan file tersembunyi di Finder|Supaya .git, .env, .vscode terlihat. Shortcut manual: Cmd+Shift+.|$( [ "$(rd com.apple.finder AppleShowAllFiles)" = 1 ] && echo 1 || echo 0)"
    "path|Path bar & status bar di Finder|Menampilkan lokasi folder lengkap di bawah jendela Finder.|$( [ "$(rd com.apple.finder ShowPathbar)" = 1 ] && echo 1 || echo 0)"
    "shot|Screenshot disimpan ke ~/Pictures/Screenshots|Desktop tidak penuh dengan file screenshot.|$( [ "$(rd com.apple.screencapture location)" = "$HOME/Pictures/Screenshots" ] && echo 1 || echo 0)"
    "key|Key repeat lebih cepat|Tahan tombol (misal Backspace/panah) jadi lebih cepat. Enak untuk ngoding. Berlaku setelah logout.|$( [ "$(rd NSGlobalDomain KeyRepeat)" = 2 ] && echo 1 || echo 0)"
    "press|Matikan popup aksen saat tahan tombol|Supaya tahan huruf (misal jjjj di Vim) mengulang huruf, bukan memunculkan pilihan aksen.|$( [ "$(rd NSGlobalDomain ApplePressAndHoldEnabled)" = 0 ] && echo 1 || echo 0)"
    "ds|Jangan buat .DS_Store di flashdisk/jaringan|Mencegah file .DS_Store nyampah di flashdisk teman pengguna Windows.|$( [ "$(rd com.apple.desktopservices DSDontWriteNetworkStores)" = 1 ] && echo 1 || echo 0)"
    "dock|Dock auto-hide|Layar lebih lega untuk editor kode.|$( [ "$(rd com.apple.dock autohide)" = 1 ] && echo 1 || echo 0)"
  )
  local t k n d on
  opt_reset
  for t in "${TW[@]}"; do IFS='|' read -r k n d on <<< "$t"
    opt_add "$n" "$d" "$k" "$( [ "$on" = 1 ] && printf '%s✓ sudah aktif' "$GRN")" $((1-on)) "$on" 1; done
  select_list "Tweak macOS untuk Developer" "Pengaturan yang bikin Mac lebih ramah programmer. Yang belum aktif sudah dicentang." multi 0 "terapkan"
  [ "$RES_OK" != 1 ] && return
  printf '%s\n' "$E[2J$E[H"
  for k in $RES_VALUES; do
    case $k in
      ext) defaults write NSGlobalDomain AppleShowAllExtensions -bool true ;;
      hid) defaults write com.apple.finder AppleShowAllFiles -bool true ;;
      path) defaults write com.apple.finder ShowPathbar -bool true; defaults write com.apple.finder ShowStatusBar -bool true ;;
      shot) mkdir -p ~/Pictures/Screenshots; defaults write com.apple.screencapture location ~/Pictures/Screenshots ;;
      key) defaults write NSGlobalDomain KeyRepeat -int 2; defaults write NSGlobalDomain InitialKeyRepeat -int 15 ;;
      press) defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false ;;
      ds) defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true; defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true ;;
      dock) defaults write com.apple.dock autohide -bool true ;;
    esac
    printf '   %s✓ %s%s\n' "$GRN" "$k" "$R0"
  done
  killall Finder Dock SystemUIServer 2>/dev/null
  printf '   %sFinder & Dock di-restart supaya perubahan terlihat.%s\n' "$DIM" "$R0"
  pause_key
}

update_all() {
  printf '%s' "$E[2J$E[H"; show_cur
  printf '\n  %s═══ UPDATE SEMUA (brew update + upgrade) ═══%s\n\n' "$MAG" "$R0"
  brew update && brew upgrade && brew upgrade --cask --greedy && brew cleanup
  printf '\n  %sUpdate macOS sendiri lewat System Settings > General > Software Update.%s\n' "$DIM" "$R0"
  scan_installed; pause_key
}

# =====================================================================================
#  TUNE-UP & DEBLOAT macOS
# =====================================================================================
tune_up() {
  printf '%s\n   %sMenghitung ukuran cache, tunggu sebentar...%s' "$E[2J$E[H" "$DIM" "$R0"
  local s_cache s_logs s_brew s_dev s_trash s_xcode
  s_cache=$(dir_bytes ~/Library/Caches); s_logs=$(dir_bytes ~/Library/Logs)
  s_brew=$(dir_bytes "$(brew --cache 2>/dev/null)")
  s_dev=$(dir_bytes ~/.npm/_cacache ~/Library/Caches/pip ~/.gradle/caches ~/Library/Caches/Yarn ~/.cache/pip)
  s_xcode=$(dir_bytes ~/Library/Developer/Xcode/DerivedData ~/Library/Developer/Xcode/iOS\ DeviceSupport ~/Library/Developer/CoreSimulator/Caches)
  s_trash=$(dir_bytes ~/.Trash)
  local snaps; snaps=$(tmutil listlocalsnapshots / 2>/dev/null | grep -c com.apple)
  local old=0; [ "$SYS_RAM" -le 8 ] && old=1
  local TU=(
    "cache|Bersihkan cache aplikasi user ($(human "$s_cache"))|Isi ~/Library/Caches. Aplikasi membuat ulang cache-nya; pertama kali dibuka mungkin sedikit lebih lambat.|1"
    "logs|Hapus log lama ($(human "$s_logs"))|Isi ~/Library/Logs. Aman.|1"
    "brew|Bersihkan Homebrew ($(human "$s_brew"))|brew cleanup --prune=all + brew autoremove: hapus installer lama dan dependensi yatim.|1"
    "dev|Bersihkan cache developer ($(human "$s_dev"))|npm, pip, Yarn dan Gradle cache. Paket diunduh ulang saat dibutuhkan.|0"
    "xcode|Bersihkan Xcode DerivedData & cache simulator ($(human "$s_xcode"))|Sering puluhan GB di Mac developer iOS. Build pertama setelahnya lebih lama.|0"
    "trash|Kosongkan Trash ($(human "$s_trash"))|PERMANEN. Cek isi Trash dulu kalau ragu.|0"
    "tmsnap|Hapus snapshot lokal Time Machine ($snaps snapshot)|Snapshot lokal bisa memakan banyak GB yang tidak terlihat di Finder. Backup di disk eksternal tidak tersentuh.|$( [ "$snaps" -gt 0 ] && echo 1 || echo 0)"
    "anim|Percepat animasi (Dock, jendela, Mission Control)|Animasi lebih singkat atau mati, sehingga Mac lama terasa jauh lebih responsif.|$old"
    "motion|Kurangi gerakan & transparansi|Mengurangi beban GPU. Di macOS terbaru mungkin perlu izin; kalau gagal, atur di System Settings > Accessibility > Display.|$old"
    "purge|Bebaskan RAM (purge)|Mengosongkan cache memori yang tidak aktif. Efeknya sementara; berguna sebelum membuka aplikasi berat.|0"
    "dns|Flush DNS cache|Untuk situs yang tidak bisa dibuka setelah ganti jaringan/DNS.|0"
    "spot|Bangun ulang index Spotlight|Untuk pencarian Spotlight yang lambat atau tidak menemukan file. Mac akan sibuk mengindeks 10-60 menit.|0"
  )
  local t k n d r
  opt_reset
  for t in "${TU[@]}"; do IFS='|' read -r k n d r <<< "$t"; opt_add "$n" "$d" "$k" "$( [ "$r" = 1 ] && printf '%s★ rekomendasi' "$YEL")" "$r" 0 "$r"; done
  opt_add "Login items (aplikasi saat Mac menyala)" "Membuka System Settings > General > Login Items. Matikan aplikasi yang tidak perlu ikut jalan saat Mac menyala supaya booting lebih cepat." "login" "" 0 0 0
  opt_add "Cari file besar (> 500 MB) di folder home" "Hanya menampilkan daftar, tidak menghapus apa pun." "big" "" 0 0 0
  select_list "Tune-Up & Optimasi" "RAM $SYS_RAM GB, disk kosong $SYS_DISKFREE GB. Rekomendasi sudah dicentang." multi 0 "jalankan"
  [ "$RES_OK" != 1 ] && return
  printf '%s\n  %s═══ TUNE-UP ═══%s\n\n' "$E[2J$E[H" "$MAG" "$R0"; show_cur
  local before; before=$(df -k / | awk 'NR==2{print $4}')
  case " $RES_VALUES " in *" tmsnap "*|*" purge "*|*" dns "*|*" spot "*) sudo -v ;; esac
  for k in $RES_VALUES; do
    log "TUNE $k"
    case $k in
      cache) rm -rf ~/Library/Caches/* 2>/dev/null ;;
      logs) rm -rf ~/Library/Logs/* 2>/dev/null ;;
      brew) brew cleanup --prune=all >>"$LOG" 2>&1; brew autoremove >>"$LOG" 2>&1 ;;
      dev) command -v npm >/dev/null && npm cache clean --force >>"$LOG" 2>&1; command -v pip3 >/dev/null && pip3 cache purge >>"$LOG" 2>&1; rm -rf ~/.gradle/caches ~/Library/Caches/Yarn 2>/dev/null ;;
      xcode) rm -rf ~/Library/Developer/Xcode/DerivedData/* ~/Library/Developer/Xcode/iOS\ DeviceSupport/* ~/Library/Developer/CoreSimulator/Caches/* 2>/dev/null; command -v xcrun >/dev/null && xcrun simctl delete unavailable >>"$LOG" 2>&1 ;;
      trash) osascript -e 'tell application "Finder" to empty trash' >>"$LOG" 2>&1 || rm -rf ~/.Trash/* 2>/dev/null ;;
      tmsnap) sudo tmutil thinlocalsnapshots / 999999999999 4 >>"$LOG" 2>&1 ;;
      anim) defaults write com.apple.dock autohide-time-modifier -float 0.15; defaults write com.apple.dock autohide-delay -float 0
            defaults write com.apple.dock expose-animation-duration -float 0.1; defaults write com.apple.dock launchanim -bool false
            defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false; defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
            defaults write com.apple.finder DisableAllAnimations -bool true; killall Dock Finder 2>/dev/null ;;
      motion) defaults write com.apple.universalaccess reduceMotion -bool true 2>>"$LOG"; defaults write com.apple.universalaccess reduceTransparency -bool true 2>>"$LOG" ;;
      purge) sudo purge ;;
      dns) sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder 2>/dev/null ;;
      spot) sudo mdutil -E / >>"$LOG" 2>&1 ;;
      login) open "x-apple.systempreferences:com.apple.LoginItems-Settings.extension" 2>/dev/null ;;
      big) printf '  %sFile terbesar di %s:%s\n' "$CYN" "$HOME" "$R0"; find ~ -xdev -type f -size +500M -not -path '*/Library/Mobile Documents/*' 2>/dev/null | head -200 | while IFS= read -r f; do du -h "$f" 2>/dev/null; done | sort -rh | head -15 | sed 's/^/     /' ;;
    esac
    printf '   %s✓ %s%s\n' "$GRN" "$k" "$R0"
  done
  local after; after=$(df -k / | awk 'NR==2{print $4}')
  [ "$after" -gt "$before" ] && printf '\n   %sRuang kosong bertambah: %s%s\n' "$GRN" "$(human $(( (after-before)*1024 )))" "$R0"
  pause_key
}

debloat() {
  local APPS=(
    "GarageBand|GarageBand|Studio musik bawaan. Bersama loop audionya bisa memakan 2-10 GB."
    "iMovie|iMovie|Editor video bawaan (±3 GB)."
    "Keynote|Keynote|Presentasi Apple. Hapus kalau memakai PowerPoint/Google Slides."
    "Numbers|Numbers|Spreadsheet Apple. Hapus kalau memakai Excel/Google Sheets."
    "Pages|Pages|Pengolah kata Apple. Hapus kalau memakai Word/Google Docs."
  )
  local a f nm d sz
  opt_reset
  opt_add "Aplikasi Apple opsional" "" "" "" 0 1 0 1
  for a in "${APPS[@]}"; do
    IFS='|' read -r f nm d <<< "$a"
    [ -d "/Applications/$f.app" ] || continue
    sz=$(dir_bytes "/Applications/$f.app")
    [ "$f" = GarageBand ] && sz=$(( sz + $(dir_bytes "/Library/Application Support/GarageBand" "/Library/Audio/Apple Loops") ))
    opt_add "$nm ($(human "$sz"))" "$d Dipindahkan ke Trash (masih bisa dikembalikan) dan bisa dipasang ulang gratis dari App Store." "app:$f" "${DIM}opsional" 0 0 0
  done
  opt_add "Privasi & gangguan" "" "" "" 0 1 0 1
  local siri ads; siri=$(defaults read com.apple.assistant.support "Assistant Enabled" 2>/dev/null); ads=$(defaults read com.apple.AdLib allowApplePersonalizedAdvertising 2>/dev/null)
  opt_add "Matikan iklan yang dipersonalisasi Apple" "Apple tidak memakai data kamu untuk iklan di App Store, News dan Stocks." "tw:ads" "$( [ "$ads" = 0 ] && printf '%s✓ sudah' "$GRN")" $( [ "$ads" = 0 ] && echo 0 || echo 1) $( [ "$ads" = 0 ] && echo 1 || echo 0) 1
  opt_add "Matikan Siri" "Siri dan proses latarnya tidak berjalan. Hemat RAM di Mac lama." "tw:siri" "$( [ "$siri" = 0 ] && printf '%s✓ sudah' "$GRN")" 0 $( [ "$siri" = 0 ] && echo 1 || echo 0) 0
  opt_add "Matikan kirim data analitik & crash ke Apple" "Membuka System Settings > Privacy & Security > Analytics & Improvements (pengaturan ini dilindungi sistem)." "tw:analytics" "" 0 0 0
  opt_add "Sembunyikan aplikasi terbaru di Dock" "Dock hanya berisi aplikasi yang kamu pin." "tw:recents" "" 1 0 1
  select_list "Debloat macOS" "Hapus aplikasi Apple opsional yang besar dan matikan gangguan. Aplikasi sistem yang dilindungi macOS (SIP) tidak bisa dan tidak akan dihapus." multi 0 "jalankan"
  [ "$RES_OK" != 1 ] && return
  printf '%s\n  %s═══ DEBLOAT ═══%s\n\n' "$E[2J$E[H" "$MAG" "$R0"; show_cur
  case "$RES_VALUES" in *app:*) sudo -v ;; esac
  local v
  for v in $RES_VALUES; do
    log "DEBLOAT $v"
    case $v in
      app:*) f=${v#app:}; sudo mv "/Applications/$f.app" ~/.Trash/ 2>>"$LOG" && printf '   %s✓ %s dipindah ke Trash%s\n' "$GRN" "$f" "$R0" || printf '   %s✗ %s gagal%s\n' "$RED" "$f" "$R0"
             if [ "$f" = GarageBand ]; then sudo rm -rf "/Library/Application Support/GarageBand" "/Library/Audio/Apple Loops/Apple" 2>/dev/null; fi ;;
      tw:ads) defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false; printf '   %s✓ iklan personal mati%s\n' "$GRN" "$R0" ;;
      tw:siri) defaults write com.apple.assistant.support "Assistant Enabled" -bool false; defaults write com.apple.Siri StatusMenuVisible -bool false; launchctl disable "gui/$(id -u)/com.apple.Siri.agent" 2>/dev/null; printf '   %s✓ Siri mati%s\n' "$GRN" "$R0" ;;
      tw:analytics) open "x-apple.systempreferences:com.apple.preference.security?Privacy_Analytics" 2>/dev/null; printf '   %s→ System Settings dibuka%s\n' "$CYN" "$R0" ;;
      tw:recents) defaults write com.apple.dock show-recents -bool false; killall Dock 2>/dev/null; printf '   %s✓ recent apps disembunyikan%s\n' "$GRN" "$R0" ;;
    esac
  done
  pause_key
}

show_sysinfo() {
  local rt
  if [ "$SYS_RAM" -lt 8 ]; then rt="RAM di bawah 8GB: hindari Docker Desktop/Android Studio, pakai OrbStack dan editor ringan."
  elif [ "$SYS_RAM" -lt 16 ]; then rt="RAM 8GB: cukup untuk kuliah. Apple Silicon sangat efisien, tapi emulator + Docker bersamaan akan terasa."
  else rt="RAM 16GB+: aman untuk Docker, Android Studio dan LLM lokal."; fi
  opt_reset
  opt_add "Mac     : $SYS_MODEL" "Model Mac ($SYS_CHIP)."
  opt_add "OS      : $SYS_OS" "Versi macOS. Update lewat System Settings > General > Software Update."
  opt_add "CPU     : ${SYS_CPU:0:40}" "$SYS_CORES, arsitektur $SYS_ARCH."
  opt_add "RAM     : $SYS_RAM GB" "$rt"
  opt_add "Disk    : $SYS_DISKFREE GB kosong / $SYS_DISKTOT GB" "Sisakan minimal 30GB untuk Xcode/tool dev dan proyek."
  opt_add "Homebrew: $(brew --version | head -1)" "Package manager yang dipakai script ini. Lokasi: $(brew --prefix)"
  opt_add "Katalog : $(inst_count)/$NCAT aplikasi terpasang" "Lihat menu Cek Status untuk detailnya."
  select_list "Info Sistem" "" single 0 "kembali"
}

main_menu() {
  local i
  while true; do
    HDR=()
    if [ "$(tput lines)" -ge 40 ]; then
      for ((i=0;i<6;i++)); do HDR+=("  ${BCOL[$i]}${BANNER[$i]}${R0}"); done
      HDR+=("      ${DIM}I F  ·  $USER@$SYS_MODEL  ·  $SYS_CHIP  ·  RAM ${SYS_RAM}GB  ·  $(inst_count)/$NCAT app terpasang${R0}"); HDR+=("")
    fi
    local cc; cc=$(cart_count)
    opt_reset
    opt_add "🧙 Wizard Preferensi" "Jawab ${#WIZ[@]} pertanyaan singkat (browser, unarchiver, terminal, editor, bahasa, pengganti WSL, dst). Setiap pilihan ada penjelasan dan rekomendasinya. PALING DISARANKAN untuk Mac baru." wiz "${YEL}★ mulai di sini"
    opt_add "📦 Profil Siap Pakai" "Paket sekali klik: Starter Mahasiswa IF, Web, Mobile, Data/AI, Jaringan & Security, DevOps, Game, Desain, Power User." prof
    opt_add "🗂  Pilih Manual per Kategori" "Jelajahi $NCAT aplikasi dalam ${#CATS[@]} kategori lalu centang sendiri." cat
    opt_add "🔍 Cek Status Mac" "Lihat semua aplikasi: mana yang sudah terpasang dan mana yang belum. Laporan disimpan ke laporan-status.txt." status "${GRN}$(inst_count)/$NCAT terpasang"
    opt_add "🛒 Keranjang & Install" "Tinjau daftar yang akan dipasang lalu mulai instalasi otomatis dengan progress bar." cart "$( [ "$cc" -gt 0 ] && printf '%s%s item siap' "$CYN" "$cc" || printf '%skosong' "$DIM")"
    opt_add "🧩 Ekstensi VS Code" "Pasang ekstensi VS Code penting: C/C++, Code Runner, Python, Java, Live Server, GitLens, Error Lens, dll." ext
    opt_add "🔑 Setup Git & SSH Key GitHub" "Atur nama/email Git, buat SSH key, simpan di Keychain, copy ke clipboard, buka GitHub, gh auth login." git
    opt_add "⚙️  Tweak macOS untuk Developer" "Tampilkan ekstensi dan file tersembunyi, path bar, folder screenshot, key repeat cepat, tanpa .DS_Store di flashdisk." tweak
    opt_add "🚀 Tune-Up & Optimasi" "Bersihkan cache, log, Homebrew, cache developer & Xcode, snapshot Time Machine, percepat animasi, bebaskan RAM. Cocok untuk Mac lama yang mulai lemot." tune "$( [ "$SYS_RAM" -le 8 ] && printf '%s★ disarankan untuk Mac ini' "$YEL")"
    opt_add "🧹 Debloat macOS" "Hapus GarageBand/iMovie/Keynote/Numbers/Pages (bisa belasan GB), matikan iklan personal, Siri dan recent apps di Dock." debloat
    opt_add "🔄 Update Semua Aplikasi" "brew update + upgrade + upgrade --cask --greedy + cleanup." upd
    opt_add "💻 Info Sistem" "Spesifikasi Mac, chip, RAM, disk dan versi Homebrew." sys
    opt_add "🚪 Keluar" "Sampai jumpa! Semangat ngodingnya." quit
    select_list "Menu Utama" "Selamat datang! Pakai panah ↑↓ lalu Enter. Setiap menu punya penjelasan di kotak info bawah." single 0 "pilih"
    local v=quit; [ "$RES_OK" = 1 ] && v=$RES_VALUE
    HDR=()
    case $v in
      wiz) run_wizard ;; prof) pick_profile ;; cat) browse_category ;; status) show_all ;;
      cart) review_install ;; ext) setup_vscode_ext ;; git) setup_git ;; tweak) setup_tweaks ;;
      upd) update_all ;; sys) show_sysinfo ;; tune) tune_up ;; debloat) debloat ;;
      quit)
        if [ "$(cart_count)" -gt 0 ]; then printf '%s' "$E[2J$E[H"; echo; yesno "Keranjang masih berisi $(cart_count) item. Yakin keluar?" n || continue; fi
        printf '%s' "$E[2J$E[H"; printf '\n  %sTerima kasih sudah pakai DEVSETUP IF. Log: %s%s\n\n' "$MAG" "$LOG" "$R0"; return ;;
    esac
  done
}

# =====================================================================================
#  MAIN
# =====================================================================================
log "DEVSETUP IF macOS dimulai ($(uname -m), bash $BASH_VERSION, tes=$TEST_MODE)"
boot
if [ $SELFTEST = 1 ] && [ ${#KEYQ[@]} = 0 ]; then
  echo "SELFTEST katalog=$NCAT terpasang=$(inst_count) arch=$(uname -m) os=$(sw_vers -productVersion)"; exit 0
fi
if [ -n "$INSTALL_KEYS" ]; then
  want=$(echo "$INSTALL_KEYS" | tr ',' ' '); bad=""
  for k in $want; do case "$k" in *[!a-z0-9]*) bad="$bad $k"; continue ;; esac; [ -z "$(ix "$k")" ] && bad="$bad $k"; done
  [ -n "$bad" ] && echo "Key tidak dikenal:$bad"
  sync_cart "$want" "$want"
  if [ "$(cart_count)" -gt 0 ]; then install_cart; else echo "Semua aplikasi yang diminta sudah terpasang."; fi
  [ "$INSTALL_FAIL" -gt 0 ] && exit 3; exit 0
fi
if [ -n "$PRESET" ]; then
  found=""; for p in "${PROFILES[@]}"; do [ "${p%%|*}" = "$PRESET" ] && found=${p##*|}; done
  [ -z "$found" ] && { echo "Preset '$PRESET' tidak dikenal."; exit 1; }
  sync_cart "$found" "$found"; install_cart
  [ "$INSTALL_FAIL" -gt 0 ] && exit 3
else
  main_menu
fi
