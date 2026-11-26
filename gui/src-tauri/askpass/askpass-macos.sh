#!/bin/sh
# Dialog password grafis untuk sudo -A (dipakai Homebrew & TIPACK saat berjalan dari aplikasi GUI)
/usr/bin/osascript -e 'display dialog "TIPACK butuh password Mac kamu untuk memasang aplikasi." default answer "" with hidden answer with title "TIPACK" with icon caution buttons {"Batal", "OK"} default button "OK"' -e 'text returned of result' 2>/dev/null
