#!/bin/bash
# - (Ubuntu 16.04 and later only)
set -e

# Checking dependencies ...
## - Assert prerequisites git, curl, python3, my .vimrc
apt-get update -y
apt-get install -y git python3 curl cmake
#git --version
#python3 --version
#curl --version
#cmake --version
#pip3 --version

remote_vimrc="https://gist.githubusercontent.com/LplusKira/f68437c2b7e4af2b9686043093320f56/raw/a92eb772af2aeb9dac1fcf85911f69b4837093d2/.vimrc"
local_vimrc="$HOME/.vimrc" #"/root/.vimrc" #
curl -o ${local_vimrc} ${remote_vimrc}
if [ ! -f "$local_vimrc" ]; then
    echo "$local_vimrc download fails! Abort"
    exit 1
fi

# Installing ...
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

vim +PluginInstall +qall

## - Specially handle YouCompleteMe -- complie it mannually @@
### Ref: https://github.com/ycm-core/YouCompleteMe#linux-64-bit
apt-get install -y build-essential cmake python3-dev
### vv mono-complete
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
apt-get install -y apt-transport-https ca-certificates
echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | tee /etc/apt/sources.list.d/mono-official-stable.list
apt-get update
apt install mono-devel
### ^^ mono-complete
curl -O https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz
tar -xvf go1.13.3.linux-amd64.tar.gz
mv go /usr/local
for f in ~/.bashrc ~/.zshrc
do
  export GOROOT=/usr/local/go
  export GOPATH=$HOME/go
  export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
  echo "export GOROOT=/usr/local/go" >> $f
  echo "export GOPATH=$HOME/go" >> $f
  echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> $f
done
# vv node, npm
ver=12
apt-get install -y python-software-properties
curl -sL "https://deb.nodesource.com/setup_${ver}.x" | bash -
apt-get install -y nodejs
# ^^ node, npm
# vv clang 9 (default clang is too old)
## Ref: https://justiceboi.github.io/blog/install-clang-9-on-ubuntu/
## Ref: (if using old clang) https://github.com/ycm-core/YouCompleteMe/issues/3236#issuecomment-439987788
curl -SL http://releases.llvm.org/9.0.0/clang%2bllvm-9.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz | tar -xJC .
mv clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-16.04 clang_9.0.0
sudo mv clang_9.0.0 /usr/local
for f in ~/.bashrc ~/.zshrc
do
  export PATH=/usr/local/clang_9.0.0/bin:$PATH
  export LD_LIBRARY_PATH=/usr/local/clang_9.0.0/lib:$LD_LIBRARY_PATH
  echo "PATH=/usr/local/clang_9.0.0/bin:$PATH" >> $f
  echo "LD_LIBRARY_PATH=/usr/local/clang_9.0.0/lib:$LD_LIBRARY_PATH" >> $f
done
# ^^ clang 9 (default clang is too old)
# Do not use `python3 install.py --all` # this uses some battery-included clang compiler which does not work
## Ref: https://github.com/ycm-core/YouCompleteMe/issues/1711#issuecomment-329520570
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer --system-libclang


## - Specially install tidy
### Ref: https://github.com/htacg/tidy-html5/blob/next/README/BUILD.md
git clone https://github.com/htacg/tidy-html5.git
cd tidy-html5/build/cmake
cmake ../.. -DCMAKE_BUILD_TYPE=Release
make
make install

## - Specially install flake8 (python linting)
pip3 install flake8
