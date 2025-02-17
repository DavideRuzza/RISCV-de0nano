import struct
from math import ceil, log2
from enum import Enum

UNICODE = True

if UNICODE:
    TR="\u256e" # top right
    TL="\u256d" # top left
    BR="\u256f" # bottom right
    BL="\u2570" # bottom left
    VE="\u2502" # vertical
    HO="\u2500" # horizontal
    TC="\u252c" # top cross
    BC="\u2534" # bottom cross
else:
    TR="\\" # top right
    TL="/" # top left
    BR="/" # bottom right
    BL="\\" # bottom left
    VE="|" # vertical
    HO="-" # horizontal
    TC="+" # top cross
    BC="+" # bottom cross

# MASK64 = (1<<64)-1
# MASK32 = (1<<32)-1



class MainMemory:
    def __init__(self, size_Kb, offset=0, bus_size=32):
        # size in KB
        self.offset = offset
        self.mask = (1<<bus_size)
        self.size_kb = size_Kb
        self.size_byte = self.size_kb*0x400
        self.mem = b'\x00' * self.size_byte
    
    def clear(self):
        self.mem = b'\x00' * self.size_byte
    def write_block(self, addr, data: bytearray):
        addr -= self.offset
        assert 0 <= addr
        assert addr <= int(self.size_byte)
        self.mem = self.mem[:addr] + data + self.mem[addr+len(data):]

    def hexdump(self, bytes_per_line=16):
                   
        previous_line = None
        repeated = False
        offset = 0

        for i in range(0, len(self.mem), bytes_per_line):
            chunk = self.mem[i:i + bytes_per_line]
            hex_part = " ".join(f"{b:02x}" for b in chunk)
            ascii_part = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
            if chunk == previous_line:
                if not repeated:
                    print("*")
                    repeated = True
            else:
                print(f"{offset:08x}  {hex_part:<{bytes_per_line * 3}}  |{ascii_part}|")
                repeated = False
            previous_line = chunk
            offset += bytes_per_line
        
        if repeated:
            print(f"{offset-bytes_per_line:08x}  {hex_part:<{bytes_per_line * 3}}  |{ascii_part}|")
        
    def __getitem__(self, addr):
        if isinstance(addr, int):
            addr -= self.offset
            assert 0 <= addr < int(self.size_byte/4)
            return struct.unpack("<I", self.mem[addr:addr+4])[0]
        elif isinstance(addr, slice):
            start = addr.start
            end = addr.start
            return self.mem[end:start]
    
    def __setitem__(self, addr, value):
        addr -= self.offset
        assert 0 <= addr < int(self.size_byte)
        self.mem = self.mem[:addr] + struct.pack("<I", value&0xffffffff) + self.mem[addr+4:]
        
    def __str__(self):
        return f"Memory size: {len(self.mem)} ({self.size_kb} KB)"
     
class Wire:
    
    def __init__(self, initial:int=0):
        self._value=initial
    
    @property
    def value(self):
        return self._value
    
    def l(self):
        self._value=0
    
    def h(self):
        self._value=1
    
    def __str__(self):
        return f"wire: {self._value}"

    
    
class Reg:
    def __init__(self, nbits, data=0):
        self.nbits = nbits
        self.mask = (1<<self.nbits)-1
        
        if data>0:
            assert log2(data) < self.nbits, "%x can't be represented with %d bits, needs at least %d"%(data, self.nbits, log2(data)+1)
        self.reg = data & self.mask
    
    def write(self, data):
        # print("type ",type(data), log2(3) )
        # assert log2(data) < self.nbits, "Reg assigment invalid, not enough bit %d %d"%(data, self.nbits)
        self.reg = data & self.mask
    
    def data(self):
        return self.reg
    
    def __getitem__(self, key):
        if isinstance(key, slice):
            start = key.start
            end = key.stop
            
            if start == None and end==None:
                return self.reg
            if start == None:
                start = self.nbits-1
            if end == None:
                end = 0

            assert self.nbits>start>end>=0, "Slice error, check indexes"
            return (self.reg>>end) & ((1<<(start-end+1))-1)
        else:
            assert self.nbits>key>=0, "index out of bound"
            return (self.reg>>key) & 0x01
    
    def __setitem__(self, key, value):
        
        if isinstance(key, slice):
            start = key.start
            end = key.stop
            if start == None:
                start = self.nbits-1
            if end == None:
                end = 0 
            bitsize = (start+1-end)
            assert self.nbits>start>end>=0, "Slice error, check indexes"
            assert len(bin(value)[2:]) <= bitsize
            
            slice_mask =  ~(((1<<bitsize)-1)<<end)&self.mask
            self.reg = (self.reg & slice_mask) | value << end
        elif isinstance(key, int):
            assert self.nbits>key>=0, "index out of bound"
            assert value < 2
            slice_mask =  ~(1<<key)&self.mask
            self.reg = (self.reg & slice_mask) | value << key
            
    def __str__(self):
        return "%x"%self.reg


class LatchReg:
    
    def __init__(self, sec:list[int], sec_name:list[str]=None, name:str=None, write_enable:Reg=None):
        self.sec = sec
        self.sec_name = sec_name
        self.reg_name = name
        
        self.nbits = sum(self.sec)
        self.sec_idx = {}
        self.we = write_enable
        
        if not self.sec_name:
            self.sec_name = ["s%d"%i for i in range(len(self.sec))]
        else:
            assert len(self.sec) == len(self.sec_name)
        
        self.buff_reg = [Reg(size) for size in self.sec]
        self.assiged_reg = [Reg(size) for size in self.sec]
        self.out_reg = [Reg(size) for size in self.sec]
        
        if not self.reg_name:
            self.reg_name = "Reg#"
            
        idx = self.nbits-1

        for idx, name in enumerate(self.sec_name):
            self.sec_idx[name] = idx
            
        if not self.we:
            self.we = Reg(1)
    
    def __setitem__(self, key, value):
        if isinstance(key, str):
            assert key in self.sec_name, "Key '%s' not a valid section"%key
            
            idx = self.sec_idx[key]
            reg_size = self.sec[idx]
            
            if isinstance(value, Reg):
                # print("setting by reg")
                assert value.nbits == reg_size, "trying to assign %d bits to a Reg size of %d bits"%(value.nbits, reg_size)
                self.buff_reg[idx] = value
            elif isinstance(value, int):
                self.buff_reg[idx].write(value)
            
    def __getitem__(self, key):
        if isinstance(key, str):
            assert key in self.sec_name, "Key '%s' not a valid section"%key
            
            return self.out_reg[self.sec_idx[key]]
    
    def show(self, only_out=False, show=True):
        top_row = TL
        name_row = VE+" "
        buff_row = VE+" "
        out_row = VE+" "
        bott_row = BL
        
        
        for size, name, buff, out in zip(self.sec, self.sec_name, self.buff_reg, self.out_reg):
            sec_hex_size = ceil(size/4)
            buff_partial = f"{buff.data():0{sec_hex_size}x}"
            out_partial = f"{out.data():0{sec_hex_size}x}"

            sec_space = max(sec_hex_size, len(name))
            name_row+=f"{name:>{sec_space}s} "
            buff_row+=f"{buff_partial:>{sec_space}s} "
            out_row+=f"{out_partial:>{sec_space}s} "
        
        name_row+=" "+VE
        buff_row+=" "+VE
        out_row+=" "+VE
 
        hor_lines = len(name_row)-2-len(self.reg_name)-2
        half_hor_lines = ceil(hor_lines/2)
        
        top_row+=HO*half_hor_lines+f" {self.reg_name} "+HO*(hor_lines-half_hor_lines)+TR
        bott_row+=HO*(len(name_row)-2)+BR
        if show:
            if only_out:
                print("\n".join([top_row, name_row, out_row, bott_row]))
            else:
                print("\n".join([top_row, name_row, buff_row, out_row, bott_row]))
        
        return [top_row, name_row, buff_row, out_row, bott_row]
    
    def rst_input(self):
        for i in range(len(self.buff_reg)):
            self.buff_reg[i].write(0)
            self.update()
    
    def flush_output(self):
        for i in range(len(self.out_reg)):
            self.out_reg[i].write(0)
        
    def write_en(self):
        self.we[0] = 1
    
    def write_dis(self):
        self.we[0] = 0
    
    def update(self):
        # if self.we[0]:
        for idx, reg in enumerate(self.buff_reg):
            # print(reg.data())
            self.assiged_reg[idx].write(reg.data())
                
    def clk(self):
        if self.we[0]:
            for idx, reg in enumerate(self.assiged_reg):
                # print(reg.data())
                self.out_reg[idx].write(reg.data())
            
    def __str__(self):
        return f"{self.name} sec:{self.buff_reg}"

class RegFile:
    
    def __init__(self, n_regs, bus_size=32, reg_names:list[str]=None):
        self.n_reg = n_regs
        self.n_reg_log2 = int(log2(self.n_reg))
        self.bus_size = bus_size
        self.mask = (1<<self.bus_size)-1
        self.reg_file = [Reg(self.bus_size) for _ in range(self.n_reg)]
        self.reg_names = reg_names
        
        if not self.reg_names:
            self.reg_names = ["x%d"%i for i in range(self.n_reg)]
        else:
            assert self.n_reg == len(self.reg_names), "Number of names != reg number"
        
        self.raddr1 = Reg(self.n_reg_log2)
        self.raddr2 = Reg(self.n_reg_log2)
        self.waddr  = Reg(self.n_reg_log2)
        
        self.data1 = Reg(self.bus_size)
        self.data2 = Reg(self.bus_size)
        self.wdata = Reg(self.bus_size)
        
        self.we = Reg(1, 0)
    
    def clk(self):
        if self.we[:]==1 and self.waddr.data()!=0:
            self.reg_file[self.waddr[:]][:] = self.wdata[:]
        
    def update(self):
        if self.raddr1[:] == 0:
            self.data1[:] = 0
        elif self.we[:]==1 and self.raddr1[:]==self.waddr[:]:
            self.data1[:] = self.wdata[:]
            # print("from write to r1")
        else:
            self.data1[:] = self.reg_file[self.raddr1[:]][:]
            
        if self.raddr2[:] == 0:
            self.data2[:] = 0
        elif self.we[:]==1 and self.raddr2[:]==self.waddr[:]:
            self.data2[:] = self.wdata[:]
            # print("from write to r2")
            
        else:
            self.data2[:] = self.reg_file[self.raddr2[:]][:]
    
    def set_raddr1(self, raddr1:Reg):
        assert raddr1.nbits == self.raddr1.nbits, "rdata1 bitsize is not the same %d %d"%(raddr1.nbits,self.raddr1.nbits)
        self.raddr1 = raddr1

    def set_raddr2(self, raddr2:Reg):
        assert raddr2.nbits == self.raddr2.nbits, "rdata1 bitsize is not the same"
        self.raddr2 = raddr2

    def set_waddr(self, waddr:Reg):
        assert waddr.nbits == self.waddr.nbits, "rdata1 bitsize is not the same"
        self.waddr = waddr

    def set_wdata(self, wdata:Reg):
        assert wdata.nbits == self.wdata.nbits, "rdata1 bitsize is not the same"
        self.wdata = wdata

    def set_we(self, we:Wire):
        self.we = we
        
    def set_input(self, raddr1:Reg, raddr2:Reg, waddr:Reg, wdata:Reg, we:Wire):
        assert raddr1.nbits == self.raddr1.nbits, "rdata1 bitsize is not the same"
        assert raddr2.nbits == self.raddr2.nbits, "rdata1 bitsize is not the same"
        assert waddr.nbits == self.waddr.nbits, "rdata1 bitsize is not the same"
        assert wdata.nbits == self.wdata.nbits, "rdata1 bitsize is not the same"
        
        self.raddr1 = raddr1
        self.raddr2 = raddr2
        self.waddr = waddr
        self.wdata = wdata
        self.we = we
    
    def write_direct(self, addr, data):
        self.reg_file[addr][:] = data&self.mask
    
    def input_state(self):
        return f"rs1:{self.raddr1[:]}, rs2:{self.raddr2[:]}, wadd:{self.waddr[:]}, wdata:{self.wdata[:]:08x}, we:{self.we[:]}"
    
    def output_state(self):
        return f"data1:{self.data1[:]:08x} data2:{self.data2[:]:08x}"
        
    def __str__(self):
        dump_str=""
        # dump_str = self.input_state()
        # dump_str += "\n"
        for i , name in zip(range(self.n_reg), self.reg_names):
            if (i)%4 == 0 and i>0:
                dump_str += '\n'
            if i>15:
                break
            dump_str+="%3s: %08x " % (name, self.reg_file[i][:])
        return dump_str

def print_multi_reg(*regs:LatchReg, only_out=False):
    if len(regs) == 1:
        regs[0].show(only_out=only_out)
        return
    li0, li1, li2, li3, li4 = [i[:-1] for i in regs[0].show(show=False)]
    
    l0, l1, l2, l3, l4 = "", "", "", "", ""
     
    for reg in regs[1:-1]:
        lp0, lp1, lp2, lp3, lp4 = [i[:-1] for i in reg.show(show=False)]
        lp0=TC+lp0[1:]
        lp4=BC+lp4[1:]
        l0 += lp0
        l1 += lp1
        l2 += lp2
        l3 += lp3
        l4 += lp4
        
    lf0, lf1, lf2, lf3, lf4 = regs[-1].show(show=False)
    lf0=TC+lf0[1:]
    lf4=BC+lf4[1:]
    l0 = li0+l0+lf0
    l1 = li1+l1+lf1
    l2 = li2+l2+lf2
    l3 = li3+l3+lf3
    l4 = li4+l4+lf4
    if only_out:
        print("\n".join([l0, l1, l3, l4]))
    else:        
        print("\n".join([l0, l1, l2, l3, l4]))
        
        
##########################

def int_32(uint_32):
    uint_32 = Reg(32, uint_32)
    if uint_32[31]:
        return int(uint_32[:] - (1<<32))
    else:
        return uint_32[:] 
    
class Ops(Enum):

    INVALID = 0b0000000
    LUI = 0b0110111
    LOAD = 0b0000011
    STORE = 0b0100011
    
    AUIPC  = 0b0010111
    BRANCH = 0b1100011
    JAL = 0b1101111
    JALR = 0b1100111
    
    OP = 0b0110011
    OP_IMM = 0b0010011
    
    MISC_MEM = 0b0001111
    SYSTEM = 0b1110011

class OP_F3(Enum):
    ADD_SUB = 0b000
    SLL = 0b001
    SLT = 0b010 
    SLTU = 0b011
    XOR = 0b100
    SRX =  0b101
    OR = 0b110 
    AND = 0b111
    
class LOAD_F3(Enum):
    LB = 0b000
    LH = 0b001
    LW = 0b010
    LBU = 0b100
    LHU = 0b101

class STORE_F3(Enum):
    SB = 0b000
    SH = 0b001
    SW = 0b010
    
class BR_F3(Enum):
    BEQ = 0b000
    BNE = 0b001
    BLT = 0b100
    BGE = 0b101
    BLTU = 0b110
    BGEU = 0b111
    
class Mux:
    def __init__(self, *regs:Reg, select:Reg=None):
        
        self.mux_in = regs
        self.n_input = len(self.mux_in)
        self.sel_size = ceil(log2(self.n_input))
        self.nbits = self.mux_in[0].nbits
        self.select = select
        
        for r in self.mux_in:
            assert self.nbits == r.nbits, "input have different bit size"
        
        if not self.select:
            self.select = Reg(self.sel_size)
        else:
            # print(self.select.nbits, self.sel_size)
            assert self.select.nbits >= self.sel_size, "Not enough selection bit for %d items"%self.n_input 
        # verify every mux input has the same bit size
    
        self.output = Reg(self.nbits)
        self.update()
    
    def update(self):
        if self.select[:]>(self.n_input-1):
            self.output[:] = self.mux_in[0][:]
        else:
            self.output[:] = self.mux_in[self.select[:]][:]

    def __str__(self):
        return "sel: %s, output: %s"%(self.select, self.output)