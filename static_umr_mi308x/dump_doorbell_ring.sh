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
    for me in {1,2}; do
        for pipe in {0,1,2,3}; do
            for queue in {0,1,2,3}; do
                echo "g:${g} xcc:${xcc} me:${me} pipe:${pipe} queue:${queue}" 
                echo "g:${g} xcc:${xcc} me:${me} pipe:${pipe} queue:${queue}" >> "${filename}"
                ./umr -i "${g}" -vmp "${xcc}" -sb "${me}" "${pipe}" "${queue}" -O bits -r *.*.CP_HQD_PQ_DOORBELL_CONTROL 2>&1 >> "${filename}"
            done
        done
    done
done