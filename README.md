# Dotfiles

Personal configuration files, managed with GNU Stow.

## Quick Start

Clone the repository:

```bash
git clone https://github.com/EmilPopovic/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Install GNU Stow:

```bash
sudo pacman -S stow
```

Link all dotfiles to your home directory:

```bash
cd ~/.dotfiles
stow .
```

Stow creates symlinks from `~/.dotfiles` to your home directory, treating `.dotfiles` as `~`.

## Adding New Dotfiles

To add a new dotfile to the repository:

### 1. Move the file to `.dotfiles` with its relative structure

Move `~/.zshrc` to `~/.dotfiles/.zshrc`

```bash
mv ~/.zshrc ~/.dotfiles/.zshrc
```

Move entire directories

```bash
mkdir -p ~/.dotfiles/.config/nvim
mv ~/.config/nvim/* ~/.dotfiles/nvim/
```

### 2. Create the symlink

```bash
cd ~/.dotfiles
stow .
```

Stow automatically creates symlinks for all files in `.dotfiles`, mirroring their directory structure back to your home directory.

### 3. Commit to git

```bash
git add .
git commit -m "Add bashrc and nvim config"
git push
```

## Removing Dotfiles

To remove all symlinks without deleting files:

```bash
cd ~/.dotfiles
stow -D .
```

Reapply symlinks:

```bash
stow .
```
