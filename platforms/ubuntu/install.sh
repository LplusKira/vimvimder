#!/bin/bash
set -euo pipefail

# Check local vimrc's download
function replace_vimrc() {
  local repo_vimrc="../../cfg/vimrc"
  local local_vimrc="$HOME/.vimrc"
  if [ -f "$local_vimrc" ]; then
    mv $local_vimrc "$local_vimrc.bak"
  fi
  cp $repo_vimrc $local_vimrc
}

# Check if vim supports python
function vim_supports_python() {
  # ref: https://www.feliciano.tech/blog/how-to-check-if-vim-supports-python/
  local res=`vim --version | grep "+python"`
  echo $res # E.g. "+conceal +linebreak +python3 +visualextra"
}

# Install YouCompleteMe
function install_YCM() {
  # Ref: https://github.com/ycm-core/YouCompleteMe
  # Note: there's A LOT of places that might fail you here

  # Dependencies
  apt install -y build-essential cmake vim-nox python3-dev
  apt install -y mono-complete golang nodejs default-jdk npm

  # Compile YCM (YouCompleteMe)
  ## If having cert error, check https://github.com/LplusKira/vimvimder/issues/1
  cd ~/.vim/bundle/YouCompleteMe
  python3 install.py --all
  cd -
}

# Install tidy
function install_tidy() {
  ### Ref: https://github.com/htacg/tidy-html5/blob/next/README/BUILD.md
  git clone https://github.com/htacg/tidy-html5.git
  cd tidy-html5/build/cmake
  cmake ../.. -DCMAKE_BUILD_TYPE=Release
  make
  make install
}

# Install flake8
function install_flake8() {
  pip3 install flake8
}

# Complete dependencies
## - Prerequisites git, curl, python3, my .vimrc
apt-get update -y
apt-get install -y git python3 curl cmake
## - Install proper-ver vim
add-apt-repository -y ppa:jonathonf/vim
apt update -y
apt install -y vim
## - Overwrite vimrc
replace_vimrc

# Install plugins through Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# Install specials
## - YCM
install_YCM
## - tidy
install_tidy
## - flake8
install_flake8
