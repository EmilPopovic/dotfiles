# Zsh configuration migrated from Omarchy bash

# =============================================================================
# History
# =============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=32768
SAVEHIST=32768
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY

# =============================================================================
# Environment
# =============================================================================
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi
export TERM=xterm-kitty
export _JAVA_AWT_WM_NONREPARENTING=1
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Xilinx
source /opt/Xilinx/Vivado/2022.2/settings64.sh

# =============================================================================
# SSH with kitty fix
# =============================================================================
[[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh"

# =============================================================================
# Completion
# =============================================================================
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

# Case-insensitive completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' '1:|=* r:|=*'

# =============================================================================
# Key Bindings
# =============================================================================
bindkey "^P" history-search-backward
bindkey "^N" history-search-forward
bindkey -e

# Ctrl+Arrow for word navigation
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# =============================================================================
# Initialization - Tools
# =============================================================================

# mise (environment manager)
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# starship (prompt)
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# zoxide (cd replacement)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# fzf (fuzzy finder)
if command -v fzf &> /dev/null; then
  if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
  fi
  if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
  fi
fi

# =============================================================================
# Aliases - File System
# =============================================================================
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

alias ff="fzf --preview 'bat --style=nuumbers --color=always {}'"

# Directory navigation (zoxide handles `cd` via zd function below)
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# =============================================================================
# Aliases - Tools
# =============================================================================
alias d='docker'
alias py='python3'
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# =============================================================================
# Functions - Core
# =============================================================================

# Neovim
n() {
  if [ "$#" -eq 0 ]; then
    nvim .
  else
    nvim "$@"
  fi
}

# zoxide cd override with fallback
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}

alias cd="zd"

# xdg-open (background)
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# =============================================================================
# Function - Compression
# =============================================================================

compress() {
  tar -czf "${1%/}.tar.gz" "${1%/}"
}

alias decompress="tar -xzf"

# =============================================================================
# Functions - Storage & Disks
# =============================================================================

# Write ISO to SD card
iso2sd() {
  if [ $# -ne 2 ]; then
    echo "Usage: iso2sd <input_file> <output_device>"
    echo "Example: iso2sd ~/Downloads/ubuntu-25.04-dekstop-amd64.iso /dev/sda"
    echo -e "\nAvailable SD cards:"
    lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
  else
    sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
    sudo eject "$2"
  fi
}

# Format drive with ext4
format-drive() {
  if [ $# -ne 2 ]; then
    echo "Usage: format-drive <device> <name>"
    echo "Example: format-drive /dev/sda 'My Stuff'"
    echo -e "\nAvailable drives:"
    lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
  else
    echo "WARNING: This will completely erase all data on $1 and label it '$2'."
    read -r "confirm?Are you sure? (y/N): "
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      sudo wipefs -a "$1"
      sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
      sudo parted -s "$1" mklabel gpt
      sudo parted -s "$1" mkpart primary ext4 1MiB 100%
      sudo mkfs.ext4 -L "$2" "$([[ $1 == *"nvme"* ]] && echo "${1}p1" || echo "${1}1")"
      sudo chmod -R 777 "/run/media/$USER/$2"
      echo "Drive $1 formatted and labeled '$2'."
    fi
  fi
}

# =============================================================================
# Functions - Video Transcoding
# =============================================================================

transcode-video-1080p() {
  ffmpeg -i "$1" -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy "${1%.*}-1080p.mp4"
}

transcode-video-4K() {
  ffmpeg -i "$1" -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k "${1%.*}-optimized.mp4"
}

# =============================================================================
# Functions - Image Transcoding
# =============================================================================

img2jpg() {
  magick "$1" -quality 95 -strip "{1%.*}.jpg"
}

img2jpg-small() {
  magick "$1" -resize 1080x\> -quality 95 -strip "${1%.*}.jpg"
}

# =============================================================================
# Additional Zsh Options
# =============================================================================
setopt EXTENDED_GLOB
setopt NO_NOMATCH
setopt APPEND_HISTORY
setopt INTERACTIVE_COMMENTS

