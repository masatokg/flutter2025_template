#!/usr/bin/env bash
set -euo pipefail

# このスクリプトは、同名コンテナの存在を事前チェックし、
# 日本語メッセージで案内して起動を中断します。
# 実行場所は任意ですが、.devcontainer ディレクトリ内で実行されることを想定しています。

# .devcontainer 直下に移動（このファイルが置かれている場所）
cd "$(dirname "$0")"

# .env の存在確認
if [[ ! -f ./.env ]]; then
  echo "エラー: .devcontainer/.env が見つかりません。CONTAINER_NAME と ARCH を設定してください。"
  echo "例:"
  echo "  CONTAINER_NAME=2025SD4_v01"
  echo "  ARCH=arm64   # M1/M2 の場合"
  echo "  ARCH=amd64   # Intel/AMD の場合"
  exit 1
fi

# CONTAINER_NAME の取得
CONTAINER_NAME_LINE=$(grep -E '^CONTAINER_NAME=' ./.env || true)
CONTAINER_NAME=${CONTAINER_NAME_LINE#CONTAINER_NAME=}

if [[ -z "${CONTAINER_NAME:-}" ]]; then
  echo "エラー: .env の CONTAINER_NAME が未設定です。CONTAINER_NAME を設定してください。"
  exit 1
fi

CNAME="flutter_devcontainer_${CONTAINER_NAME}"

# 同名コンテナの存在チェック
# if docker ps -a --format '{{.Names}}' | grep -Fxq "$CNAME"; then
#   echo "同名のコンテナ『${CNAME}』が既に存在します。起動を中断します。"
#   echo "対処方法:"
#   echo "  1) 既存コンテナを停止・削除する"
#   echo "     docker stop ${CNAME} && docker rm ${CNAME}"
#   echo "  2) .devcontainer/.env の CONTAINER_NAME を変更して再実行する"
#   exit 1
# fi

# 事前チェック通過 → 起動
exec docker compose up -d
