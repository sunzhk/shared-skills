#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skills_root="$(cd "${script_dir}/../.." && pwd)"

exec bash "${skills_root}/scripts/init-shared-skill.sh" eng-practices "$@"
