#!/bin/bash

# কনফিগারেশন
GITHUB_USER="SoftwareEngineerMehedi"
REPO="myadmin"
APK_FILE="myadmin.apk"
APK_URL="https://github.com/$GITHUB_USER/$REPO/raw/main/$APK_FILE"

PKG="com.soft.debitpay"
ADMIN="$PKG/$PKG.MyDeviceAdminReceiver"
NOTI="$PKG/$PKG.NagadNotificationListener"

# ফিক্স: আমরা এখন টেম্পোরারি ফোল্ডারে ফাইল রাখব যা সিস্টেম পড়তে পারে
LOCAL_PATH="/data/local/tmp/$APK_FILE"

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

echo "[1/3] Downloading APK..."

# ফিক্স: Shizuku দিয়ে ডাউনলোড করতে হবে কারণ সাধারণ ইউজারের /data/local/tmp তে পারমিশন থাকে না
cat <<EOF | $RISH_CMD
    echo "--> Downloading to System Temp Folder..."
    curl -L -o "$LOCAL_PATH" "$APK_URL" --silent
    
    if [ ! -f "$LOCAL_PATH" ]; then
        echo "❌ Download Failed inside Rish!"
        exit 1
    fi
    echo "✅ Download Success!"
    
    echo "[2/3] Installing & Configuring..."
    echo "--> Installing APK (Reinstall mode)..."
    
    # এখান থেকে ইন্সটল ১০০% কাজ করবে
    pm install -r "$LOCAL_PATH"
    
    # ইন্সটল হতে সময় লাগে, তাই ৫ সেকেন্ড অপেক্ষা
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

    # ক্লিনআপ
    rm "$LOCAL_PATH"
    
    echo "--> ✅ ALL DONE! SUCCESS."
EOF