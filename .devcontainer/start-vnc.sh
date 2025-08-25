#!/bin/bash


# Xvfb 仮想ディスプレイ起動
export DISPLAY=:1
Xvfb :1 -screen 0 1280x720x24 &
sleep 2

# Xvfbが生成したcookieを抽出してXauthorityファイルに書き出す
XAUTH=/tmp/.Xauthority
xauth extract $XAUTH :1
export XAUTHORITY=$XAUTH

# DBus デーモン起動
eval $(dbus-launch --sh-syntax)

# XFCE セッション起動
startxfce4 &

# x11vnc 起動（-bgでバックグラウンド、-oでログ出力、-authでXauthority指定）
x11vnc -display :1 -rfbport 5901 -nopw -forever -shared -bg -o /tmp/x11vnc.log -auth $XAUTH
echo "VNC server started on display :1 (port 5901)"

# Android Emulator をバックグラウンド起動
echo "Starting Android Emulator..."
# Android SDKのパスを絶対パスで指定
/opt/Android/sdk/emulator/emulator -avd Pixel_API_34 -noaudio -no-boot-anim -gpu swiftshader_indirect -no-snapshot &

# 全てのバックグラウンドプロセスが起動するのを待つ
sleep 10

# 無限ループでシェルをアクティブに保つ
while true; do
    tail -f /dev/null & wait ${!}
done