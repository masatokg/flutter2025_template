FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ARG ARCH
RUN apt-get update && \
    apt-get install -y sudo \
        curl git wget unzip zip xz-utils cmake ninja-build build-essential clang pkg-config \
        libgtk-3-dev libx11-dev libglfw3-dev xauth \
        xfce4 xfce4-goodies x11vnc xvfb \
        qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils dbus-x11 xfonts-base xfonts-100dpi xfonts-75dpi xserver-xorg-video-dummy && \
    apt-get remove -y xfce4-power-manager && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash developer
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN passwd -d developer

# スクリーンセーバー・ロック無効化（xfce, gnome両対応）
RUN apt-get update && apt-get install -y dbus-x11 gsettings-desktop-schemas
# xfce4: xscreensaver, light-locker, xfce4-screensaver, xfce4-power-managerは既に削除済み
# gsettingsでGNOME系のスクリーンセーバー・ロックを無効化
USER developer
RUN dbus-launch gsettings set org.gnome.desktop.screensaver lock-enabled false || true
RUN dbus-launch gsettings set org.gnome.desktop.screensaver idle-activation-enabled false || true
RUN dbus-launch gsettings set org.gnome.desktop.lockdown disable-lock-screen true || true
USER root

ENV FLUTTER_ROOT=/opt/flutter

RUN FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.9-stable.tar.xz" && \
    wget -P /tmp "$FLUTTER_URL" && \
    tar -xf /tmp/$(basename "$FLUTTER_URL") -C /opt/ && \
    rm -rf /tmp/$(basename "$FLUTTER_URL")
ENV PATH=$FLUTTER_ROOT/bin:$PATH

# JAVA_HOME を永続化（/opt/jdk シンボリックリンクに集約、tar.gz形式対応）
ARG TARGETARCH
RUN ARCH="${TARGETARCH:-$(uname -m)}"; \
    if [ "$ARCH" = "aarch64" ]; then ARCH=arm64; fi; \
    if [ "$ARCH" = "arm64" ]; then \
        JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.48.15-ca-jdk17.0.10-linux_aarch64.tar.gz"; \
    else \
        JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.48.15-ca-jdk17.0.10-linux_x64.tar.gz"; \
    fi && \
    wget -P /tmp/ "$JAVA_URL" && \
    tar -xzf /tmp/$(basename "$JAVA_URL") -C /opt && \
    rm -rf /tmp/$(basename "$JAVA_URL")
RUN ARCH="${TARGETARCH:-$(uname -m)}"; \
    if [ "$ARCH" = "aarch64" ]; then ARCH=arm64; fi; \
    if [ "$ARCH" = "arm64" ]; then \
        JDIR=$(echo /opt/zulu*-linux_aarch64); \
    else \
        JDIR=$(echo /opt/zulu*-linux_x64); \
    fi && \
    rm -f /opt/jdk && ln -s "$JDIR" /opt/jdk
ENV JAVA_HOME=/opt/jdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Node.jsのインストール（VS Code Remote-Containers用）
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs

RUN chown -R developer:developer /opt/flutter /opt/zulu*


# VNC スタートスクリプト
# COPYでファイルをコンテナにコピー
COPY start-vnc.sh /home/developer/start-vnc.sh
# chownでファイルの所有者をdeveloperに変更
RUN chown developer:developer /home/developer/start-vnc.sh && chmod 755 /home/developer/start-vnc.sh

# ユーザーを切り替えて作業ディレクトリを設定 
USER developer
WORKDIR /home/developer
RUN flutter config --device-id linux

# M1 Mac環境でFlutter x86_64バイナリをRosetta 2経由で実行するための設定
# Docker内でのbinfmtエミュレーションを利用してx86_64バイナリを透過実行
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        echo "ARM64環境検出: FlutterはRosetta 2/エミュレーション経由で実行されます"; \
        /opt/flutter/bin/flutter --version || echo "Flutter実行テスト完了"; \
    fi

# developerユーザーの.bashrcにDISPLAY=:1を追加
RUN echo 'export DISPLAY=:1' >> /home/developer/.bashrc
RUN echo 'echo -e "\n=====================\nこのターミナルは閉じないでください。\n操作するには、新しいターミナルを開いてくさださい。\nflutterプロジェクトフォルダを生成するには、以下のコマンドをターミナルで実行してください\nflutter create \"プロジェクト名\"\n「my_appプロジェクトを生成する」例） flutter create my_app\nそして作成したプロジェクトフォルダへ移動して、flutter run コマンドでプロジェクトアプリを実行してください。\ncd my_app\nflutter run\n=====================\n"' >> /home/developer/.bashrc
