
ARG TARGETARCH
FROM debian:bullseye-slim

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
        libgtk-3-dev libx11-dev libglfw3-dev \
        xfce4 xfce4-goodies x11vnc xvfb \
        qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils dbus-x11 xfonts-base xfonts-100dpi xfonts-75dpi xserver-xorg-video-dummy && \
    rm -rf /var/lib/apt/lists/*

# 開発者ユーザー作成
RUN useradd -ms /bin/bash developer
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Flutter SDKのインストール (architecture自動判定)
ENV FLUTTER_ROOT=/opt/flutter
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_arm64_3.13.9-stable.tar.xz"; \
    else \
        FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.9-stable.tar.xz"; \
    fi && \
    wget -P /tmp "$FLUTTER_URL" && \
    tar -xf /tmp/$(basename "$FLUTTER_URL") -C /opt/ && \
    rm -rf /tmp/$(basename "$FLUTTER_URL")
ENV PATH=$FLUTTER_ROOT/bin:$PATH


# Javaのインストール (architecture自動判定)
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        JAVA_HOME=/opt/zulu17.56.15-ca-jdk17.0.14-linux_aarch64; \
        JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-linux_aarch64.zip"; \
    else \
        JAVA_HOME=/opt/zulu17.56.15-ca-jdk17.0.14-linux_x64; \
        JAVA_URL="https://cdn.azul.com/zulu/bin/zulu17.56.15-ca-jdk17.0.14-linux_x64.zip"; \
    fi && \
    wget -P /tmp/ "$JAVA_URL" && \
    unzip -o /tmp/$(basename "$JAVA_URL") -d /opt && \
    rm -rf /tmp/$(basename "$JAVA_URL") && \
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile.d/java_home.sh && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java_home.sh
ENV JAVA_HOME=/opt/zulu17.56.15-ca-jdk17.0.14-linux_x64
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

# 実行権限を付与
# RUN chmod 755 /home/developer/start-vnc.sh

# ユーザーを切り替えて作業ディレクトリを設定 
USER developer
WORKDIR /home/developer

# Android SDK componentsのインストール (architecture自動判定)
ENV ANDROID_SDK_ROOT=/opt/Android/sdk
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        SYSIMG="system-images;android-34;google_apis;arm64-v8a"; \
    else \
        SYSIMG="system-images;android-34;google_apis;x86_64"; \
    fi && \
    yes | sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platform-tools" "platforms;android-34" "build-tools;33.0.1" "emulator" "$SYSIMG"
RUN yes | /opt/flutter/bin/flutter doctor --android-licenses
RUN /opt/flutter/bin/flutter config --no-analytics

# Workspace フォルダ 
RUN mkdir -p /home/developer/workspace

# コンテナ起動時にVNCを起動
# CMD ["/home/developer/start-vnc.sh"]