`ifndef __CONTROLLER_V__
`define __CONTROLLER_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module ControlUnit(
    input [`Word] inst_in,
    output MemtoReg,
    output MemWrite,
    output Branch,
    output [3:0] JudgeOp,
    output [3:0] ALUCtrl,
    output ALUASrc,
    output ALUSrc,
    output RegDst,
    output RegWrite,
    output Extend,
    output Jump,
    output Jump_R,
    output Link,
    output [3:0] DataType,
    output JudgeMove,
    output Likely,
    output [3:0] MDUOp,
    output [1:0] MTHILO,
    output [1:0] MFHILO,
    output MDU_Result,
    output IgnoreExcRI,
    output ERET,
    output cpzWrite,
    output cpztoReg,
    output ExcOccur,
    output [4:0] ExcCode
);
    wire [`Word] inst = Unknown?32'b0:inst_in;

    wire [`Inst_OP]       Op = inst[`Inst_OP];
    wire [`Inst_RS]       Rs = inst[`Inst_RS];
    wire [`Inst_RT]       Rt = inst[`Inst_RT];
    wire [`Inst_RD]       Rd = inst[`Inst_RD];
    wire [`Inst_S]     Shamt = inst[`Inst_S];
    wire [`Inst_Funct] Funct = inst[`Inst_Funct];

    wire R_Type = (Op==0)?1'b1:1'b0;
    wire Unknown;

    wire ADD   = (R_Type && Shamt==0 && Funct==`ADD);
    wire ADDU  = (R_Type && Shamt==0 && Funct==`ADDU);
    wire ADDI  = (Op==`ADDI);
    wire ADDIU = (Op==`ADDIU);
    wire AND   = (R_Type && Shamt==0 && Funct==`AND);
    wire ANDI  = (Op==`ANDI);
    wire LUI   = (Op==`LUI && Rs==0);
    wire SUB   = (R_Type && Shamt==0 && Funct==`SUB);
    wire SUBU  = (R_Type && Shamt==0 && Funct==`SUBU);
    wire NOR   = (R_Type && Shamt==0 && Funct==`NOR);
    wire OR    = (R_Type && Shamt==0 && Funct==`OR);
    wire ORI   = (Op==`ORI);
    wire XOR   = (R_Type && Shamt==0 && Funct==`XOR);
    wire XORI  = (Op==`XORI);
    wire CLO   = (Op==`SPE2 && Shamt==0 && Funct==`CLO);
    wire CLZ   = (Op==`SPE2 && Shamt==0 && Funct==`CLZ);


    wire SLL  = (R_Type && Rs==0 && Funct==`SLL);
    wire SLLV = (R_Type && Shamt==0 && Funct==`SLLV);
    wire SRA  = (R_Type && Rs==0 && Funct==`SRA);
    wire SRAV = (R_Type && Shamt==0 && Funct==`SRAV);
    wire SRL  = (R_Type && Rs==0 && Funct==`SRL);
    wire SRLV = (R_Type && Shamt==0 && Funct==`SRLV);

    wire SLT   = (R_Type && Shamt==0 && Funct==`SLT);
    wire SLTI  = (Op==`SLTI);
    wire SLTIU = (Op==`SLTIU);
    wire SLTU  = (R_Type && Shamt==0 && Funct==`SLTU);

    wire BEQ    = (Op==`BEQ);
    wire BNE    = (Op==`BNE);
    wire BGEZ   = (Op==`REGIMM && Rt==`BGEZ);
    wire BLTZ   = (Op==`REGIMM && Rt==`BLTZ);
    wire BGTZ   = (Op==`BGTZ && Rt==0);
    wire BLEZ   = (Op==`BLEZ && Rt==0);
    wire BLTZAL = (Op==`REGIMM && Rt==`BLTZAL);
    wire BGEZAL = (Op==`REGIMM && Rt==`BGEZAL);
    wire BEQL   = (Op==`BEQL);
    wire BNEL   = (Op==`BNEL);

    wire J    = (Op==`J);
    wire JAL  = (Op==`JAL);
    wire JALR = (R_Type && Rt==0 && Shamt==0 && Funct==`JALR);
    wire JR   = (R_Type && Rt==0 && Rd==0 && Shamt==0 && Funct==`JR);

    wire LB  = (Op==`LB);
    wire LBU = (Op==`LBU);
    wire LH  = (Op==`LH);
    wire LHU = (Op==`LHU);
    wire LW  = (Op==`LW);
    wire LWL = (Op==`LWL);
    wire LWR = (Op==`LWR);

    wire SB  = (Op==`SB);
    wire SH  = (Op==`SH);
    wire SW  = (Op==`SW);
    wire SWL = (Op==`SWL);
    wire SWR = (Op==`SWR);
    
    wire MOVZ = (R_Type && Shamt==0 && Funct==`MOVZ);
    wire MOVN = (R_Type && Shamt==0 && Funct==`MOVN);

    wire MFC0    = (Op==`COP0 && Rs==`MFC0 && Shamt==0 && Funct==0);
    wire MTC0    = (Op==`COP0 && Rs==`MTC0 && Shamt==0 && Funct==0);
    wire BREAK   = (R_Type && Funct==`BREAK);
    assign ERET  = (Op==`OP_ERET && inst[25:6]==`I_ERET && Funct==`F_ERET);
    wire SYSCALL = (R_Type && Funct==`SYSCALL);

    wire MFHI  = (R_Type && Rs==0 && Rt==0 && Shamt==0 && Funct==`MFHI);
    wire MFLO  = (R_Type && Rs==0 && Rt==0 && Shamt==0 && Funct==`MFLO);
    wire MTHI  = (R_Type && Rt==0 && Rd==0 && Shamt==0 && Funct==`MTHI);
    wire MTLO  = (R_Type && Rt==0 && Rd==0 && Shamt==0 && Funct==`MTLO);
    wire MULT  = (R_Type && Rd==0 && Shamt==0 && Funct==`MULT);
    wire MULTU = (R_Type && Rd==0 && Shamt==0 && Funct==`MULTU);
    wire DIV   = (R_Type && Rd==0 && Shamt==0 && Funct==`DIV);
    wire DIVU  = (R_Type && Rd==0 && Shamt==0 && Funct==`DIVU);
    wire MADD  = (Op==`SPE2 && Rd==0 && Shamt==0 && Funct==`MADD);
    wire MADDU = (Op==`SPE2 && Rd==0 && Shamt==0 && Funct==`MADDU);
    wire MSUB  = (Op==`SPE2 && Rd==0 && Shamt==0 && Funct==`MSUB);
    wire MSUBU = (Op==`SPE2 && Rd==0 && Shamt==0 && Funct==`MSUBU);
    wire MUL   = (Op==`SPE2 && Shamt==0 && Funct==`MUL);


    // Outputs

    assign MemtoReg=(LW | LH | LHU | LB | LBU | LWL | LWR);

    assign MemWrite=(SW | SH | SB | SWL | SWR);

    assign Branch=(BEQ | BEQL | BNE | BNEL | BGTZ | BLEZ | BGEZ |
                   BLTZ | BLTZAL | BGEZAL);

    assign JudgeOp=(BEQ | MOVZ | BEQL)?`EQ:
                   (BNE | MOVN | BNEL)?`NE:
                   (BGTZ)?`GTZ:
                   (BLEZ)?`LEZ:
                   (BGEZ | BGEZAL)?`GEZ:
                   (BLTZ | BLTZAL)?`LTZ:
                                   4'bxxxx;

    assign ALUCtrl=
        (ADDU | ADD | ADDIU | ADDI | LW | SW | LH | LHU | SH | LB | LBU | SB | LWL | LWR | SWL | SWR)?`ALU_ADD:
        (SUBU | SUB)?`ALU_SUB:
        (LUI)?`ALU_LUI:
        (ANDI | AND)?`ALU_AND:
        (ORI | OR)?`ALU_OR:
        (NOR)?`ALU_NOR:
        (XORI | XOR)?`ALU_XOR:
        (SLL | SLLV)?`ALU_SLL:
        (SRA | SRAV)?`ALU_SRA:
        (SRL | SRLV)?`ALU_SRL:
        (SLTI | SLT)?`ALU_LT:
        (SLTIU | SLTU)?`ALU_LTU:
        (CLO)?`ALU_CLO:
        (CLZ)?`ALU_CLZ:
        4'bxxxx;

    assign ALUASrc = (SLL | SRA | SRL);

    assign ALUSrc=(
        LUI | LW | SW | LH | LHU | SH | LB | LBU | SB | ORI | ANDI | ADDIU | XORI | 
        SLTI | SLTIU | ADDI | LWL | LWR | SWL | SWR
        );

    assign RegDst = (R_Type | CLO | CLZ | MUL);

    assign RegWrite=(
        ADDU | SLL | SLLV | SRL | SRLV | SUBU | SRA | SRAV | JALR | AND | OR | XOR | NOR | SLT | SLTU | 
        MOVZ | MOVN | MFHI | MFLO | ADD | SUB | LW |  JAL | LUI | ANDI | ORI | LH | LHU | LB | LBU | 
        ADDIU | XORI | SLTI | SLTIU | ADDI | LWL | LWR | cpztoReg | CLO | CLZ | MUL
        );

    assign Extend = (
        LW | SW | BEQ | LH | LHU | SH | LB | LBU | SB | ADDI | ADDIU | 
        SLTI | SLTIU | BNE | BGTZ | BLEZ | BGEZ | BGEZAL |
        BLTZ | BLTZAL | BEQL | BNEL | LWL | LWR | SWL | SWR
    );

    assign Jump = (JAL | J);

    assign Jump_R = (JR | JALR);

    assign Link = (JAL | JALR | BGEZAL | BLTZAL);

    assign DataType=(LW | SW)?4'b0000:
                    (LHU | SH)?4'b0010:
                    (LH)?4'b0011:
                    (LBU | SB)?4'b0100:
                    (LB)?4'b0101:
                    (LWL | SWL)?4'b0110:
                    (LWR | SWR)?4'b0111:
                                4'b1111;
    
    assign JudgeMove = (MOVZ | MOVN);

    assign Likely = (BEQL | BNEL);

    assign MDUOp = (MULTU)?`MDU_MULTU:
                   (MULT | MUL)?`MDU_MULT:
                   (DIVU)?`MDU_DIVU:
                   (DIV)?`MDU_DIV:
                   (MADDU)?`MDU_MADDU:
                   (MADD)?`MDU_MADD:
                   (MSUBU)?`MDU_MSUBU:
                   (MSUB)?`MDU_MSUB:
                            `MDU_DUM;
                   
    assign MTHILO = (MTLO)?2'b01:
                    (MTHI)?2'b11:
                    2'b00;
    assign MFHILO = (MFLO | MUL)?2'b01:
                    (MFHI)?2'b10:
                    2'b00;

    assign MDU_Result = (MUL);

    assign cpzWrite = (MTC0);
    assign cpztoReg = (MFC0);

    assign IgnoreExcRI = (ADDU | SUBU | ADDIU);

    assign Unknown = ~(
        ADD | ADDI | ADDU | ADDIU | AND | ANDI | SUB | SUBU | LUI | NOR | OR | ORI | XOR | XORI | CLO | CLZ |
        SLL | SLLV | SRA | SRAV | SRL | SRLV | SLT | SLTI | SLTIU | SLTU |
        BEQ | BNE | BGEZ | BLTZ | BGTZ | BLEZ | BLTZAL | BGEZAL | BEQL | BNEL |
        J | JAL | JALR | JR | 
        LB | LBU | LH | LHU | LW | LWL | LWR |
        SB | SH | SW | SWL | SWR |
        MOVZ | MOVN |
        MFC0 | MTC0 | BREAK | ERET | SYSCALL |
        MFHI | MFLO | MTHI | MTLO | MULT | MULTU | DIV | DIVU | MADD | MADDU | MSUB | MSUBU | MUL
    );

    assign ExcOccur = Unknown | SYSCALL | BREAK;

    

    assign ExcCode = ExcOccur?
                        (Unknown?`EXC_RI:
                         SYSCALL?`EXC_SYSCALL:
                         BREAK?`EXC_BP:
                         5'b00000):
                     5'b00000;

endmodule // ControlUnit
`endif