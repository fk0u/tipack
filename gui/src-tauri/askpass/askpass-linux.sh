#!/bin/sh
# Dialog password grafis untuk sudo -A (aplikasi GUI TIPACK di Linux)
MSG="TIPACK butuh password sudo untuk memasang aplikasi"
if command -v zenity >/dev/null 2>&1; then exec zenity --password --title="TIPACK" 2>/dev/null
elif command -v kdialog >/dev/null 2>&1; then exec kdialog --title "TIPACK" --password "$MSG" 2>/dev/null
elif command -v ssh-askpass >/dev/null 2>&1; then exec ssh-askpass "$MSG"
elif [ -x /usr/lib/ssh/x11-ssh-askpass ]; then exec /usr/lib/ssh/x11-ssh-askpass "$MSG"
else echo "Tidak ada dialog password (zenity/kdialog/ssh-askpass). Pasang zenity atau jalankan TIPACK di terminal." >&2; exit 1; fi
