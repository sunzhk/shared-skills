#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runner="$script_dir/openspec-cn-run.sh"
bin_dir="${OPEN_SPEC_CN_BIN_DIR:-$HOME/.local/bin}"

mkdir -p "$bin_dir"

# 按 openspec 顶层命令生成 -cn 包装
commands=(
  init
  update
  list
  view
  change
  archive
  spec
  config
  schema
  validate
  show
  feedback
  completion
  status
  instructions
  templates
  schemas
  new
)

for cmd in "${commands[@]}"; do
  wrapper="$bin_dir/openspec-${cmd}-cn"
  cat > "$wrapper" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec "$runner" "$cmd" "\$@"
EOF
  chmod +x "$wrapper"
done

echo "[open-spec-cn] installed wrappers to: $bin_dir"
echo "[open-spec-cn] examples:"
echo "  openspec-new-cn change \"my-change\""
echo "  openspec-instructions-cn proposal --change \"my-change\" --json"
echo "  openspec-archive-cn \"my-change\""
