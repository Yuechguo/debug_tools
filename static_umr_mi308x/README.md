# Usage
The compiled UMR tool is linked to local .so libraries and can be used directly in the Ali environment without installation.

# Operating Procedure

check the pci-instance used by gpu device:
```
$ rocm-smi --showbus
============================ ROCm System Management Interface ============================
======================================= PCI Bus ID =======================================
GPU[0]          : PCI Bus: 0000:0A:00.0
GPU[1]          : PCI Bus: 0000:0A:00.1
GPU[2]          : PCI Bus: 0000:0A:00.2
GPU[3]          : PCI Bus: 0000:0A:00.3
GPU[4]          : PCI Bus: 0000:80:00.0
GPU[5]          : PCI Bus: 0000:80:00.1
GPU[6]          : PCI Bus: 0000:80:00.2
GPU[7]          : PCI Bus: 0000:80:00.3
GPU[8]          : PCI Bus: 0000:A4:00.0
GPU[9]          : PCI Bus: 0000:A4:00.1
GPU[10]         : PCI Bus: 0000:A4:00.2
GPU[11]         : PCI Bus: 0000:A4:00.3
GPU[12]         : PCI Bus: 0000:C8:00.0
GPU[13]         : PCI Bus: 0000:C8:00.1
GPU[14]         : PCI Bus: 0000:C8:00.2
GPU[15]         : PCI Bus: 0000:C8:00.3
GPU[16]         : PCI Bus: 0001:0B:00.0
GPU[17]         : PCI Bus: 0001:0B:00.1
GPU[18]         : PCI Bus: 0001:0B:00.2
GPU[19]         : PCI Bus: 0001:0B:00.3
GPU[20]         : PCI Bus: 0001:81:00.0
GPU[21]         : PCI Bus: 0001:81:00.1
GPU[22]         : PCI Bus: 0001:81:00.2
GPU[23]         : PCI Bus: 0001:81:00.3
GPU[24]         : PCI Bus: 0001:A5:00.0
GPU[25]         : PCI Bus: 0001:A5:00.1
GPU[26]         : PCI Bus: 0001:A5:00.2
GPU[27]         : PCI Bus: 0001:A5:00.3
GPU[28]         : PCI Bus: 0001:C9:00.0
GPU[29]         : PCI Bus: 0001:C9:00.1
GPU[30]         : PCI Bus: 0001:C9:00.2
GPU[31]         : PCI Bus: 0001:C9:00.3
==========================================================================================
================================== End of ROCm SMI Log ===================================
```
database setup
If you're using umr into the host in first time, remember to export "export UMR_DATABASE_PATH=$PWD/database". that will able to help you to resolve the pci-util related problems.
PWD folder should be under static_umr_mi308x, db file is included in this folder. Only dump_all_cpc_info.sh has this setup.
```
export UMR_DATABASE_PATH=$PWD/database
```

check the correspondence between pci-instances and umr-gpu-instance:
```
$ ./umr --script instances
41 25 17 0 57 9 49 33

$ ./umr --script pci-bus 0
0000:0a:00.0

$ ./umr --script pci-bus 17
0000:a4:00.0
```

correspondence between physical GPU IDs and UMR GPU instances:
```
0 -> 0 (in ali machine this could be 1)
1 -> 9
2 -> 17
3 -> 25
4 -> 33
5 -> 41
6 -> 49
7 -> 57
```

modify the all the bash script to make sure the correspondence between physical GPU IDs and UMR GPU instances is right:
```
if [ $gpu -le 1 ]; then
    g=0
else
    g=$((gpu * 8 + 1))
fi
0 -> 0 
1 -> 9
2 -> 17
3 -> 25
4 -> 33
5 -> 41
6 -> 49
7 -> 57

or 
g=$((gpu * 8 + 1))
0 -> 1
1 -> 9
2 -> 17
3 -> 25
4 -> 33
5 -> 41
6 -> 49
7 -> 57
```

get umr info by physical gpu id:
```
sudo bash dump_all_cpc_info.sh {physical_gpu_id}
```
