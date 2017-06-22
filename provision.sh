#!/bin/sh

which -s brew
if [[ $? != 0 ]] ; then
  echo "Installing Homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Homebrew already installed, updating..."
  brew update
fi

which -s git
if [[ $? != 0 ]] ; then
  echo "Installing Git..."
  brew install git
else
  echo "Git installed, updating..."
  brew upgrade git
fi

which -s ansible
if [[ $? != 0 ]] ; then
  echo "Installing Ansible..."
  brew install ansible
else
  echo "Ansible installed, updating..."
  brew upgrade ansible
fi

git clone git@github.com:GGD/provision ~/.provision
cd ~/.provision
ansible-playbook mac.yml
