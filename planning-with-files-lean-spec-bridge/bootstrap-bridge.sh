#!/bin/bash
# planning-with-files-lean-spec-bridge: 将三件套协作文档复制到目标仓库 doc/plans/，便于就近查阅。
# 不修改 hooks/rules。需已存在 doc/plans（通常由 planning-with-files-ext 的 bootstrap 创建）。

set -euo pipefail

usage() {
  cat <<'EOT' >&2
用法:
  bash /path/to/planning-with-files-lean-spec-bridge/bootstrap-bridge.sh [target_root]

说明:
  - 默认 target_root 为当前目录。
  - 将 shared-skills/planning-with-files-lean-spec-bridge/planning-with-files-and-lean-spec-collaboration.md 复制到:
      <target_root>/doc/plans/COORDINATION_LEANSPEC.md
  - 若 doc/plans 不存在，将创建该目录（建议仍先运行 planning-with-files-ext 的 bootstrap 以安装 hooks）。
EOT
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

TARGET_ROOT="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_MD="${SCRIPT_DIR}/planning-with-files-and-lean-spec-collaboration.md"
DEST_DIR="${TARGET_ROOT}/doc/plans"
DEST_MD="${DEST_DIR}/COORDINATION_LEANSPEC.md"

if [[ ! -f "${SRC_MD}" ]]; then
  echo "[lean-spec-bridge] 错误: 找不到协作文档源文件: ${SRC_MD}" >&2
  exit 1
fi

mkdir -p "${DEST_DIR}"

NOW="$(date "+%Y-%m-%d %H:%M:%S")"
{
  echo "<!-- 由 bootstrap-bridge.sh 生成于 ${NOW}；源文件: shared-skills/planning-with-files-lean-spec-bridge/planning-with-files-and-lean-spec-collaboration.md -->"
  echo ""
  cat "${SRC_MD}"
} > "${DEST_MD}"

echo "[lean-spec-bridge] 已写入: ${DEST_MD}" >&2
echo "  若尚未安装 planning-with-files-ext，请先在其目录执行 bootstrap.sh。" >&2
