#!/bin/sh

PKG="com.soft.debitpay"
ADMIN="com.soft.debitpay/com.soft.debitpay.MyDeviceAdminReceiver"
NOTI="com.soft.debitpay/com.soft.debitpay.NagadNotificationListener"

echo "=== DebitPay Shizuku Setup ==="

# ১. একাউন্ট চেক (শুধু ওয়ার্নিং দিবে)
echo "[1/6] Checking Accounts..."
dumpsys account | grep "Account {"

# ২. ডিভাইস ওনার
echo "[2/6] Setting Device Owner..."
dpm set-device-owner $ADMIN

# ৩. পারমিশন গ্রান্ট
echo "[3/6] Granting Permissions..."
pm grant $PKG android.permission.WRITE_SECURE_SETTINGS
pm grant $PKG android.permission.SYSTEM_ALERT_WINDOW

# ৪. ব্যাটারি ফিক্স
echo "[4/6] Fixing Battery Optimization..."
dumpsys deviceidle whitelist +$PKG

# ৫. নোটিফিকেশন লিসেনার
echo "[5/6] Enabling Notification Listener..."
settings put secure enabled_notification_listeners $NOTI

# ৬. ডাটা সেভার ফিক্স
echo "[6/6] Allowing Background Data..."
cmd netpolicy add restrict-background-whitelist $PKG

echo "=== ✅ ALL DONE! ==="