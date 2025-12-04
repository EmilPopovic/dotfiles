#!/bin/bash
# Toggle between extending and mirroring external displays

STATE_FILE="/tmp/hypr-mirror-state"
PRIMARY="eDP-1"

# Get list of external monitors (not eDP-1) - use "all" to include mirrored displays
external_monitors=$(hyprctl monitors all -j | jq -r ".[] | select(.name != \"$PRIMARY\") | .name")

if [[ -z "$external_monitors" ]]; then
    notify-send "Display" "No external monitors connected"
    exit 0
fi

# Check current state
if [[ -f "$STATE_FILE" ]] && [[ "$(cat "$STATE_FILE")" == "mirrored" ]]; then
    # Currently mirrored -> switch to extend
    # First disable the monitor to clear mirror state
    for mon in $external_monitors; do
        hyprctl keyword monitor "$mon,disable"
    done
    sleep 0.3
    # Re-enable with extend settings
    for mon in $external_monitors; do
        hyprctl keyword monitor "$mon,preferred,auto-left,auto"
    done
    sleep 0.3
    # Run auto-scale for proper scaling
    ~/.config/hypr/scripts/auto-scale.sh
    # Refresh wallpaper (restart swaybg)
    pkill swaybg
    swaybg -i ~/.config/omarchy/current/background -m fill &
    disown
    echo "extended" > "$STATE_FILE"
    notify-send "Display" "Extended mode"
else
    # Currently extended -> switch to mirror
    for mon in $external_monitors; do
        hyprctl keyword monitor "$mon,preferred,auto,1,mirror,$PRIMARY"
    done
    echo "mirrored" > "$STATE_FILE"
    notify-send "Display" "Mirror mode"
fi
