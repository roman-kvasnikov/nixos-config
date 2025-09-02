#!/bin/sh

# Waybar Restart Script with status check

# Check if required commands exist
if ! command -v waybar &> /dev/null; then
    notify-send "Error" "Waybar not found" -u critical

    exit 1
fi

# Function to check if waybar is running
is_waybar_running() {
    pgrep -x "waybar" > /dev/null 2>&1 || pgrep -x ".waybar-wrapped" > /dev/null 2>&1
}

# Function to start waybar
start_waybar() {
    echo "Starting waybar..."
    if waybar > /dev/null 2>&1 & then
        sleep 1
        notify-send "Waybar" "Started" -i window-new

        return 0
    else
        notify-send "Error" "Failed to start waybar" -u critical

        return 1
    fi
}

# Function to restart waybar
restart_waybar() {
    echo "Stopping waybar..."
    if killall waybar 2>/dev/null || killall .waybar-wrapped 2>/dev/null; then
        sleep 1
        echo "Starting waybar..."
        if waybar > /dev/null 2>&1 & then
            sleep 1
            notify-send "Waybar" "Successfully Restarted" -i window-new

            return 0
        else
            notify-send "Error" "Failed to restart waybar" -u critical

            return 1
        fi
    else
        notify-send "Error" "Failed to kill waybar" -u critical

        return 1
    fi
}

# Main logic
echo "Checking waybar status..."

if is_waybar_running; then
    echo "Waybar is running, restarting..."

    restart_waybar
else
    echo "Waybar is not running, starting..."

    start_waybar
fi