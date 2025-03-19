#!/bin/sh
echo "Starting battery-level.sh script..."
export DISPLAY=:0

battery_info=$(acpi -b)
battery_percentage=$(echo "$battery_info" | grep -o '[0-9]*%' | tr -d '%')
charging_status=$(echo "$battery_info" | grep -o 'Charging')

if [ -n "$charging_status" ]; then
    echo "Battery is charging. No notifications will be sent."
else
    if [ "$battery_percentage" -lt 10 ]; then
        notify-send "Battery Critical" "Battery is at ${battery_percentage}%. Please charge immediately!"
    elif [ "$battery_percentage" -lt 20 ]; then
        notify-send "Battery Low" "Battery is at ${battery_percentage}%. Consider charging soon."
    elif [ "$battery_percentage" -lt 50 ]; then
        notify-send "Battery Warning" "Battery is at ${battery_percentage}%. You might want to charge."
    fi
fi

echo "Ending battery-level.sh script."
