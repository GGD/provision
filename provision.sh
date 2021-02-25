#!/bin/sh

which -s brew
if [[ $? != 0 ]] ; then
  echo "Installing Homebrew ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

echo "Updating Homebrew formula ..."
brew tap homebrew/cask
brew tap homebrew/cask-versions
brew tap homebrew/bundle
cd ~/.dotfiles; brew bundle

if [ ! -d "$HOME/.config/" ]; then
  mkdir "$HOME/.config"
fi

if [ ! -d "$HOME/.config/nvim/" ]; then
  mkdir "$HOME/.config/nvim"
fi

if [ ! -d "$HOME/.config/yarn/global" ]; then
  mkdir -p "$HOME/.config/yarn/global"
fi

echo "Install Zinit"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

ln -sf ~/.dotfiles/p10k.zsh ~/.p10k.zsh
ln -sf ~/.dotfiles/nvimrc ~/.config/nvim/init.vim
ln -sf ~/.dotfiles/ctags ~/.ctags
ln -sf ~/.dotfiles/fzf.zsh ~/.fzf.zsh
ln -sf ~/.dotfiles/gemrc ~/.gemrc
ln -sf ~/.dotfiles/gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/git_template ~/.git_template
ln -sf ~/.dotfiles/irbrc ~/.irbrc
ln -sf ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -sf ~/.dotfiles/zshrc ~/.zshrc
ln -sf ~/.dotfiles/package.json ~/.config/yarn/global/package.json

which -s nvm
if [[ $? != 0 ]] ; then
  echo "Installing nvm via zsh-nvm ..."
  git clone https://github.com/lukechilds/zsh-nvm.git ~/.zsh-nvm
fi


source ~/.zshrc

if [ ! -d "$HOME/.local/share/nvim/site/autoload/" ]; then
  mkdir "$HOME/.local/share/nvim/site/autoload"
fi

if [ ! -d "$HOME/.local/share/nvim/site/autoload/" ]; then
  mkdir -p "$HOME/.local/share/nvim/site/autoload"
fi

if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
  curl https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -o ~/.local/share/nvim/site/autoload/plug.vim
fi
nvim --headless -c PlugInstall -c qa

if [ ! -d "$HOME/.local/config/nvim/" ]; then
  mkdir -p "$HOME/.local/config/nvim"
fi

echo "Installing Tmux Plugin Manager..."
if [ ! -d "$HOME/.tmux/plugins/" ]; then
  mkdir -p "$HOME/.tmux/plugins"
fi

if [ ! -d "$HOME/.tmux/plugins/" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
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
gem_install_or_update "tmuxinator"
