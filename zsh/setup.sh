#!/usr/bin/env bash

# Check whether zsh is installed or not
command -v zsh > /dev/null || {
    echo "Please install zsh yourself before running this script!"
    exit 1
}

# Install oh-my-zsh in unattended mode - no prompts to change shell, or open a zsh prompt after it completes
echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Clone in powerlevel10k
git clone https://github.com/romkatv/powerlevel10k.git "$HOME"/.oh-my-zsh/custom/themes/powerlevel10k

# Change oh-my-zsh theme to powerlevel10k
echo "Changing default powerlevel10k theme from 'robbyrussell' to 'powerlevel10k/powerlevel10k'"
sed -i -e 's|ZSH_THEME="robbyrussell"|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME"/.zshrc

# Copy p10k config
echo "Copying powerlevel10k configuration"
cp -v "$(dirname "$0")"/.p10k.zsh "$HOME"/

# Ensure p10k config is included
echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> "$HOME/.zshrc"

# Warn user about fonts
echo "Please ensure the recommended fonts from https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k are installed, and your terminal is using 'MesloLGS NF'"
