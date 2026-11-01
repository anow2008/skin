#!/bin/sh
##############################################################
# Premium-FHD-Blue skin installer (Enigma2)
# Usage:
#   wget -q --no-check-certificate -O - https://raw.githubusercontent.com/anow2008/skin/main/installer.sh | sh
##############################################################

PKG_NAME="enigma2-plugin-skins-premium-fhd-blue"
IPK_FILE="enigma2-plugin-skins-premium-fhd-blue_3.1-r2_all.ipk"
IPK_URL="https://raw.githubusercontent.com/anow2008/skin/main/${IPK_FILE}"
TMP_IPK="/tmp/${IPK_FILE}"
MIN_SIZE=1000000        # bytes - anything smaller is not the real package
MIN_FREE_KB=40000       # free space needed on the root filesystem

cleanup() {
    rm -f "$TMP_IPK"
}
trap cleanup EXIT

fail() {
    echo ""
    echo "ERROR: $1"
    exit 1
}

echo "=========================================="
echo "  Premium-FHD-Blue skin installer"
echo "=========================================="

# --- checks -------------------------------------------------
[ "$(id -u)" = "0" ] || fail "Please run as root."

command -v opkg >/dev/null 2>&1 || fail "opkg not found. This installer supports opkg-based images only."

if [ ! -d /usr/lib/enigma2 ] && [ ! -d /usr/share/enigma2 ]; then
    fail "Enigma2 was not found on this device."
fi

FREE_KB=$(df -k / 2>/dev/null | tail -1 | awk '{print $(NF-2)}')
case "$FREE_KB" in
    ''|*[!0-9]*) ;;   # could not read the value, continue anyway
    *)
        if [ "$FREE_KB" -lt "$MIN_FREE_KB" ]; then
            fail "Not enough free space: ${FREE_KB} KB free, ${MIN_FREE_KB} KB needed."
        fi
        ;;
esac

# --- download -----------------------------------------------
echo "> Downloading package..."
rm -f "$TMP_IPK"

if command -v wget >/dev/null 2>&1; then
    wget -q --no-check-certificate -O "$TMP_IPK" "$IPK_URL" \
        || wget -q -O "$TMP_IPK" "$IPK_URL"
elif command -v curl >/dev/null 2>&1; then
    curl -fsSLk -o "$TMP_IPK" "$IPK_URL"
else
    fail "Neither wget nor curl is available."
fi

[ -s "$TMP_IPK" ] || fail "Download failed. Check the internet connection and try again."

SIZE=$(wc -c < "$TMP_IPK" | tr -d ' ')
if [ "$SIZE" -lt "$MIN_SIZE" ]; then
    fail "Downloaded file is too small (${SIZE} bytes). The link may be wrong."
fi

# an .ipk built with ar starts with this signature
if [ "$(head -c 7 "$TMP_IPK")" != "!<arch>" ]; then
    fail "Downloaded file is not a valid .ipk package."
fi
echo "  OK (${SIZE} bytes)"

# --- install ------------------------------------------------
if opkg list-installed 2>/dev/null | grep -q "^${PKG_NAME} "; then
    echo "> Removing the previous version..."
    opkg remove --force-depends "$PKG_NAME" >/dev/null 2>&1
fi

echo "> Installing..."
if ! opkg install --force-reinstall --force-overwrite "$TMP_IPK"; then
    fail "Installation failed."
fi

sync

echo ""
echo "=========================================="
echo "  Installed successfully."
echo "  Next: Menu > Setup > System > Skin"
echo "  choose Premium-FHD-Blue, then restart GUI."
echo "=========================================="
exit 0
