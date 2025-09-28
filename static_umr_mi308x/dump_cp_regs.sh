#!/usr/bin/bash
gpu=$1
gpu=${gpu:-0}
if [ $gpu -le 1 ]; then
    g=0
else
    g=$((gpu * 8 + 1))
fi

for xcc in {0,1,2,3}; do
	filename="sys_$(date +"%Y-%m-%d_%H_%M")_umr_cp_regs_gpu${gpu}_xcc${xcc}.txt"
	echo "Generating $filename"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCPC_UTCL1_STATUS" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCPF_UTCL1_STATUS" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCPG_UTCL1_STATUS" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_INT_STAT_DEBUG" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_ME1_INT_STAT_DEBUG" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_ME2_INT_STAT_DEBUG" 2>&1 >>"${filename}"

	echo "PQ fetcher" 1>>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -w "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_CNTL" 0 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR_ADDR" 2>&1 >>"${filename}"

	echo "IB fetcher" 1>>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -w "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_CNTL" 1 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR_ADDR" 2>&1 >>"${filename}"

	echo "EOP fetcher" 1>>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -w "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_CNTL" 2 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR_ADDR" 2>&1 >>"${filename}"

	echo "EQ fetcher" 1>>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -w "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_CNTL" 3 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR_ADDR" 2>&1 >>"${filename}"

	echo "PQ RPTR report fetcher utcl1" 1>>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -w "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_CNTL" 4 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR_ADDR" 2>&1 >>"${filename}"

	echo "PQ WPTR poll fetcher utcl1" 1>>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -w "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_CNTL" 5 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR" 2>&1 >>"${filename}"
	./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regCP_HPD_UTCL1_ERROR_ADDR" 2>&1 >>"${filename}"

	for count in {0..7}; do
		./umr -i "${g}" -vmp "${xcc}" -r "aqua_vanjaram.gfx944{${xcc}}.regSPI_CSQ_WF_ACTIVE_COUNT_${count}" 2>&1 >>"${filename}"
	done

done
