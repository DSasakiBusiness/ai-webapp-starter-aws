#!/bin/sh
# =============================================================================
# wait-for-it.sh - TCP ポートの接続可能を待つユーティリティ
# =============================================================================
# Usage: ./scripts/wait-for-it.sh host:port [-t timeout] [-- command args]
#
# Docker Compose のサービス間依存で、healthcheck だけでは不十分な
# 場合（DB マイグレーション前の DB 起動待ちなど）に使用する。
# =============================================================================

set -e

TIMEOUT=30
HOST=""
PORT=""
QUIET=0

usage() {
  echo "Usage: $0 host:port [-t timeout] [-q] [-- command args]"
  exit 1
}

wait_for() {
  local start_ts=$(date +%s)
  while :; do
    if nc -z "$HOST" "$PORT" 2>/dev/null; then
      local end_ts=$(date +%s)
      if [ "$QUIET" -eq 0 ]; then
        echo "$HOST:$PORT is available after $((end_ts - start_ts)) seconds"
      fi
      break
    fi
    local now_ts=$(date +%s)
    if [ $((now_ts - start_ts)) -ge "$TIMEOUT" ]; then
      echo "Timeout: $HOST:$PORT did not become available within ${TIMEOUT}s" >&2
      exit 1
    fi
    sleep 1
  done
}

# 引数パース
while [ $# -gt 0 ]; do
  case "$1" in
    *:*)
      HOST=$(echo "$1" | cut -d: -f1)
      PORT=$(echo "$1" | cut -d: -f2)
      shift
      ;;
    -t)
      TIMEOUT="$2"
      shift 2
      ;;
    -q)
      QUIET=1
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
  usage
fi

wait_for

# -- 以降のコマンドを実行
if [ $# -gt 0 ]; then
  exec "$@"
fi
