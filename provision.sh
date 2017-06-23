#!/bin/sh

which -s brew
if [[ $? != 0 ]] ; then
  echo "Installing Homebrew ..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Homebrew already installed, updating ..."
  brew update
fi

which -s git
if [[ $? != 0 ]] ; then
  echo "Installing Git ..."
  brew install git
else
  echo "Git installed, updating ..."
  brew upgrade git
fi

if [ ! -d "$HOME/.dotfiles/" ]; then
  git clone git@github.com:GGD/dotfiles ~/.dotfiles
fi

ln -s ~/.dotfiles/nvimrc ~/.config/nvim/init.vim
ln -s ~/.dotfiles/ctags ~/.ctags
ln -s ~/.dotfiles/fzf.zsh ~/.fzf.zsh
ln -s ~/.dotfiles/gemrc ~/.gemrc
ln -s ~/.dotfiles/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/git_template ~/.git_template
ln -s ~/.dotfiles/irbrc ~/.irbrc
ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/zshrc ~/.zshrc

echo "Updating Homebrew formula ..."
brew tap caskroom/cask
brew tap caskroom/versions
brew tap homebrew/bundle
cd ~/.dotfiles; brew bundle

if [ ! -d "$HOME/.oh-my-zsh/" ]; then
  git clone git@github.com:robbyrussell/oh-my-zsh ~/.oh-my-zsh
fi

if [ ! -d "$HOME/.config/" ]; then
  mkdir "$HOME/.config"
fi

if [ ! -d "$HOME/.config/nvim/" ]; then
  mkdir "$HOME/.config/nvim"
fi

if [ ! -d "$HOME/.local/share/nvim/site/autoload/" ]; then
  mkdir "$HOME/.local/share/nvim/site/autoload"
fi

if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
  curl https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -o ~/.local/share/nvim/site/autoload/plug.vim
fi
nvim --headless -c PlugInstall -c qa

if [ ! -d "$HOME/.local/config/nvim/" ]; then
  mkdir "$HOME/.local/config/nvim"
fi

if [ ! -d "$HOME/.rbenv/plugins/rbenv-ctags/" ]; then
  git clone git@github.com:tpope/rbenv-ctags ~/.rbenv/plugins/rbenv-ctags
fi

echo "Configuring Ruby ..."
find_latest_ruby() {
  rbenv install -l | grep -v - | tail -1 | sed -e 's/^ *//'
}

ruby_version="$(find_latest_ruby)"
if ! rbenv versions | grep -Fq "$ruby_version"; then
  RUBY_CONFIGURE_OPTS=--with-openssl-dir=/usr/local/opt/openssl rbenv install -s "$ruby_version"
fi
rbenv global "$ruby_version"

gem_install_or_update() {
  if gem list "$1" --installed > /dev/null; then
    gem update "$@"
  else
    gem install "$@"
  fi
}
gem_install_or_update "bundler"
