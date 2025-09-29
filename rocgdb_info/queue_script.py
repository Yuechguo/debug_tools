import gdb
import struct
import os


class DumpHsaQueue(gdb.Command):
    """Dump HSA queue"""

    def __init__(self):
        super(DumpHsaQueue, self).__init__("dump_hsa_queue", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        args = gdb.string_to_argv(arg)
        if len(args) != 3 and len(args) != 4:
            print("usage: dump_hsa_queue <queue> <start> <end> [size_bytes]")
            return

        base = int(gdb.parse_and_eval(args[0]))
        start_idx = int(gdb.parse_and_eval(args[1]))
        end_idx = int(gdb.parse_and_eval(args[2]))
        size_bytes = 0 if len(args) == 3 else int(gdb.parse_and_eval(args[3]))
        mod = size_bytes // 64
        
        start_idx %= mod
        end_idx %= mod
        
        assert start_idx < end_idx

        inferior = gdb.selected_inferior()

        for i in range(start_idx, end_idx):
            addr = base + i * 64
            try:
                data = inferior.read_memory(addr, 64).tobytes()
            except gdb.MemoryError:
                print(f"Cannot read memory at 0x{addr:x}")
                continue

            (header,) = struct.unpack_from("<H", data, 0)
            type_ = header & 0xFF
            (completion_signal,) = struct.unpack_from("<Q", data, 56)

            print("-" * 30)
            print(
                f"Packet #{i} at 0x{addr:x}: header=0x{header:04x} (type={type_}, barrier={(header >> 8) & 1}, acquire={(header >> 9) & 3}, release={(header >> 11) & 3})"
            )

            if type_ == 1:
                print("Invalid packet type, raw dump:")
                print(" ".join(f"{b:02x}" for b in data[:64]))
                try:
                    (second_word,) = struct.unpack_from("<I", data, 4)
                    type_ = 2 if second_word != 0 else 3
                    print(f"Read invalid packet as type {type_}\n")
                except struct.error:
                    pass

            if type_ == 2:  # Kernel dispatch
                try:
                    (
                        setup,
                        wg_x,
                        wg_y,
                        wg_z,
                        grid_x,
                        grid_y,
                        grid_z,
                        pvt,
                        grp,
                        kern_obj,
                        kern_arg,
                    ) = struct.unpack_from("<H HHH xx III II QQ", data, 2)
                    kern_name = gdb.execute(
                        f"info symbol 0x{kern_obj:x}", to_string=True
                    ).split(" in ")[0]
                    print("Kernel Dispatch Packet Fields:")
                    print(f"  setup=0x{setup:x}")
                    print(f"  workgroup=[{wg_x},{wg_y},{wg_z}]")
                    print(f"  grid=[{grid_x},{grid_y},{grid_z}]")
                    print(f"  private_segment_size={pvt}, group_segment_size={grp}")
                    print(f'  kernel_object=0x{kern_obj:x} "{kern_name}"')
                    print(f"  kernarg_address=0x{kern_arg:x}")
                except struct.error:
                    print("  Failed to decode kernel dispatch packet")

            elif type_ in (3, 5):  # Barrier And / Barrier Or
                try:
                    dep_signals = struct.unpack_from("<5Q", data, 8)
                    print("Barrier Packet Fields:")
                    for j, s in enumerate(dep_signals):
                        print(f"  dep_signal[{j}]=0x{s:x}")
                except struct.error:
                    print("  Failed to decode barrier packet")

            elif type_ == 4:  # Agent dispatch
                try:
                    (agend_type,) = struct.unpack_from("<H", data, 2)
                    print("Agent Dispatch Packet Fields:")
                    print(f"  type=0x{agend_type:x}")
                except struct.error:
                    print("  Failed to decode agent dispatch packet")

            else:
                print("Unknown packet type, raw dump:")
                print(" ".join(f"{b:02x}" for b in data[:64]))

            print(f"  completion_signal=0x{completion_signal:x}")


DumpHsaQueue()

class DumpHsaQueueSearch(gdb.Command):
    """Dump HSA queue"""

    def __init__(self):
        super(DumpHsaQueueSearch, self).__init__("dump_hsa_queue_search", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        args = gdb.string_to_argv(arg)
        if len(args) != 3 and len(args) != 4:
            print("usage: dump_hsa_queue_search <queue> <start> <end> [size_bytes] <signal>")
            return

        base = int(gdb.parse_and_eval(args[0]))
        start_idx = int(gdb.parse_and_eval(args[1]))
        end_idx = int(gdb.parse_and_eval(args[2]))
        size_bytes = 0 if len(args) == 3 else int(gdb.parse_and_eval(args[3]))
        target_signal = int(gdb.parse_and_eval(args[4]))
        mod = size_bytes // 64
        
        start_idx %= mod
        end_idx %= mod
        
        assert start_idx < end_idx

        inferior = gdb.selected_inferior()

        for i in range(start_idx, end_idx):
            addr = base + i * 64
            try:
                data = inferior.read_memory(addr, 64).tobytes()
            except gdb.MemoryError:
                print(f"Cannot read memory at 0x{addr:x}")
                continue

            (completion_signal,) = struct.unpack_from("<Q", data, 56)
            
            if completion_signal == target_signal:
                print("-" * 30)
                print(f"  packet_idx={i} completion_signal=0x{completion_signal:x}")


DumpHsaQueueSearch()

class DumpHsaSignal(gdb.Command):
    """Dump HSA signal"""

    def __init__(self):
        super(DumpHsaSignal, self).__init__("dump_hsa_signal", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        args = gdb.string_to_argv(arg)

        if len(args) != 1:
            print("usage: dump_hsa_signal <signal>")
            return

        addr = int(gdb.parse_and_eval(args[0]))

        inferior = gdb.selected_inferior()

        try:
            data = inferior.read_memory(addr, 64).tobytes()
        except gdb.MemoryError:
            print(f"Cannot read memory at 0x{addr:x}")
            return
        try:
            (
                kind,
                value,
                mailbox_ptr,
                event_id,
                start_ts,
                end_ts,
                queue_ptr,
            ) = struct.unpack_from("<qQ QI xxxx QQ Q", data, 0)
            kind= {0: "invalid(0)", 1: "user(1)", -1: "doorbell(-1)", -2: "legacy(-2)"}.get(
                kind, kind
            )
            print(f"Signal at 0x{addr:x}:")
            print("Signal Fields:")
            print(f"  kind={kind}")
            print(f"  value={value}")
            print(f"  mailbox_ptr=0x{mailbox_ptr:x}")
            print(f"  event_id={event_id}")
            print(f"  start_ts={start_ts}, end_ts={end_ts}")
            print(f"  queue_ptr=0x{queue_ptr:x}")
        except struct.error as e:
            print(e)
            print("  Failed to decode hsa signal")


DumpHsaSignal()

class ModifyHsaSignal(gdb.Command):
    """
    ModifyHsaSignal : modify_hsa_signal <signal> value
    """
    
    def __init__(self):
        super(DumpQueueMemory, self).__init__("modify_hsa_signal", gdb.COMMAND_USER)
        
    def invoke(self, arg, from_tty):
        args = gdb.string_to_argv(arg)
        if len(args) != 2:
            print("usage: modify_hsa_signal <signal> value")
            return
        
        signal_addr = int(gdb.parse_and_eval(args[3]))
        val = int(gdb.parse_and_eval(args[3]))
        inferior = gdb.selected_inferior()

        try:
            data = inferior.read_memory(signal_addr, 64).tobytes()
        except gdb.MemoryError:
            print(f"Cannot read memory at 0x{signal_addr:x}")
            return
        
        try:
            (
                kind,
                value,
                mailbox_ptr,
                event_id,
                start_ts,
                end_ts,
                queue_ptr,
            ) = struct.unpack_from("<qQ QI xxxx QQ Q", data, 0)
            kind= {0: "invalid(0)", 1: "user(1)", -1: "doorbell(-1)", -2: "legacy(-2)"}.get(
                kind, kind
            )
            print(f"Signal at 0x{signal_addr:x}:")
            print("Signal Fields:")
            print(f"  kind={kind}")
            print(f"  value={value}")
            print(f"  mailbox_ptr=0x{mailbox_ptr:x}")
            print(f"  event_id={event_id}")
            print(f"  start_ts={start_ts}, end_ts={end_ts}")
            print(f"  queue_ptr=0x{queue_ptr:x}")
        except struct.error as e:
            print(e)
            print("  Failed to decode hsa signal")
            return
        
        # Modify the value field (offset 8 bytes for the 'value' field)
        try:
            new_data = bytearray(data)
            struct.pack_into("<Q", new_data, 8, val)
            inferior.write_memory(signal_addr, new_data)
            print(f" Modified signal at 0x{signal_addr:x} - value changed from {value} to {val}")
            
            # Verify the change
            # verify_data = inferior.read_memory(signal_addr, 64).tobytes()
            # new_value = struct.unpack_from("<Q", verify_data, 8)[0]
            # print(f"Verified new value: {new_value}")
            
        except gdb.MemoryError:
            print(f"Cannot write memory at 0x{signal_addr:x}")
        except Exception as e:
            print(f"Error modifying signal: {e}")
        

ModifyHsaSignal()

class DumpSdmaQueue(gdb.Command):
    """Dump SDMA queue"""

    def __init__(self):
        super(DumpSdmaQueue, self).__init__("dump_sdma_queue", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        args = gdb.string_to_argv(arg)
        if len(args) != 1 and len(args) != 2:
            print("usage: dump_sdma_queue <queue> [max_size]")
            return

        base = int(gdb.parse_and_eval(args[0]))
        max_size = 1024 * 1024 if len(args) == 1 else int(gdb.parse_and_eval(args[1]))

        inferior = gdb.selected_inferior()

        addr = base
        end = base + max_size
        i = 0
        while addr < end:
            try:
                data = inferior.read_memory(addr, 1).tobytes()
            except gdb.MemoryError:
                print(f"Cannot read memory at 0x{addr:x}")
                break

            op = data[0]

            if op == 0:
                break

            print("-" * 30)
            print(f"Packet #{i} at 0x{addr:x}: op=0x{op:x}")

            if op == 1:  # SDMA_OP_COPY
                try:
                    data = inferior.read_memory(addr, 28).tobytes()
                except gdb.MemoryError:
                    print(f"Cannot read memory at 0x{addr:x}")
                    break
                try:
                    (
                        sub_op,
                        count,
                        parameter,
                        src_addr,
                        dst_addr,
                    ) = struct.unpack_from("<B xx II QQ", data, 1)
                    print("Copy Packet Fields:")
                    print(f"  sub_op={sub_op}")
                    print(f"  count={count + 1}")
                    print(f"  parameter=0x{parameter:x}")
                    print(f"  src_addr=0x{src_addr:x}")
                    print(f"  dst_addr=0x{dst_addr:x}")
                except struct.error:
                    print("  Failed to decode copy packet")
                addr += 28
            elif op == 5:  # SDMA_OP_FENCE
                try:
                    data = inferior.read_memory(addr, 16).tobytes()
                except gdb.MemoryError:
                    print(f"Cannot read memory at 0x{addr:x}")
                    break
                try:
                    (
                        header,
                        addr_,
                        data_,
                    ) = struct.unpack_from("<IQI", data, 0)
                    print("Fence Packet Fields:")
                    print(f"  header={header >> 16}")
                    print(f"  addr=0x{addr_:x}")
                    print(f"  data={data_}")
                except struct.error:
                    print("  Failed to decode fence packet")
                addr += 16
            elif op == 6:  # SDMA_OP_TRAP
                try:
                    data = inferior.read_memory(addr, 8).tobytes()
                except gdb.MemoryError:
                    print(f"Cannot read memory at 0x{addr:x}")
                    break
                try:
                    (
                        context,
                    ) = struct.unpack_from("<I", data, 4)
                    print("Trap Packet Fields:")
                    print(f"  context={context}")
                except struct.error:
                    print("  Failed to decode trap packet")
                addr += 8
            elif op == 8:  # SDMA_OP_POLLREGMEM
                try:
                    data = inferior.read_memory(addr, 24).tobytes()
                except gdb.MemoryError:
                    print(f"Cannot read memory at 0x{addr:x}")
                    break
                try:
                    (
                        sub_op,
                        addr_,
                        value,
                        mask,
                        interval,
                        retry_count,
                    ) = struct.unpack_from("<B xx Q iI HH", data, 1)
                    print("Poll Packet Fields:")
                    print(f"  sub_op={sub_op}")
                    print(f"  addr=0x{addr_:x} #signal(0x{(addr_ - 8):x})")
                    print(f"  value={value}")
                    print(f"  mask=0x{mask:x}")
                    print(f"  interval={interval}")
                    print(f"  retry_count={retry_count}")
                except struct.error:
                    print("  Failed to decode poll packet")
                addr += 24
            elif op == 10:  # SDMA_OP_ATOMIC
                try:
                    data = inferior.read_memory(addr, 32).tobytes()
                except gdb.MemoryError:
                    print(f"Cannot read memory at 0x{addr:x}")
                    break
                try:
                    (
                        sub_op,
                        op_,
                        addr_,
                        src_data,
                        cmp_data,
                        interval,
                    ) = struct.unpack_from("<B x B Q qq I", data, 1)
                    print("Atomic Packet Fields:")
                    print(f"  sub_op={sub_op}")
                    print(f"  op={op_ >> 1}")
                    print(f"  addr=0x{addr_:x}")
                    print(f"  src_data={src_data}")
                    print(f"  cmp_data={cmp_data}")
                    print(f"  interval={interval}")
                except struct.error:
                    print("  Failed to decode atomic packet")
                addr += 32
            else:
                print("Unknown packet type")
                break

DumpSdmaQueue()

class DumpQueueMemory(gdb.Command):
    """Dump Queue Memory
       dump_queue_memory binary queue_1 0x000000324434 1048576
    """
    FORMATS = {
        'binary': 'binary',
        'ihex': 'ihex', 
        'srec': 'srec',
        'tekhex': 'tekhex',
        'verilog': 'verilog'
    }
    
    def __init__(self):
        super(DumpQueueMemory, self).__init__("dump_queue_memory", gdb.COMMAND_USER)
    
    def _execute_gdb_command(self, command: str) -> str:
        try:
            result = gdb.execute(command, to_string=True)
            return result.strip()
        except gdb.error as e:
            raise RuntimeError(f"failed: {command}\n error: {e}")
        
    def invoke(self, arg, from_tty):
        args = gdb.string_to_argv(arg)
        if len(args) != 4:
            print("usage: dump_queue_memory [format] [filename] <queue> [size_bytes]")
            return
        
        format_type = str(args[0])
        filename = str(args[1])
        start_addr = int(gdb.parse_and_eval(args[2]))
        end_addr =  start_addr + int(gdb.parse_and_eval(args[3]))
  
        command = f"dump {self.FORMATS[format_type]} memory {filename} {start_addr:#x} {end_addr:#x}"
        
        try:
            result = self._execute_gdb_command(command)
            if os.path.exists(filename) and os.path.getsize(filename) > 0:
                print(f"success: {filename} (size: {os.path.getsize(filename)} bytes)")
            else:
                print("warning: {filename} is empty or save memory to file failed")
        except Exception as e:
            print(f"{e}")

DumpQueueMemory()