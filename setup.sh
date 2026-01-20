#!/bin/bash

# কনফিগারেশন
GITHUB_USER="SoftwareEngineerMehedi"
REPO="myadmin"
APK_FILE="myadmin.apk"
APK_URL="https://github.com/$GITHUB_USER/$REPO/raw/main/$APK_FILE"

PKG="com.soft.debitpay"
ADMIN="$PKG/$PKG.MyDeviceAdminReceiver"
NOTI="$PKG/$PKG.NagadNotificationListener"
LOCAL_PATH="/sdcard/$APK_FILE"

echo "=========================================="
echo "   🚀 DebitPay Auto Installer & Setup   "
echo "=========================================="

# ১. Rish লোকেশন ডিটেক্ট করা (FIXED)
if [ -f "./rish" ]; then
    RISH_CMD="./rish"
    echo "✅ Found Shizuku (Local ./rish)"
elif command -v rish &> /dev/null; then
    RISH_CMD="rish"
    echo "✅ Found Shizuku (Global rish)"
else
    echo "❌ Error: Shizuku (rish) not found!"
    echo "👉 Please make sure 'rish' file is in this folder."
    exit 1
fi

# ২. পারমিশন ঠিক করা (যদি লাগে)
chmod +x $RISH_CMD

echo "[1/3] Downloading APK..."
# সাইলেন্ট মোড কিন্তু প্রগ্রেস বার সহ ডাউনলোড
curl -L -o "$LOCAL_PATH" "$APK_URL" --progress-bar

if [ ! -f "$LOCAL_PATH" ]; then
    echo "❌ Download Failed! Check Link."
    exit 1
fi

# ৩. Shizuku-র মাধ্যমে ইন্সটল এবং সেটআপ
echo "[2/3] Installing & Configuring..."

# ভেরিয়েবলসহ rish এ কমান্ড পাঠানো
cat <<EOF | $RISH_CMD
    echo "--> Shizuku Shell Active..."

    echo "--> Installing APK (Reinstall mode)..."
    pm install -r "$LOCAL_PATH"
    sleep 3

    echo "--> Checking Accounts..."
    dumpsys account | grep "Account {"

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

    rm "$LOCAL_PATH"
    echo "--> ✅ ALL DONE! SUCCESS."
EOF