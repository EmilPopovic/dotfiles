#!/bin/bash
# Listens for Hyprland monitor events and triggers auto-scaling

SCRIPT_DIR="$(dirname "$0")"

# Listen to Hyprland socket for monitor events
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    # Event format: monitoradded>>MONITOR_NAME
    if [[ "$line" == monitoradded* ]]; then
        monitor="${line#monitoradded>>}"
        echo "Monitor added: $monitor"
        # Small delay to let the monitor fully initialize
        sleep 0.5
        "$SCRIPT_DIR/auto-scale.sh" "$monitor"
    fi
done
