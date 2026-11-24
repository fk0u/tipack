#!/usr/bin/env bash
# Uji di dalam container distro: deteksi, validasi semua nama paket native, dan install sungguhan beberapa item.
# Pakai: docker run --rm -v DIR:/t IMAGE /t/test-distro.sh   (DIR berisi setup.sh dan file ini)
cd /t || exit 1
# muat semua fungsi tanpa menjalankan bagian MAIN
sed '/^# *MAIN *$/,$d' setup.sh | sed '$d' > /tmp/lib.sh
NOANIM=1; source /tmp/lib.sh 2>/dev/null
detect_distro; get_sysinfo >/dev/null 2>&1; resolve_methods
echo "DISTRO=$D_NAME | PM=$PM"
pm_refresh >/dev/null 2>&1 || echo "WARN refresh gagal"

exists() { # cek paket ada di repo
  case $PM in
    apt) apt-cache show "$1" >/dev/null 2>&1 ;;
    dnf) dnf -q list --available "$1" >/dev/null 2>&1 || dnf -q list --installed "$1" >/dev/null 2>&1 ;;
    pacman) pacman -Si "$1" >/dev/null 2>&1 ;;
    zypper) zypper --non-interactive -q info "$1" 2>/dev/null | grep -q "^Name *: *$1" ;;
    apk) [ -n "$(apk search -e "$1" 2>/dev/null)" ] ;;
  esac
}
nat=0; bad=""; aur=0; flat=0; scr=0; inf=0; none=0
for ((i=0;i<NCAT;i++)); do
  case "${K_TYPE[$i]}" in
    native) for p in ${K_ID[$i]}; do nat=$((nat+1)); exists "$p" || bad="$bad ${K_KEY[$i]}:$p"; done ;;
    aur) aur=$((aur+1)) ;; flatpak) flat=$((flat+1)) ;; script) scr=$((scr+1)) ;; info) inf=$((inf+1)) ;; *) none=$((none+1)) ;;
  esac
done
echo "METODE native-pkgs=$nat aur=$aur flatpak=$flat script=$scr manual=$inf tidak-tersedia=$none"
echo "PAKET-TIDAK-ADA:${bad:- (semua ada)}"
# install sungguhan
for k in git clipack build python; do
  i=$(ix $k); install_one "$i" >/tmp/inst.log 2>&1 && r=OK || r="GAGAL($(tail -2 /tmp/inst.log | tr '\n' ' '))"
  echo "INSTALL $k [${K_ID[$i]}] -> $r"
done
scan_installed
echo "TERDETEKSI-TERPASANG=$(inst_count): $(for ((i=0;i<NCAT;i++)); do [ "${INST[$i]}" = 1 ] && printf '%s ' "${K_KEY[$i]}"; done)"
