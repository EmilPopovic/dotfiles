# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

source /opt/Xilinx/Vivado/2022.2/settings64.sh

alias py='python3'
export _JAVA_AWT_WM_NONREPARENTING=1

export TERM=xterm-kitty

[[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh"

