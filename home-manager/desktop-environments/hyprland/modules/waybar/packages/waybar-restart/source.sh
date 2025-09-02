#!/bin/sh

# Waybar Restart Script

# Check if required commands exist
if ! command -v waybar &> /dev/null; then
    notify-send "Error" "Waybar not found" -u critical

    exit 1
fi

# Restart waybar
if killall waybar 2>/dev/null || killall .waybar-wrapped 2>/dev/null; then
    sleep 1  # Give waybar time to close

    if waybar > /dev/null 2>&1 & then
        sleep 1  # Give waybar time to start

        notify-send "Waybar" "Successfully Restarted" -i window-new
    else
        notify-send "Error" "Failed to restart waybar" -u critical
    fi
fi
