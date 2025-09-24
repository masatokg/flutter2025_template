
#!/bin/bash
set -x
# 既存プロセスの停止（重複起動防止）
pkill -f xfwm4 || true
pkill -f xfsettingsd || true
pkill -f xfdesktop || true
pkill -f xfce4-session || true
pkill -f screensaver || true
pkill -f xiccd || true
pkill -f xfce4-power-manager || true
pkill -f notification-daemon || true
pkill -f xfce4-volumed || true

# /tmp/.ICE-unix の所有者修正
if [ -d /tmp/.ICE-unix ]; then
	sudo chown root:root /tmp/.ICE-unix || true
fi

# 必要なパッケージのインストール（不足時のみ）
for pkg in xfce4 xfce4-session xfce4-power-manager colord xiccd pm-utils; do
	dpkg -s $pkg >/dev/null 2>&1 || sudo apt-get update && sudo apt-get install -y $pkg
done

# VNCサーバーとAndroidエミュレーターを起動するスクリプト

# Xvfb 仮想ディスプレイ起動
export DISPLAY=:1
Xvfb :1 -screen 0 1280x720x24 &
sleep 2

# Xvfbが生成したcookieを抽出し、ユーザーのホームディレクトリに書き出す
XAUTH=/home/developer/.Xauthority
touch $XAUTH
xauth add :1 . $(mcookie)

# DBus デーモン起動
eval $(dbus-launch --sh-syntax)

# XFCE セッション起動
startxfce4 &

# x11vnc 起動（-bgでバックグラウンド、-oでログ出力、-authでXauthority指定）
x11vnc -display :1 -rfbport 5901 -nopw -forever -shared -bg -o /tmp/x11vnc.log -auth $XAUTH
echo "VNC server started on display :1 (port 5901)"

# スクリーンセーバー・画面ロック無効化
xfconf-query -c xfce4-session -p /screensaver/enabled -t bool -s false
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -t bool -s false
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -t int -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -t int -s 0
pkill xfce4-screensaver || true
pkill light-locker || true

echo "====================="
echo "このターミナルは閉じないでください。"
echo "操作するには、新しいターミナルを開いてくさださい。"
echo "flutterプロジェクトフォルダを生成するには、以下のコマンドをターミナルで実行してください\nflutter create \"プロジェクト名\""
echo "「my_appプロジェクトを生成する」例） flutter create my_app"
echo "そして作成したプロジェクトフォルダへ移動して、flutter run コマンドでプロジェクトアプリを実行してください。"
echo "cd my_app"
echo "flutter run"
echo "====================="

sleep infinity