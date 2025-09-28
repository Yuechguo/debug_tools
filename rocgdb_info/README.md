## Use rocgdb to save info
modify the `<hang_pid>` in `save_info.gdb` and run command:
```
Command: sudo rocgdb -x script.gdb 2>&1 | tee hang_gdb.log
```

## Use queue_script to collect data
rocgdb attach the <hang_pid> and enable script:
```
sudo rocgdb attach <hang_pid>
source queue_script.py
```

get queue info and dump queue packet and signal info(in rocgdb):
```
(gdb) info queue
  Id   Target Id                  Type         Read   Write  Size     Address            
  1    AMDGPU Queue 4:1 (QID 27)  DMA                        1048576  0x00007e4b57600000 
  2    AMDGPU Queue 4:2 (QID 26)  DMA                        1048576  0x00007e4b57800000 
  3    AMDGPU Queue 3:3 (QID 25)  DMA                        1048576  0x00007e4b58200000 
  4    AMDGPU Queue 3:4 (QID 24)  DMA                        1048576  0x00007e4b58400000 
  5    AMDGPU Queue 2:5 (QID 23)  DMA                        1048576  0x00007e4b58e00000 
  6    AMDGPU Queue 2:6 (QID 22)  DMA                        1048576  0x00007e4b59000000 
  7    AMDGPU Queue 1:7 (QID 21)  DMA                        1048576  0x00007e4b59a00000 
  8    AMDGPU Queue 1:8 (QID 20)  DMA                        1048576  0x00007e4b5c400000 
  9    AMDGPU Queue 4:9 (QID 19)  HSA          438427 438427 1048576  0x00007e4bb1a00000 
  10   AMDGPU Queue 4:10 (QID 18) HSA          481374 481374 1048576  0x00007e4bb2c00000 
  11   AMDGPU Queue 4:11 (QID 17) HSA          479194 479194 1048576  0x00007e4bb3a00000 
  12   AMDGPU Queue 4:12 (QID 16) HSA          423666 423666 1048576  0x00007e4bb5c00000 
  13   AMDGPU Queue 4:13 (QID 15) HSA          1588   1588   4096     0x00007f91cc714000 
  14   AMDGPU Queue 3:14 (QID 14) HSA          444298 444298 1048576  0x00007e4bb7600000 
  15   AMDGPU Queue 3:15 (QID 13) HSA          453365 453365 1048576  0x00007e4bb8800000 
  16   AMDGPU Queue 3:16 (QID 12) HSA          425246 425246 1048576  0x00007e4bbc000000 
  17   AMDGPU Queue 3:17 (QID 11) HSA          418775 418775 1048576  0x00007e4bbd200000 
  18   AMDGPU Queue 3:18 (QID 10) HSA          1592   1592   4096     0x00007f91cce98000 
  19   AMDGPU Queue 2:19 (QID 9)  HSA          444064 444064 1048576  0x00007e4bbec00000 
  20   AMDGPU Queue 2:20 (QID 8)  HSA          455545 455545 1048576  0x00007e4bbfe00000 
  21   AMDGPU Queue 2:21 (QID 7)  HSA          419029 419029 1048576  0x00007e4bc0c00000 
  22   AMDGPU Queue 2:22 (QID 6)  HSA          419071 419071 1048576  0x00007e4bc2e00000 
  23   AMDGPU Queue 2:23 (QID 5)  HSA          1580   1580   4096     0x00007f91cceda000 
  24   AMDGPU Queue 1:24 (QID 4)  HSA          438252 438252 1048576  0x00007e4bc4800000 
  25   AMDGPU Queue 1:25 (QID 3)  HSA          2569549 2569550 1048576  0x00007e4bc5a00000 
  26   AMDGPU Queue 1:26 (QID 2)  HSA          480617 480617 1048576  0x00007e4bc8600000 
  27   AMDGPU Queue 1:27 (QID 1)  HSA          4735680 4735680 1048576  0x00007e4bc9800000 
  28   AMDGPU Queue 1:28 (QID 0)  HSA          1660   1660   4096     0x00007f91ccf1c000 
  
(gdb) dump_hsa_queue 0x00007e4bc9800000  2569549 2569550 1048576
------------------------------
Packet #2293 at 0x7e47efe23d40: header=0x1503 (type=3, barrier=1, acquire=2, release=2)
Barrier Packet Fields:
  dep_signal[0]=0x0
  dep_signal[1]=0x0
  dep_signal[2]=0x0
  dep_signal[3]=0x0
  dep_signal[4]=0x0
  completion_signal=0x7e4cb57d3100

(gdb) dump_hsa_signal 0x7e4cb57d3100
Signal at 0x7e4cb57d3100:
Signal Fields:
  kind=user(1)
  value=1
  mailbox_ptr=0x7f8df84c37d8
  event_id=1787
  start_ts=257063712923241, end_ts=257063712923413
  queue_ptr=0x0
```

save all packet into file:
```
(gdb) dump_queue_memory binary qid3_0x00007e4bc5a00000 0x00007e4bc5a00000 1048576
success: qid3_0x00007e4bc5a00000 (size:  1048576 bytes)
```