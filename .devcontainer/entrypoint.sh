#!/bin/bash
# entrypoint.sh

echo "Starting XFCE, VNC, and Android Emulator..."

export DISPLAY=:1

# Xvfb 起動
Xvfb :1 -screen 0 1920x1080x24 &
sleep 2

# dbus 起動
if [ ! -e /var/run/dbus/system_bus_socket ]; then
    dbus-uuidgen --ensure
    sudo service dbus start
fi

# XFCE デスクトップ起動
startxfce4 &

# x11vnc 起動
x11vnc -display :1 -forever -nopw -shared &

# Android Emulator AVD 作成（存在しない場合）
AVD_NAME="Pixel_7_API_34"
echo no | avdmanager create avd -n $AVD_NAME -k "system-images;android-34;google_apis;x86_64" --force

# Emulator 起動
$ANDROID_SDK_ROOT/emulator/emulator -avd $AVD_NAME -no-snapshot-load -no-boot-anim -no-audio -gpu swiftshader_indirect &

# bash フォールバック
exec /bin/bash
