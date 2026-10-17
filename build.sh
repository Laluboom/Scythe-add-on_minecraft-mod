#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

rm -f scythe_addon.mcaddon
zip -r scythe_addon.mcaddon behavior_pack resource_pack -x '*.DS_Store'

echo "Built scythe_addon.mcaddon"
