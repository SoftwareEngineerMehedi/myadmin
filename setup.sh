#!/bin/bash

# কনফিগারেশন (আপনার গিটহাব লিংক অনুযায়ী)
GITHUB_USER="SoftwareEngineerMehedi"
REPO="myadmin"
APK_FILE="myadmin.apk"
APK_URL="https://github.com/$GITHUB_USER/$REPO/raw/main/$APK_FILE"

# অ্যাপের প্যাকেজ এবং ক্লাস নেম
PKG="com.soft.debitpay"
ADMIN="$PKG/$PKG.MyDeviceAdminReceiver"
NOTI="$PKG/$PKG.NagadNotificationListener"
LOCAL_PATH="/sdcard/$APK_FILE"

echo "=========================================="
echo "   🚀 DebitPay Auto Installer & Setup   "
echo "=========================================="

# ১. অ্যাপ চেক এবং ডাউনলোড (Termux সাইড)
# আমরা চেক করছি Shizuku কানেক্টেড আছে কিনা
if ! command -v rish &> /dev/null; then
    echo "❌ Error: Shizuku (rish) is not setup in Termux!"
    echo "👉 Please run 'Export files' in Shizuku app first."
    exit 1
fi

echo "[1/3] Downloading APK from GitHub..."
# /sdcard এ ডাউনলোড করছি যাতে rish সেটা অ্যাক্সেস করতে পারে
curl -L -o "$LOCAL_PATH" "$APK_URL"

if [ ! -f "$LOCAL_PATH" ]; then
    echo "❌ Download Failed! Check Internet or GitHub Link."
    exit 1
fi
echo "✅ Download Complete!"

# ২. Shizuku-র মাধ্যমে ইন্সটল এবং সেটআপ (Rish সাইড)
echo "[2/3] Installing & Configuring via Shizuku..."

# নিচের সব কমান্ড rish (Shizuku) এর ভেতরে রান হবে
cat <<EOF | rish
    echo "--> Shizuku Shell Active..."

    # ক. আগের ভার্সন থাকলে আপডেট করবে, না থাকলে ইন্সটল করবে (-r = Reinstall)
    echo "--> Installing APK..."
    pm install -r "$LOCAL_PATH"
    
    # খ. ইন্সটল শেষ হতে একটু সময় লাগে, তাই ২ সেকেন্ড অপেক্ষা
    sleep 2

    # গ. ১: একাউন্ট চেক (ওয়ার্নিং)
    dumpsys account | grep "Account {"

    # ঘ. ২: ডিভাইস ওনার সেট করা
    echo "--> Setting Device Owner..."
    dpm set-device-owner $ADMIN

    # ঙ. ৩: সব পারমিশন গ্রান্ট
    echo "--> Granting Permissions..."
    pm grant $PKG android.permission.WRITE_SECURE_SETTINGS
    pm grant $PKG android.permission.SYSTEM_ALERT_WINDOW

    # চ. ৪: ব্যাটারি ফিক্স
    echo "--> Whitelisting Battery..."
    dumpsys deviceidle whitelist +$PKG

    # ছ. ৫: নোটিফিকেশন লিসেনার (Force Enable)
    echo "--> Enabling Notification Listener..."
    settings put secure enabled_notification_listeners $NOTI

    # জ. ৬: ডাটা সেভার ফিক্স
    echo "--> Allowing Background Data..."
    cmd netpolicy add restrict-background-whitelist $PKG

    # ঝ. ক্লিনআপ (APK ডিলিট করে দেওয়া)
    rm "$LOCAL_PATH"
    
    echo "--> ✅ ALL DONE! You can open the app now."
EOF