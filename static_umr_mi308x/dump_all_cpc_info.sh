#!/usr/bin/bash

g=$1
g=${g:-0}

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo chmod +x "${dir}"/dump_cpc.sh
sudo chmod +x "${dir}"/dump_waves.sh
sudo chmod +x "${dir}"/dump_cp_regs.sh
sudo chmod +x "${dir}"/collect_kfd_debug_info.sh
sudo chmod +x "${dir}"/dump_cpc_scratch_mems.sh
export UMR_DATABASE_PATH=${dir}/database

#which umr >/dev/null 2>&1
#if [ "$?" -eq 0 ]; then
#	echo "UMR found"
#else
#	echo "Installing UMR"
#	sudo "${dir}"/install_umr.sh
#fi
"${dir}"/dump_cpc.sh ${g}
"${dir}"/dump_waves.sh ${g}
"${dir}"/collect_kfd_debug_info.sh
"${dir}"/dump_cpc_scratch_mems.sh ${g}
"${dir}"/dump_cp_regs.sh ${g}
