#!/bin/sh
URL="https://raw.githubusercontent.com/anow2008/skin/main/enigma2-plugin-skins-aglare-fhd_8.5_all.ipk"
IPK="/tmp/enigma2-plugin-skins-aglare-fhd_8.5_all.ipk"

rm -f "$IPK"

echo "[1/3] Downloading..."
if command -v curl >/dev/null 2>&1; then
    curl -L -f -o "$IPK" "$URL" 2>/dev/null || {
        echo "Secure download failed, retrying without certificate check..."
        curl -k -L -f -o "$IPK" "$URL"
    }
else
    wget -q -O "$IPK" "$URL" 2>/dev/null || {
        echo "Secure download failed, retrying without certificate check..."
        wget --no-check-certificate -O "$IPK" "$URL"
    }
fi
[ -s "$IPK" ] || { echo "Download failed"; rm -f "$IPK"; exit 1; }

echo "[2/3] Installing..."
opkg update
if ! opkg install --force-overwrite --force-reinstall "$IPK"; then
    echo "Install failed"
    rm -f "$IPK"
    exit 1
fi

echo "[3/3] Cleaning..."
rm -f "$IPK"

echo "Restarting GUI..."
sleep 2
killall -9 enigma2
