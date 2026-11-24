#!/usr/bin/env bash
# DEVSETUP IF - bootstrap macOS & Linux
# Pakai:  curl -fsSL https://tipack.kousozo.tech/install.sh | bash
#   atau: wget -qO- https://tipack.kousozo.tech/install.sh | bash
set -e
case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux)  OS=linux ;;
  *) echo "OS tidak didukung. Windows: irm https://tipack.kousozo.tech/install.ps1 | iex"; exit 1 ;;
esac
if [ "$(id -u)" = 0 ] && [ "$OS" = linux ] && [ -n "$SUDO_USER" ]; then
  echo "Jangan jalankan dengan sudo. Jalankan sebagai user biasa; password sudo akan diminta saat perlu."; exit 1
fi
DIR="$HOME/devsetup-if"
mkdir -p "$DIR"
echo "Mengunduh DEVSETUP IF ($OS) ke $DIR ..."
URL="https://tipack.kousozo.tech/$OS/setup.sh"
if command -v curl >/dev/null 2>&1; then curl -fsSL "$URL" -o "$DIR/setup.sh"
elif command -v wget >/dev/null 2>&1; then wget -qO "$DIR/setup.sh" "$URL"
else echo "Butuh curl atau wget."; exit 1; fi
chmod +x "$DIR/setup.sh"
cd "$DIR"
# stdin diarahkan ke keyboard karena script ini dijalankan lewat pipe
exec bash "$DIR/setup.sh" "$@" < /dev/tty
