#!/usr/bin/bash -e
set -x

install_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 修正點：加入 libstdc++-static，並移除找不到的 ncurses-static
sudo yum install -y gcc gcc-c++ make libpciaccess-devel ncurses-devel cmake git glibc-static libstdc++-static

# 檢查 umr 目錄是否存在，避免重複 clone
if [ ! -d "umr" ]; then
  git clone --depth=1 https://gitlab.freedesktop.org/tomstdenis/umr.git
fi

cd "${install_dir}/umr" || exit
mkdir -p build && cd build || exit
rm -rf ../build/*

# 使用 -static 旗標進行靜態編譯
cmake \
    -DUMR_NO_GUI=on \
    -DUMR_NO_DRM=ON \
    -DUMR_NO_LLVM=ON \
    -DUMR_NO_SERVER=ON \
    -DCMAKE_EXE_LINKER_FLAGS="-static" \
    ..

make -j umr
sudo make install
sudo chmod +s "$(which umr)"

echo "✅ UMR successfully installed as a static binary!"

# 驗證是否為靜態連結檔案
echo "🔍  Verifying binary type:"
file "$(which umr)"

cd ../../
