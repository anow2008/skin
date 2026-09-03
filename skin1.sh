#!/bin/sh
# anow2008 - Enigma2 GitHub Skins1 Installer Script

# --- رابط جيت هاب المباشر (Raw Link) ---
URL_TAR_GZ="https://raw.githubusercontent.com/anow2008/skin/main/skins1.tar.gz"
# -------------------------------------------

ARCHIVE_PATH="/tmp/skins1.tar.gz"
EXTRACT_DIR="/tmp/extracted_skins1"

echo "====== [1/4] Downloading Skins1 Archive from GitHub ======"
# تحميل ملف الأرشيف
wget --no-check-certificate "$URL_TAR_GZ" -O "$ARCHIVE_PATH"

if [ $? -ne 0 ] || [ ! -s "$ARCHIVE_PATH" ]; then
    echo "❌ Error: Failed to download skins1 archive from GitHub!"
    exit 1
fi

echo "====== [2/4] Extracting Archive ======"
# إنشاء الفولدر المؤقت وفك الضغط
mkdir -p "$EXTRACT_DIR"
tar -xzf "$ARCHIVE_PATH" -C "$EXTRACT_DIR"

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to extract $ARCHIVE_PATH"
    rm -f "$ARCHIVE_PATH"
    rm -rf "$EXTRACT_DIR"
    exit 1
fi

echo "====== [3/4] Installing Skins1 IPK File(s) ======"
# تحديث الفيد لضمان التثبيت بدون نقص اعتماديات
opkg update

# التثبيت
cd "$EXTRACT_DIR"
if ls *.ipk 1> /dev/null 2>&1; then
    opkg install *.ipk
else
    echo "❌ Error: No .ipk file found inside the skins1 archive!"
    rm -f "$ARCHIVE_PATH"
    rm -rf "$EXTRACT_DIR"
    exit 1
fi

echo "====== [4/4] Cleaning Up ======"
# تنظيف مسار /tmp
rm -f "$ARCHIVE_PATH"
rm -rf "$EXTRACT_DIR"

echo "✅ Done! Skins1 installation completed successfully."
echo "🔄 Restarting Enigma2 GUI to apply changes..."
sleep 2

# أمر إعادة تشغيل وجهة الرسيفر تلقائياً لتطبيق الاسكين فوراً
killall -9 enigma2

exit 0
