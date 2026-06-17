#!/bin/sh
# anow2008 - Enigma2 GitHub Skin Installer Script

# --- روابط جيت هاب المباشرة (Raw Links) ---
# ضع هنا رابط ملف الـ tar.gz الخاص بالاسكين بتاعك على جيت هاب
URL_TAR_GZ="https://raw.githubusercontent.com/anow2008/skins/main/myskin/skin.tar.gz"
# -------------------------------------------

ARCHIVE_PATH="/tmp/skin.tar.gz"
EXTRACT_DIR="/tmp/extracted_skin"

echo "====== [1/4] Downloading Skin Archive from GitHub ======"
# تحميل ملف الأرشيف
wget --no-check-certificate "$URL_TAR_GZ" -O "$ARCHIVE_PATH"

if [ $? -ne 0 ] || [ ! -s "$ARCHIVE_PATH" ]; then
    echo "❌ Error: Failed to download skin archive from GitHub!"
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

echo "====== [3/4] Installing Skin IPK File(s) ======"
# تحديث الفيد لضمان تثبيت أي ملفات جرافيكس أو بلجنز مساعدة يعتمد عليها الاسكين
opkg update

# التثبيت
cd "$EXTRACT_DIR"
if ls *.ipk 1> /dev/null 2>&1; then
    opkg install *.ipk
else
    echo "❌ Error: No .ipk file found inside the skin archive!"
    rm -f "$ARCHIVE_PATH"
    rm -rf "$EXTRACT_DIR"
    exit 1
fi

echo "====== [4/4] Cleaning Up ======"
# تنظيف مسار /tmp
rm -f "$ARCHIVE_PATH"
rm -rf "$EXTRACT_DIR"

echo "✅ Done! Skin installation completed successfully."
echo "💡 Tip: Please restart the Enigma2 GUI to apply the new skin."
exit 0
