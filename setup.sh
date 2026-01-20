#!/bin/bash

# কনফিগারেশন
GITHUB_USER="SoftwareEngineerMehedi"
REPO="myadmin"
APK_FILE="myadmin.apk"
APK_URL="https://github.com/$GITHUB_USER/$REPO/raw/main/$APK_FILE"

PKG="com.soft.debitpay"
ADMIN="$PKG/$PKG.MyDeviceAdminReceiver"
NOTI="$PKG/$PKG.NagadNotificationListener"

# পাথ কনফিগারেশন
SDCARD_PATH="/sdcard/$APK_FILE"
TEMP_PATH="/data/local/tmp/$APK_FILE"

echo "=========================================="
echo "   🚀 DebitPay Auto Installer & Setup   "
echo "=========================================="

# ১. Rish ডিটেক্ট করা
if [ -f "./rish" ]; then
    RISH_CMD="./rish"
    echo "✅ Found Shizuku (Local ./rish)"
elif command -v rish &> /dev/null; then
    RISH_CMD="rish"
    echo "✅ Found Shizuku (Global rish)"
else
    echo "❌ Error: Shizuku (rish) not found!"
    exit 1
fi
chmod +x $RISH_CMD

# ২. ডাউনলোড (Termux দিয়ে - কারণ এখানে CURL আছে)
echo "[1/3] Downloading APK..."
curl -L -o "$SDCARD_PATH" "$APK_URL" --progress-bar

if [ ! -f "$SDCARD_PATH" ]; then
    echo "❌ Download Failed! Check Link or Internet."
    exit 1
fi
echo "✅ Download Complete in SD Card!"

# ৩. ইন্সটল ও সেটআপ (Shizuku দিয়ে - কারণ এখানে PM আছে)
echo "[2/3] Installing & Configuring..."

cat <<EOF | $RISH_CMD
    echo "--> Moving APK to System Temp..."
    # সিস্টেম ফোল্ডারে কপি করা হচ্ছে যাতে ইন্সটল এরর না দেয়
    cp "$SDCARD_PATH" "$TEMP_PATH"
    
    echo "--> Installing APK (Reinstall mode)..."
    pm install -r "$TEMP_PATH"
    
    # ইন্সটল হতে সময় লাগে
    sleep 5

    echo "--> Setting Device Owner..."
    dpm set-device-owner $ADMIN

    echo "--> Granting Permissions..."
    pm grant $PKG android.permission.WRITE_SECURE_SETTINGS
    pm grant $PKG android.permission.SYSTEM_ALERT_WINDOW

    echo "--> Whitelisting Battery..."
    dumpsys deviceidle whitelist +$PKG

    echo "--> Enabling Notification Listener..."
    settings put secure enabled_notification_listeners $NOTI

    echo "--> Background Data Fix..."
    cmd netpolicy add restrict-background-whitelist $PKG

    # ক্লিনআপ (ফাইল ডিলিট)
    rm "$TEMP_PATH"
    echo "--> ✅ ALL DONE! SUCCESS."
EOF

# এসডি কার্ড থেকেও ক্লিনআপ
rm "$SDCARD_PATH"