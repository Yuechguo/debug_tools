#!/usr/bin/bash
prefix="sys_$(date +"%Y-%m-%d_%H_%M")"
kfddbg="/sys/kernel/debug/kfd"
sudo cat "${kfddbg}/rls" 2>&1 >"${prefix}_rls_1.txt"
sudo cat "${kfddbg}/mqds" 2>&1 >"${prefix}_mqds_1.txt"
sleep 2
sudo cat "${kfddbg}/rls" 2>&1  >"${prefix}_rls_2.txt"
sudo cat "${kfddbg}/mqds" 2>&1 >"${prefix}_mqds_2.txt"