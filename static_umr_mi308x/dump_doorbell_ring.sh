gpu=$1
gpu=${gpu:-0}

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export UMR_DATABASE_PATH=${dir}/database

if [ $gpu -le 1 ]; then
    g=0
else
    g=$((gpu * 8 + 1))
fi

for xcc in {0,1,2,3}; do
    filename="sys_$(date +"%Y-%m-%d_%H_%M")_umr_doorbell_gpu${gpu}_xcc${xcc}.txt"
    echo "Generating $filename"
    ./umr -i "${g}" -vmp "${xcc}" -O bits -r *.*.CP_CPC_STATUS 2>&1 >> "${filename}"
    ./umr -i "${g}" -vmp "${xcc}" -O bits -r *.*.CP_CPC_BUSY_STAT 2>&1 >> "${filename}"
    ./umr -i "${g}" -vmp "${xcc}" -O bits -r *.*.CP_CPC_STALLED_STAT1 2>&1 >> "${filename}"
    ./umr -i "${g}" -vmp "${xcc}" -O bits -r *.*.CP_STAT 2>&1 >> "${filename}"
    ./umr -i "${g}" -vmp "${xcc}" -O bits -r *.*.GRBM_STATUS 2>&1 >> "${filename}"
    ./umr -i "${g}" -vmp "${xcc}" -O bits -r *.*.GRBM_STATUS2 2>&1 >> "${filename}"
    ./umr -i "${g}" -vmp "${xcc}" -O bits -r *.*.CP_MEC1_INSTR_PNTR 2>&1 >> "${filename}"
    ./umr -i "${g}" -vmp "${xcc}" -O bits -r *.*.CP_MEC2_INSTR_PNTR 2>&1 >> "${filename}"
    for me in {1,2}; do
        for pipe in {0,1,2,3}; do
            for queue in {0,1,2,3}; do
                # echo "g:${g} xcc:${xcc} me:${me} pipe:${pipe} queue:${queue}" 
                echo "g:${g} xcc:${xcc} me:${me} pipe:${pipe} queue:${queue}" >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_HQD_PQ_DOORBELL_CONTROL 2>&1 >> "${filename}"
                echo "g:${g} xcc:${xcc} me:${me} pipe:${pipe} queue:${queue} VMID" >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_HQD_VMID 2>&1 >> "${filename}"
                echo "g:${g} xcc:${xcc} me:${me} pipe:${pipe} queue:${queue} READ/WRITE" >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_HQD_PQ_RPTR 2>&1 >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_HQD_PQ_WPTR_LO 2>&1 >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_HQD_PQ_WPTR_HI 2>&1 >> "${filename}"
                echo "g:${g} xcc:${xcc} me:${me} pipe:${pipe} queue:${queue} ADDR" >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_MQD_BASE_ADDR 2>&1 >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_MQD_BASE_ADDR_HI 2>&1 >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_HQD_PQ_BASE 2>&1 >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_HQD_PQ_BASE_HI 2>&1 >> "${filename}"
                echo "g:${g} xcc:${xcc} me:${me} pipe:${pipe} queue:${queue} ACTIVE" >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_HQD_ACTIVE 2>&1 >> "${filename}"
            done
        done
    done
done