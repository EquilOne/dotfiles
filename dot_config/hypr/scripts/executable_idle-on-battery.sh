#!/bin/bash
# Run a hypridle timeout action only when on battery.
# Usage: idle-on-battery.sh <command...>
if [ "$(cat /sys/class/power_supply/rk817-charger/online 2>/dev/null)" = "1" ]; then
    exit 0
fi
exec "$@"
