# Set caps lock to command, set key repeat to max and key delay to min, fix trackpad speed.
# Install chrome, rectangle, alfred, sublime, flycut, iterm, slack, spotify, messages.
# Update spotlight and alfred hotkeys, 

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
cp Raleway-Light.ttf cp $HOME/Library/Fonts/
brew install thefuck
brew install hub


# Comment out the part that might want to destroy your ssh key...
# printf 'github\n\n' ssh-keygen -t rsa -b 4096 -C "raspat1@gmail.com"
pbcopy < ~/.ssh/id_rsa.pub

