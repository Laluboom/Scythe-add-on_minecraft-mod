#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

rm -f scythe_addon.mcaddon
python3 -m zipfile -c scythe_addon.mcaddon behavior_pack resource_pack

echo "Built scythe_addon.mcaddon"
