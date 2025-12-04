#!/bin/bash
# Smart auto-scaling for Hyprland based on display characteristics
# Triggered on monitor hotplug via hyprland.conf

# Skip known/configured monitors
KNOWN_MONITORS="eDP-1 DP-2"

scale_monitor() {
    local monitor="$1"
    
    # Skip if it's a known monitor
    for known in $KNOWN_MONITORS; do
        [[ "$monitor" == "$known" ]] && return
    done
    
    # Get monitor info
    local info=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\")")
    [[ -z "$info" ]] && return
    
    local width=$(echo "$info" | jq -r '.width')
    local height=$(echo "$info" | jq -r '.height')
    local phys_width=$(echo "$info" | jq -r '.physicalWidth // 0')  # mm
    local phys_height=$(echo "$info" | jq -r '.physicalHeight // 0')
    
    # Calculate diagonal in inches using awk (if physical size available)
    local diag_inches=0
    if [[ "$phys_width" -gt 0 && "$phys_height" -gt 0 ]]; then
        diag_inches=$(awk "BEGIN {printf \"%.1f\", sqrt($phys_width^2 + $phys_height^2) / 25.4}")
    fi
    
    # Determine scale based on heuristics
    local scale=1
    
    # 4K or higher resolution
    if [[ "$width" -ge 3840 ]]; then
        if awk "BEGIN {exit !($diag_inches > 40)}"; then
            # Large display (TV) - viewed from distance
            scale=2
        elif awk "BEGIN {exit !($diag_inches > 30)}"; then
            # Large monitor (32"+)
            scale=1.5
        elif awk "BEGIN {exit !($diag_inches > 0)}"; then
            # Smaller 4K monitor (27" etc)
            scale=1.5
        else
            # Unknown size, assume it needs scaling for 4K
            scale=1.5
        fi
    # 1440p
    elif [[ "$width" -ge 2560 ]]; then
        if awk "BEGIN {exit !($diag_inches > 40)}"; then
            scale=1.5
        else
            scale=1
        fi
    # 1080p or lower - no scaling needed
    else
        scale=1
    fi
    
    echo "Auto-scaling $monitor: ${width}x${height}, ${diag_inches}\" diagonal -> scale $scale"
    
    # Apply the scale
    hyprctl keyword monitor "$monitor,preferred,auto-left,$scale"
}

# If called with a monitor name argument, scale that one
if [[ -n "$1" ]]; then
    scale_monitor "$1"
else
    # Scale all non-known monitors
    hyprctl monitors -j | jq -r '.[].name' | while read -r mon; do
        scale_monitor "$mon"
    done
fi
