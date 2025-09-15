#!/bin/sh
set -e

# Dockerビルド時に自動的に設定される変数からアーキテクチャ部分を抽出
# BUILDPLATFORM: ビルドを実行しているマシンのプラットフォーム (例: linux/amd64)
# TARGETPLATFORM: ビルド成果物のターゲットプラットフォーム (例: linux/arm64)
BUILD_ARCH=$(echo "$BUILDPLATFORM" | cut -d'/' -f2)
TARGET_ARCH=$(echo "$TARGETPLATFORM" | cut -d'/' -f2)

echo "Build host architecture: $BUILD_ARCH"
echo "Target architecture:     $TARGET_ARCH"

# 両方のアーキテクチャが定義されているが、一致しない場合にエラーとする
if [ -n "$BUILD_ARCH" ] && [ -n "$TARGET_ARCH" ] && [ "$BUILD_ARCH" != "$TARGET_ARCH" ]; then
    echo "--------------------------------------------------------------------------------"
    echo "!!! BUILD ERROR: Architecture mismatch !!!"
    echo ""
    echo "Your machine's architecture is '$BUILD_ARCH', but the build is targeting '$TARGET_ARCH'."
    echo "This can lead to severe performance issues or build failures."
    echo ""
    echo "Please update the '.devcontainer/.env' file to match your host architecture."
    echo "Example: PLATFORM=linux/$BUILD_ARCH"
    echo "--------------------------------------------------------------------------------"
    exit 1
fi

echo "Architectures match. Proceeding with the build."
