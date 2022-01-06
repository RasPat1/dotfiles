brew install imagemagick
sudo gem install lolcommits
lolcommits --capture --fork --delay=3

# Let's set up our config as well. No point in taking photos unless we realize our vision.
cp ./lolcommits-config.yml ~/.lolcommits/config.yml
# cp ./lolcommits-config.yml ~/.lolcommits/dotfiles/config.yml

# Copy the parent config if it doesn't exist yet.
# if [ ! -f "$HOME/.lolcommits ..... um
# We can throw this in the post-hook. yikes. what fun hacks.

# Since we initialized lolcommits here we can use the post-commit as a post commit template
# Now all new git repos will include lolcommits. 
cp ./.git/hooks/post-commit ~/.git_template/hooks/post-commit
