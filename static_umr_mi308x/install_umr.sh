#!/usr/bin/bash -e
set -x
install_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#sudo apt install build-essential libpciaccess-dev libncurses-dev cmake -y
yum install -y gcc gcc-c++ make libpciaccess-devel           ncurses-devel            cmake
#rm -rf ./umr
git clone --depth=1 https://gitlab.freedesktop.org/tomstdenis/umr.git
cd "${install_dir}/umr" || exit
mkdir -p build && cd build || exit
rm -rf ../build/*
cmake -DUMR_NO_GUI=on -DUMR_NO_DRM=ON -DUMR_NO_LLVM=ON -DUMR_NO_SERVER=ON   ..
make -j umr
sudo make install
sudo chmod +s "$(which umr)"
echo "UMR successfully installed"
cd ../../
