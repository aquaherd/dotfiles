#!/bin/sh
git fetch --prune-tags --tags --force
git clean -dxf
git checkout ${1-stable} 
make CMAKE_BUILD_TYPE=RelWithDebInfo
ninja -C build package
cp -v ./build/nvim*.deb ~/Downloads/nvim-$(git describe)-$(uname -m).deb
sudo apt-get install ~/Downloads/nvim-$(git describe)-$(uname -m).deb

