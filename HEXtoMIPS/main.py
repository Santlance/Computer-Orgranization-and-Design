# -*- coding: UTF-8 -*-
import capstone as cs
import sys

def main():
    engine = cs.Cs(cs.CS_ARCH_MIPS, cs.CS_MODE_32 + cs.CS_MODE_BIG_ENDIAN)
    for i in range(1, len(sys.argv)):
        hex = bytearray.fromhex("")
        f = open(sys.argv[i])
        lines = f.readlines()
        for j in lines:
            hex += bytearray.fromhex(j)
        out = open(sys.argv[i] + ".s", "w")
        for insn in engine.disasm(hex, 0x0):
            out.write(insn.mnemonic + " " + insn.op_str + "\n")

if __name__ == "__main__":
    main()
