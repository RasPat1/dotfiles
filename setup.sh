# Set caps lock to command, set key repeat to max and key delay to min, fix trackpad speed.
# Install chrome, rectangle, raycast, sublime, flycut, iterm, slack, spotify, messages.
# Update spotlight and raycast hotkeys,

ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mkdir ../cli-utils
git clone https://github.com/rupa/z ../cli-utils
git clone https://github.com/olivierverdier/zsh-git-prompt ../cli-utils
cp zsh_prof ~/.zsh_prof
echo "source ~/.zsh_prof" >> ~/.zshrc
cp gitconfig ~/.gitconfig
cp gitignore_global ~/.gitignore_global
mkdir -p ~/.git_template/hooks
cp Raleway-Light.ttf $HOME/Library/Fonts/
brew install thefuck
brew install gh   # GitHub CLI (replaces the now-deprecated `hub`)

# tmux profile + the reflection-* status scripts it shells out to
cp tmux.conf ~/.tmux.conf
mkdir -p ~/.tmux
cp tmux/reflection-*.sh ~/.tmux/
chmod +x ~/.tmux/reflection-*.sh

# Claude Code status line (referenced from ~/.claude/settings.json)
mkdir -p ~/.claude
cp claude/statusline-command.sh ~/.claude/statusline-command.sh

# Codex CLI status line (merge only the [tui] block; keep machine-local Codex state)
codex/install-config.sh


# SSH key for GitHub. Only generate one if it doesn't already exist, so re-running
# this script can NEVER clobber an existing key. ed25519 is the modern default
# (the old `ssh-keygen -t rsa` line could silently overwrite ~/.ssh/id_rsa).
if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -C "raspat1@gmail.com" -f ~/.ssh/id_ed25519
fi
pbcopy < ~/.ssh/id_ed25519.pub
echo "Public SSH key copied to clipboard — add it at https://github.com/settings/keys"

