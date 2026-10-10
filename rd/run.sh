#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cmake -S "$script_dir" -B "$script_dir/build"
cmake --build "$script_dir/build" --target rd2D --parallel
if [[ "${1:-}" == "--build-only" ]]; then
    exit 0
fi
cd "$script_dir"
mkdir -p output
exec "$script_dir/build/rd2D" "$@"
