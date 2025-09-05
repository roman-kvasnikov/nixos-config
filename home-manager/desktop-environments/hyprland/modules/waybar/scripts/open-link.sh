#!/usr/bin/env bash

URL="$1"

xdg-open "$URL"

sleep 1.0

BROWSER_WORKSPACE=$(hyprctl clients -j | jq -r '.[] | select(.class == "brave-browser") | .workspace.id' | head -1)

if [ ! -z "$BROWSER_WORKSPACE" ]; then
  hyprctl dispatch workspace "$BROWSER_WORKSPACE"
fi