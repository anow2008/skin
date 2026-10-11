#!/bin/sh
URL="https://raw.githubusercontent.com/anow2008/skin/main/skins.tar.gz"
ARCHIVE="/tmp/skins.tar.gz"
DIR="/tmp/extracted_skin"

rm -rf "$DIR" "$ARCHIVE"
mkdir -p "$DIR"

echo "[1/4] Downloading..."
if command -v curl >/dev/null 2>&1; then
    curl -k -L -f -o "$ARCHIVE" "$URL"
else
    wget --no-check-certificate -O "$ARCHIVE" "$URL" || wget -O "$ARCHIVE" "$URL"
fi
[ -s "$ARCHIVE" ] || { echo "Download failed"; exit 1; }

echo "[2/4] Extracting..."
tar -xzf "$ARCHIVE" -C "$DIR" || { echo "Extract failed"; exit 1; }

echo "[3/4] Installing..."
opkg update
IPKS=$(find "$DIR" -name "*.ipk")
[ -n "$IPKS" ] || { echo "No ipk found"; ls -R "$DIR"; exit 1; }
opkg install --force-overwrite --force-reinstall $IPKS

echo "[4/4] Cleaning..."
rm -rf "$ARCHIVE" "$DIR"

echo "Restarting GUI..."
sleep 2
killall -9 enigma2
