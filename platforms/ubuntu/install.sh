#!/bin/bash
# TODO(po-kai): 'sudo' on proper places
set -exuo pipefail

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
  local password=$1

  # Cmake troubles
  echo $password | sudo -S apt-get purge -y cmake
  local version="3.22.1"
  cwd=`pwd`
  tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
  cd $tmp_dir
  wget https://github.com/Kitware/CMake/releases/download/v$version/cmake-$version.tar.gz
  tar -xzvf cmake-$version.tar.gz
  cd cmake-$version/
  ./bootstrap
  echo $password | sudo -S make
  echo $password | sudo -S make install
  cd $cwd

  # G++8
  echo $password | sudo -S apt-get install -y g++-8
  echo $password | sudo -S update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7
  echo $password | sudo -S update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8

  # Dependencies
  echo $password | sudo -S apt install -y build-essential vim-nox python3-dev
  echo $password | sudo -S apt install -y mono-complete golang nodejs default-jdk npm

  # Compile YCM (YouCompleteMe)
  ## If having cert error, check https://github.com/LplusKira/vimvimder/issues/1
  cd ~/.vim/bundle/YouCompleteMe
  python3 install.py --all
  cd -
}

# Install tidy
function install_tidy() {
  ### Ref: https://github.com/htacg/tidy-html5/blob/next/README/BUILD.md
  cwd=`pwd`
  tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
  cd $tmp_dir
  git clone https://github.com/htacg/tidy-html5.git
  cd tidy-html5/build/cmake
  cmake ../.. -DCMAKE_BUILD_TYPE=Release
  echo $password | sudo -S make
  echo $password | sudo -S make install
  cd $cwd
}

# Install flake8
function install_flake8() {
  pip3 install flake8
}

# Read in pwd
echo "Enter your password: "
read -s password

# Complete dependencies
## - Prerequisites git, curl, python3, my .vimrc
echo $password | sudo -S apt-get update -y
echo $password | sudo -S apt-get install -y git python3 curl cmake
## - Install 8.2-ver vim
echo $password | sudo -S add-apt-repository -y ppa:jonathonf/vim
echo $password | sudo -S apt update -y
echo $password | sudo -S apt install -y vim
## - Change owner
echo $password | sudo -S chown -R $USER "$HOME/.vim*"
## - Overwrite vimrc
replace_vimrc

# Install plugins through Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# Install specials
## - YCM
install_YCM $password
## - tidy
install_tidy
## - flake8
install_flake8
