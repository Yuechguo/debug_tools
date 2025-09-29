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

modify signal:
```
(gdb) modify_hsa_signal 0x7e4cb57d3100 0
Signal Fields:
  kind=user(1)
  value=1
  mailbox_ptr=0x7f8df84c37d8
  event_id=1787
  start_ts=257063712923241, end_ts=257063712923413
  queue_ptr=0x0
  Modified signal at 0x7e4cb57d3100 - value changed from 1 to 0
```

get doorbell signal from the rocgdb:
```
(gdb) thread 348
(gdb) bt
#0  0x00007f07556687c7 in rocr::timer::fast_clock::now () at /data/testhome/mainline-rocm-runtime/amd_new_base/ROCR-Runtime/runtime/hsa-runtime/core/util/timer.h:140
#1  rocr::core::InterruptSignal::WaitRelaxed (this=0x7dc1642d2ee0, condition=HSA_SIGNAL_CONDITION_LT, compare_value=1, timeout=<optimized out>, wait_hint=HSA_WAIT_STATE_ACTIVE)
    at /data/testhome/mainline-rocm-runtime/amd_new_base/ROCR-Runtime/runtime/hsa-runtime/core/runtime/interrupt_signal.cpp:212
#2  0x00007f075566808a in rocr::core::InterruptSignal::WaitAcquire (this=<optimized out>, condition=<optimized out>, compare_value=<optimized out>, timeout=<optimized out>, wait_hint=<optimized out>)
    at /data/testhome/mainline-rocm-runtime/amd_new_base/ROCR-Runtime/runtime/hsa-runtime/core/runtime/interrupt_signal.cpp:265
#3  0x00007f075565cff9 in rocr::HSA::hsa_signal_wait_scacquire (hsa_signal=..., condition=HSA_SIGNAL_CONDITION_LT, compare_value=1, timeout_hint=18446744073709551615, 
    wait_state_hint=HSA_WAIT_STATE_ACTIVE) at /data/testhome/mainline-rocm-runtime/amd_new_base/ROCR-Runtime/runtime/hsa-runtime/core/runtime/hsa.cpp:1239
#4  0x00007f0753f393fb in amd::roc::WaitForSignal<false> (forced_wait=false, active_wait=<optimized out>, signal=...)
    at /data/testhome/mainline-rocm-runtime/amd_new_base/clr/rocclr/device/rocm/rocvirtual.hpp:70
#5  amd::roc::Device::IsHwEventReady (this=<optimized out>, event=..., wait=<optimized out>, hip_event_flags=<optimized out>)
    at /data/testhome/mainline-rocm-runtime/amd_new_base/clr/rocclr/device/rocm/rocdevice.cpp:3007
#6  0x00007f0753f1e67a in amd::HostQueue::finish (this=0x7dc622f51900, cpu_wait=<optimized out>) at /data/testhome/mainline-rocm-runtime/amd_new_base/clr/rocclr/platform/commandqueue.cpp:164
#7  0x00007f0753cba6ce in hip::Device::SyncAllStreams (this=0x7dc624314300, cpu_wait=<optimized out>, wait_blocking_streams_only=<optimized out>)
    at /data/testhome/mainline-rocm-runtime/amd_new_base/clr/hipamd/src/hip_device.cpp:281
#8  0x00007f0753ca5799 in hip::hipDeviceSynchronize () at /data/testhome/mainline-rocm-runtime/amd_new_base/clr/hipamd/src/hip_device_runtime.cpp:621
#9  0x00007f075b9b04ab in stream_executor::gpu::GpuDriver::SynchronizeContext () at external/org_tensorflow/tensorflow/stream_executor/rocm/rocm_driver.cc:886
#10 0x00007f075b83805c in stream_executor::StreamExecutor::SynchronizeAllActivity () at external/org_tensorflow/tensorflow/stream_executor/stream_executor_pimpl.cc:554
#11 0x00007f075f18e10a in tensorflow::XlaCompilationCache::~XlaCompilationCache () at external/org_tensorflow/tensorflow/compiler/jit/xla_compilation_cache.cc:78
#12 0x00007f075f18e512 in tensorflow::XlaCompilationCache::~XlaCompilationCache () at external/org_tensorflow/tensorflow/compiler/jit/xla_compilation_cache.cc:90
#13 0x00007f075b25c4d7 in tensorflow::core::RefCounted::Unref () at external/org_tensorflow/tensorflow/core/lib/core/refcount.h:104
#14 tensorflow::core::RefCounted::Unref () at external/org_tensorflow/tensorflow/core/lib/core/refcount.h:97
#15 tensorflow::ResourceMgr::Clear () at external/org_tensorflow/tensorflow/core/framework/resource_mgr.cc:119
#16 0x00007f07664a68a4 in tensorflow::DirectSession::~DirectSession () at external/org_tensorflow/tensorflow/core/common_runtime/direct_session.cc:474
#17 0x00007f07664a72b2 in tensorflow::DirectSession::~DirectSession () at external/org_tensorflow/tensorflow/core/common_runtime/direct_session.cc:478
#18 0x00000000059de862 in std::_Sp_counted_base<(__gnu_cxx::_Lock_policy)2>::_M_release () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/shared_ptr_base.h:158
#19 std::__shared_count<(__gnu_cxx::_Lock_policy)2>::~__shared_count () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/shared_ptr_base.h:733
#20 std::__shared_ptr<tensorflow::Session, (__gnu_cxx::_Lock_policy)2>::~__shared_ptr () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/shared_ptr_base.h:1183
#21 std::shared_ptr<tensorflow::Session>::~shared_ptr () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/shared_ptr.h:121
#22 std::_Destroy<std::shared_ptr<tensorflow::Session> > () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/stl_construct.h:140
#23 std::_Destroy_aux<false>::__destroy<std::shared_ptr<tensorflow::Session>*> () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/stl_construct.h:152
#24 std::_Destroy<std::shared_ptr<tensorflow::Session>*> () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/stl_construct.h:185
#25 std::_Destroy<std::shared_ptr<tensorflow::Session>*, std::shared_ptr<tensorflow::Session> > () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/alloc_traits.h:738
#26 std::vector<std::shared_ptr<tensorflow::Session>, std::allocator<std::shared_ptr<tensorflow::Session> > >::~vector ()
    at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/stl_vector.h:680
#27 suez::turing::TfSession::~TfSession () at bazel-out/k8-opt/bin/aios/suez_turing/_virtual_includes/query_resource/suez/turing/common/TfSession.h:15
#28 __gnu_cxx::new_allocator<suez::turing::TfSession>::destroy<suez::turing::TfSession> () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/ext/new_allocator.h:156
#29 std::allocator_traits<std::allocator<suez::turing::TfSession> >::destroy<suez::turing::TfSession> () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/alloc_traits.h:531
#30 std::_Sp_counted_ptr_inplace<suez::turing::TfSession, std::allocator<suez::turing::TfSession>, (__gnu_cxx::_Lock_policy)2>::_M_dispose ()
    at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/shared_ptr_base.h:560
#31 0x000000000631ab72 in std::_Sp_counted_base<(__gnu_cxx::_Lock_policy)2>::_M_release () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/shared_ptr_base.h:158
#32 std::__shared_count<(__gnu_cxx::_Lock_policy)2>::~__shared_count () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/shared_ptr_base.h:733
#33 std::__shared_ptr<suez::turing::TfSession, (__gnu_cxx::_Lock_policy)2>::~__shared_ptr () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/shared_ptr_base.h:1183
#34 std::shared_ptr<suez::turing::TfSession>::~shared_ptr () at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/shared_ptr.h:121
#35 std::pair<std::basic_string<char, std::char_traits<char>, std::allocator<char> > const, std::shared_ptr<suez::turing::TfSession> >::~pair ()
    at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/stl_pair.h:211
#36 __gnu_cxx::new_allocator<std::_Rb_tree_node<std::pair<std::basic_string<char, std::char_traits<char>, std::allocator<char> > const, std::shared_ptr<suez::turing::TfSession> > > >::destroy<std::pair<std::basic_string<char, std::char_traits<char>, std::allocator<char> > const, std::shared_ptr<suez::turing::TfSession> > > ()
    at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/ext/new_allocator.h:156
#37 std::allocator_traits<std::allocator<std::_Rb_tree_node<std::pair<std::basic_string<char, std::char_traits<char>, std::allocator<char> > const, std::shared_ptr<suez::turing::TfSession> > > > >::destroy<std::pair<std::basic_string<char, std::char_traits<char>, std::allocator<char> > const, std::shared_ptr<suez::turing::TfSession> > > ()
    at /usr/lib/gcc/x86_64-redhat-linux/10/../../../../include/c++/10/bits/alloc_traits.h:531
#38 std::_Rb_tree<std::basic_string<char, std::char_traits<char>, std::allocator<char> >, std::pair<std::basic_string<char, std::char_traits<char>, std::allocator<char> > const, std::shared_ptr<suez::turing::TfSession> >, std::_Select1st<std::pair<std::basic_string<char, std::char_traits<char>, std::allocator<char> > const, std::shared_ptr<suez::turing::TfSession> > >, std::less<std::basic_string<char, std:--Type <RET> for more, q to quit, c to continue without paging--Quit
(gdb) f 6
(gdb) p command->queue_
$2 = (amd::HostQueue *) 0x7dc622f51900
(gdb) p ((amd::HostQueue *) 0x7dc622f51900)->thread_.virtualDevice_
$3 = (amd::device::VirtualDevice *) 0x7dc6233a8f00
(gdb) p ((amd::roc::VirtualGPU *) 0x7dc6233a8f00)->gpu_queue_
$4 = (hsa_queue_t *) 0x7f0757fde000
(gdb) p ((hsa_queue_t *) 0x7f0757fde000)->doorbell_signal->handle
```