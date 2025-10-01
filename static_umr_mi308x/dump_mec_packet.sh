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
    filename="sys_$(date +"%Y-%m-%d_%H_%M")_umr_mec_packet_gpu${gpu}_xcc${xcc}.txt"
    echo "Generating $filename"
    for pipe in {0,1,2,3}; do
        for queue in {0,1,2,3}; do
            echo "g:${g} xcc:${xcc} pipe:${pipe} queue:${queue} MEC1 PACKET" >> "${filename}"
            for header in {0,1,2,3,4,5,6,7}; do
                ./umr -i "${g}" -vmp "${xcc}" -sb 1 "${pipe}" "${queue}" -O bits -r *.*.CP_MEC_ME1_HEADER_DUMP 2>&1 >> "${filename}"
            done
            echo "g:${g} xcc:${xcc} pipe:${pipe} queue:${queue} MEC2 PACKET" >> "${filename}"
            for header in {0,1,2,3,4,5,6,7}; do
                ./umr -i "${g}" -vmp "${xcc}" -sb 2 "${pipe}" "${queue}" -O bits -r *.*.CP_MEC_ME2_HEADER_DUMP 2>&1 >> "${filename}"
            done
        done
    done
done