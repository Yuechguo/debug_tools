#!/usr/bin/bash

gpu=$1
gpu=${gpu:-0}
if [ $gpu -le 1 ]; then
    g=0
else
    g=$((gpu * 8 + 1))
fi

for xcc in {0,1,2,3}; do
	filename="sys_$(date +"%Y-%m-%d_%H_%M")_umr_waves_gpu${gpu}_xcc${xcc}.txt"
	echo "Generating $filename"
	./umr -i "${g}" -vmp "${xcc}" -O bits,halt_waves -wa none 2>&1 >"${filename}"
done
