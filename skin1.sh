#!/bin/sh
URL="https://raw.githubusercontent.com/anow2008/skin/main/skins1.tar.gz"
ARCHIVE="/tmp/skins1.tar.gz"
DIR="/tmp/extracted_skins1"

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
IPKS=$(find "$DIR" -name "*.ipk")
if [ -n "$IPKS" ]; then
    opkg update
    opkg install --force-overwrite --force-reinstall $IPKS
else
    echo "No ipk found. Archive contents:"
    ls -R "$DIR" | head -40
    exit 1
fi

echo "[4/4] Cleaning..."
rm -rf "$ARCHIVE" "$DIR"

echo "Restarting GUI..."
sleep 2
killall -9 enigma2
