#!/usr/bin/env bash
# Rakit linux/setup.sh = linux-parts.sh + mesin TUI dari macos/setup.sh (fungsi log() s/d sebelum install_ohmyzsh()).
# Fungsi khusus Linux didefinisikan SETELAH blok ini, jadi otomatis menimpa versi macOS.
set -e
cd "$(dirname "$0")"
MAC=../../macos/setup.sh
ENGINE=$(awk '/^log\(\) \{/{f=1} /^install_ohmyzsh\(\) \{/{f=0} f' "$MAC")
{
  awk '/^#@@MAC_ENGINE@@$/{exit} {print}' linux-parts.sh
  echo "# ======================= MESIN TUI (disalin otomatis dari macos/setup.sh) ======================="
  printf '%s\n' "$ENGINE"
  echo "# ======================= AKHIR MESIN TUI ======================="
  awk 'f{print} /^#@@MAC_ENGINE@@$/{f=1}' linux-parts.sh
} > ../setup.sh
chmod +x ../setup.sh
bash -n ../setup.sh && echo "linux/setup.sh dirakit ($(wc -l < ../setup.sh) baris), syntax OK"
