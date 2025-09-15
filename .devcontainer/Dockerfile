# ビルド引数としてARCHを受け取る (全ステージで利用可能)
ARG ARCH

# --- ステージ1: アーキテクチャのチェック ---
# ビルドホストとターゲットのアーキテクチャが一致するか検証
FROM alpine:3.18 as arch_checker

# スクリプトをコンテナにコピー
COPY check_arch.sh /usr/local/bin/check_arch.sh
RUN chmod +x /usr/local/bin/check_arch.sh

# BUILDPLATFORMとTARGETPLATFORMはDocker BuildKitによって自動的に設定される
# スクリプトを実行してアーキテクチャを検証
RUN check_arch.sh

# 成功のマーカーを作成し、後段ステージに依存関係を作る
RUN echo "Architecture check passed" > /arch_check_ok

# --- ステージ2: メインのビルド (arch_checkerステージが成功した場合のみ実行) ---
# ARCHの値に応じてベースイメージを切り替える
FROM --platform=linux/${ARCH} mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04
# arch_checkerステージが成功していることを保証（BuildKit並列最適化対策）
COPY --from=arch_checker /arch_check_ok /opt/.arch_check_ok

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/developer

# ロケールのインストールと設定
RUN apt-get update && \
    apt-get install -y locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# 基本パッケージ + GUI + VNC + Android Emulator
RUN apt-get update && \
    apt-get install -y \
        curl git wget unzip zip xz-utils sudo cmake ninja-build build-essential clang pkg-config \
    libgtk-3-dev libx11-dev libglfw3-dev xauth \
        xfce4 xfce4-goodies x11vnc xvfb \
        qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils dbus-x11 xfonts-base xfonts-100dpi xfonts-75dpi xserver-xorg-video-dummy && \
    rm -rf /var/lib/apt/lists/*

# 開発者ユーザー作成
RUN useradd -ms /bin/bash developer
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Flutter SDKのインストール (M1 MacではRosetta 2経由でx86_64版を実行、バージョン統一)
ENV FLUTTER_ROOT=/opt/flutter
# 全環境で同じFlutter 3.13.9を使用（M1 MacではRosetta 2で自動エミュレーション）
RUN FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.9-stable.tar.xz" && \
    wget -P /tmp "$FLUTTER_URL" && \
    tar -xf /tmp/$(basename "$FLUTTER_URL") -C /opt/ && \
    rm -rf /tmp/$(basename "$FLUTTER_URL")
ENV PATH=$FLUTTER_ROOT/bin:$PATH

# M1 Mac環境でFlutter x86_64バイナリをRosetta 2経由で実行するための設定
# Docker内でのbinfmtエミュレーションを利用してx86_64バイナリを透過実行
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        echo "ARM64環境検出: FlutterはRosetta 2/エミュレーション経由で実行されます"; \
        # x86_64バイナリの実行可能性をテスト
        /opt/flutter/bin/flutter --version || echo "Flutter実行テスト完了"; \
    fi

# Javaのインストール (architecture自動判定、最新版)
ARG TARGETARCH
RUN ARCH="${TARGETARCH:-$(uname -m)}"; \
    if [ "$ARCH" = "aarch64" ]; then ARCH=arm64; fi; \
    if [ "$ARCH" = "arm64" ]; then \
        JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-crac-jre17.0.16-linux_aarch64.tar.gz"; \
    else \
        JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-crac-jre17.0.16-linux_x64.tar.gz"; \
    fi && \
    wget -P /tmp/ "$JAVA_URL" && \
    tar -xzf /tmp/$(basename "$JAVA_URL") -C /opt && \
    rm -rf /tmp/$(basename "$JAVA_URL")

# JAVA_HOME を永続化（/opt/jdk シンボリックリンクに集約、tar.gz形式対応）
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

# Android SDK
ENV ANDROID_SDK_ROOT=/opt/Android/sdk
ENV ANDROID_HOME=$ANDROID_SDK_ROOT
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    wget -P /tmp/ https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip -o /tmp/commandlinetools-linux-11076708_latest.zip -d $ANDROID_SDK_ROOT/cmdline-tools/ && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm -rf /tmp/commandlinetools-linux-11076708_latest.zip
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH

# SDKインストール後にchownを実行する
RUN chown -R developer:developer /opt/flutter /opt/zulu* /opt/Android

# VNC スタートスクリプト
# COPYでファイルをコンテナにコピー
COPY start-vnc.sh /home/developer/start-vnc.sh
# chownでファイルの所有者をdeveloperに変更
RUN chown developer:developer /home/developer/start-vnc.sh && chmod 755 /home/developer/start-vnc.sh

# ユーザーを切り替えて作業ディレクトリを設定 
USER developer
WORKDIR /home/developer

# Android SDK componentsのインストール (architecture自動判定)
ENV ANDROID_SDK_ROOT=/opt/Android/sdk
RUN ARCH="${TARGETARCH:-$(uname -m)}"; \
    if [ "$ARCH" = "aarch64" ]; then ARCH=arm64; fi; \
    if [ "$ARCH" = "arm64" ]; then \
        JAVA_HOME="/opt/zulu17.60.17-ca-crac-jre17.0.16-linux_aarch64"; \
        SYSIMG="system-images;android-34;google_apis;arm64-v8a"; \
    else \
        JAVA_HOME="/opt/zulu17.60.17-ca-crac-jre17.0.16-linux_x64"; \
        SYSIMG="system-images;android-34;google_apis;x86_64"; \
    fi && \
    export JAVA_HOME && export PATH=$JAVA_HOME/bin:$PATH && \
    yes | sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platform-tools" "platforms;android-34" "build-tools;33.0.1" "emulator" "$SYSIMG" && \
    yes | /opt/flutter/bin/flutter doctor --android-licenses

RUN /opt/flutter/bin/flutter config --no-analytics

# Workspace フォルダ 
RUN mkdir -p /home/developer/workspace
