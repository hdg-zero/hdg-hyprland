#!/usr/bin/env sh

set -eu

if ! command -v acpi >/dev/null 2>&1 || ! command -v notify-send >/dev/null 2>&1; then
    exit 0
fi

battery_info=$(acpi -b 2>/dev/null | head -n 1 || true)
battery_percentage=$(printf '%s\n' "$battery_info" | grep -o '[0-9]\+%' | head -n 1 | tr -d '%' || true)

if [ -z "$battery_percentage" ] || printf '%s\n' "$battery_info" | grep -Eq 'Charging|Full'; then
    exit 0
fi

if [ "$battery_percentage" -lt 10 ]; then
    notify-send -u critical -a "Battery" "Batterie critique" "Batterie à ${battery_percentage} %. Branche le chargeur."
elif [ "$battery_percentage" -lt 20 ]; then
    notify-send -u normal -a "Battery" "Batterie faible" "Batterie à ${battery_percentage} %. Charge recommandée."
fi