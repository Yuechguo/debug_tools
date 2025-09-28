#!/usr/bin/bash

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
gpu=$1
gpu=${gpu:-0}
if [ $gpu -le 1 ]; then
    g=0
else
    g=$((gpu * 8 + 1))
fi

for xcc in {0,1,2,3}; do
	filename="sys_$(date +"%Y-%m-%d_%H_%M")_cpc_scratch_gpu${gpu}_xcc${xcc}.bin"
	echo "Generating $filename"
	sudo "${dir}"/cpc_scratch -p "${gpu}" -x "${xcc}" -o "${filename}" 2>>"${filename}"
done
