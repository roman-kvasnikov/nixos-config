#!/usr/bin/env bash

URL="$1"

xdg-open "$URL"

sleep 1.0

hyprctl dispatch focuswindow class:brave-browser