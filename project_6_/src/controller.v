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

    wire [5:0] Op=inst[`Inst_OP];
    wire [4:0] Rs=inst[`Inst_RS];
    wire [4:0] Rt=inst[`Inst_RT];
    wire [5:0] Funct=inst[`Inst_Funct];

    wire R_Type=(Op==0)?1'b1:1'b0;
    wire Unknown,syscall,break;

    assign MemtoReg=(Op==`LW||Op==`LH||Op==`LHU||Op==`LB||Op==`LBU||Op==`LWL||Op==`LWR)?1'b1:1'b0;
    assign MemWrite=(Op==`SW||Op==`SH||Op==`SB||Op==`SWL||Op==`SWR)?1'b1:1'b0;
    assign Branch=(Op==`BEQ || Op==`BEQL ||
                   Op==`BNE || Op==`BNEL ||
                   Op==`BGTZ ||
                   Op==`BLEZ ||
                   Op==`REGIMM && Rt==`BGEZ||
                   Op==`REGIMM && Rt==`BLTZ||
                   Op==`REGIMM && Rt==`BLTZAL||
                   Op==`REGIMM && Rt==`BGEZAL)?1'b1:1'b0;
    assign JudgeOp=(Op==`BEQ ||(R_Type && Funct==`MOVZ) || (Op==`BEQL))?`EQ:
                    (Op==`BNE ||(R_Type && Funct==`MOVN) || Op==`BNEL)?`NE:
                    (Op==`BGTZ)?`GTZ:
                    (Op==`BLEZ)?`LEZ:
                    (Op==`REGIMM && (Rt==`BGEZ || Rt==`BGEZAL))?`GEZ:
                    (Op==`REGIMM && (Rt==`BLTZ || Rt==`BLTZAL))?`LTZ:4'bxxxx;

    assign ALUCtrl=(
        (R_Type && (Funct==`ADDU||Funct==`ADD))||Op==`ADDIU||Op==`ADDI||Op==`LW||Op==`SW||Op==`LH||Op==`LHU||Op==`SH||Op==`LB||Op==`LBU||Op==`SB||
        Op==`LWL||Op==`LWR||Op==`SWL||Op==`SWR
        )?`ALU_ADD:
        (R_Type && (Funct==`SUBU||Funct==`SUB))?`ALU_SUB:
        (Op==`LUI)?`ALU_LUI:
        (Op==`ANDI||(R_Type && Funct==`AND))?`ALU_AND:
        (Op==`ORI||(R_Type && Funct==`OR))?`ALU_OR:
        (R_Type && Funct==`NOR)?`ALU_NOR:
        (Op==`XORI||(R_Type && Funct==`XOR))?`ALU_XOR:
        ((R_Type && Funct==`SLL)||(R_Type && Funct==`SLLV))?`ALU_SLL:
        ((R_Type && Funct==`SRA)||(R_Type && Funct==`SRAV))?`ALU_SRA:
        ((R_Type && Funct==`SRL)||(R_Type && Funct==`SRLV))?`ALU_SRL:
        (Op==`SLTI||(R_Type && Funct==`SLT))?`ALU_LT:
        (Op==`SLTIU||(R_Type && Funct==`SLTU))?`ALU_LTU:
        (Op==`SPE2 && Funct==`CLO)?`ALU_CLO:
        (Op==`SPE2 && Funct==`CLZ)?`ALU_CLZ:
        4'bxxxx;

    assign ALUASrc=((R_Type && Funct==`SLL)||(R_Type && Funct==`SRA)||(R_Type && Funct==`SRL))?1'b1:1'b0;

    assign ALUSrc=(
        Op==`LUI || Op==`LW || Op==`SW || Op==`LH || Op==`LHU || Op==`SH || Op==`LB || Op==`LBU || Op==`SB || Op==`ORI || Op==`ANDI || Op==`ADDIU || Op==`XORI || Op==`SLTI || Op==`SLTIU || Op==`ADDI ||
        Op==`LWL||Op==`LWR||Op==`SWL||Op==`SWR
        )?1'b1:1'b0;

    assign RegDst=R_Type || (Op==`SPE2 && Funct==`CLO) || (Op==`SPE2 && Funct==`CLZ) || (Op==`SPE2 && Funct==`MUL);

    assign RegWrite=(
        (R_Type && Funct==`ADDU)||(R_Type && Funct==`SLL)||(R_Type && Funct==`SLLV)||
        (R_Type && Funct==`SRL)||(R_Type && Funct==`SRLV)||(R_Type && Funct==`SUBU)||
        (R_Type && Funct==`SRA)||(R_Type && Funct==`SRAV)||(R_Type && Funct==`JALR)||
        (R_Type && Funct==`AND)||(R_Type && Funct==`OR)||(R_Type && Funct==`XOR)||
        (R_Type && Funct==`NOR)||(R_Type && Funct==`SLT)||(R_Type && Funct==`SLTU)||
        (R_Type && Funct==`MOVZ)||(R_Type && Funct==`MOVN)||
        (R_Type && Funct==`MFHI)||(R_Type && Funct==`MFLO)||
        (R_Type && Funct==`ADD)||(R_Type && Funct==`SUB)||
        Op==`LW||Op==`JAL||Op==`LUI||Op==`ANDI||Op==`ORI||Op==`LH||Op==`LHU||Op==`LB||Op==`LBU||Op==`ADDIU||Op==`XORI||Op==`SLTI||Op==`SLTIU||Op==`ADDI||
        Op==`LWL||Op==`LWR||cpztoReg||(Op==`SPE2 && Funct==`CLO)||(Op==`SPE2 && Funct==`CLZ)||(Op==`SPE2 && Funct==`MUL)
        )?1'b1:1'b0;

    assign Extend=(Op==`LW||Op==`SW||Op==`BEQ||Op==`LH||Op==`LHU||Op==`SH||Op==`LB||Op==`LBU||Op==`SB||Op==`ADDI||
        Op==`ADDIU||Op==`SLTI||Op==`SLTIU||Op==`BNE||Op==`BGTZ||Op==`BLEZ||(Op==`REGIMM && (Rt==`BGEZ || Rt==`BGEZAL))||
        (Op==`REGIMM && (Rt==`BLTZ||Rt==`BLTZAL))||Op==`BEQL||Op==`BNEL||Op==`LWL||Op==`LWR||Op==`SWL||Op==`SWR
    )?1'b1:1'b0;

    assign Jump=(Op==`JAL||Op==`J)?1'b1:1'b0;

    assign Jump_R=((R_Type && Funct==`JR)||(R_Type && Funct==`JALR))?1'b1:1'b0;

    assign Link=(Op==`JAL||(R_Type && Funct==`JALR))||(Op==`REGIMM && (Funct==`BGEZAL||Funct==`BLTZAL))?1'b1:1'b0;

    assign DataType=(Op==`LW || Op==`SW)?4'b0000:
                    (Op==`LHU||Op==`SH)?4'b0010:
                    (Op==`LH)?4'b0011:
                    (Op==`LBU || Op==`SB)?4'b0100:
                    (Op==`LB)?4'b0101:
                    (Op==`LWL||Op==`SWL)?4'b0110:
                    (Op==`LWR||Op==`SWR)?4'b0111:4'b1111;
    
    assign JudgeMove = ((R_Type && Funct==`MOVZ)||(R_Type && Funct==`MOVN))?1'b1:1'b0;

    assign Likely = (Op==`BEQL || Op==`BNEL)?1'b1:1'b0;

    assign MDUOp = (R_Type && Funct==`MULTU)?`MDU_MULTU:
                   ((R_Type && Funct==`MULT)||(Op==`SPE2 && Funct==`MUL))?`MDU_MULT:
                   (R_Type && Funct==`DIVU)?`MDU_DIVU:
                   (R_Type && Funct==`DIV)?`MDU_DIV:
                   (Op==`SPE2 && Funct==`MADDU)?`MDU_MADDU:
                   (Op==`SPE2 && Funct==`MADD)?`MDU_MADD:
                   (Op==`SPE2 && Funct==`MSUBU)?`MDU_MSUBU:
                   (Op==`SPE2 && Funct==`MSUB)?`MDU_MSUB:
                   `MDU_DUM;
                   
    assign MTHILO = (R_Type && Funct==`MTLO)?2'b01:
                    (R_Type && Funct==`MTHI)?2'b11:
                    2'b00;
    assign MFHILO = ((R_Type && Funct==`MFLO) ||(Op==`SPE2 && Funct==`MUL))?2'b01:
                    (R_Type && Funct==`MFHI)?2'b10:
                    2'b00;
    assign MDU_Result = (Op==`SPE2 && Funct==`MUL)?1'b1:1'b0;

    assign cpzWrite = (Op==`COP0 && Rs==`MTC0 && inst[10:0]==`SFC0)?1'b1:1'b0;
    assign cpztoReg = (Op==`COP0 && Rs==`MFC0 && inst[10:0]==`SFC0)?1'b1:1'b0;

    assign IgnoreExcRI = ((R_Type && (Funct==`ADDU || Funct==`SUBU)) || 
                          Op==`ADDIU)?1'b1:1'b0;

    assign ERET = (Op==`OP_ERET&&Funct==`F_ERET&&inst[25:6]==`I_ERET)?1'b1:1'b0;
    assign syscall = (R_Type && Funct==`SYSCALL)?1'b1:1'b0;
    assign break = (R_Type && Funct==`BREAK)?1'b1:1'b0;

    Unknown_Check _unknown_check(
        .inst(inst_in),
        .Unknown(Unknown)
    );

    assign ExcOccur = Unknown | syscall | break;
    assign ExcCode = ExcOccur?
                        (Unknown?`EXC_RI:
                         syscall?`EXC_SYSCALL:
                         break?`EXC_BP:
                         5'b00000):
                     5'b00000;

endmodule // ControlUnit
`endif

module Unknown_Check(
    input [`Word] inst,
    output Unknown
);
    wire [5:0] Op=inst[`Inst_OP];
    wire [5:0] Rs=inst[`Inst_RS];
    wire [4:0] Rt=inst[`Inst_RT];
    wire [5:0] Funct=inst[`Inst_Funct];
    wire R_Type=(Op==0)?1'b1:1'b0;
    
    assign Unknown = (
        (R_Type && 
            (Funct==`ADD||Funct==`ADDU||Funct==`AND||Funct==`NOR||Funct==`OR||Funct==`SLL||Funct==`SLLV||
             Funct==`SLT||Funct==`SLTU||Funct==`SRA||Funct==`SRAV||Funct==`SRL||Funct==`SRLV||Funct==`SUB||
             Funct==`SUBU||Funct==`XOR||Funct==`MOVZ||Funct==`MOVN||Funct==`MULT||Funct==`MULTU||Funct==`DIV||
             Funct==`DIVU||Funct==`MFHI||Funct==`MFLO||Funct==`MTHI||Funct==`MTLO||Funct==`BREAK||Funct==`SYSCALL||
             Funct==`JALR||Funct==`JR
             ))||
        (Op==`LB||Op==`LBU||Op==`LH||Op==`LHU||Op==`LW||Op==`SB||Op==`SH||Op==`SW||
         Op==`BEQ||Op==`BNE||Op==`BGTZ||Op==`BLEZ||Op==`BEQL||Op==`BNEL||(Op==`REGIMM &&(Rt==`BGEZ||Rt==`BLTZ))||
         Op==`J||Op==`JAL||Op==`ADDI||Op==`ADDIU||Op==`ANDI||Op==`LUI||Op==`ORI||Op==`SLTI||Op==`SLTIU||Op==`XORI||
         Op==`SWL||Op==`SWR||Op==`LWL||Op==`LWR||
         (Op==`OP_ERET&&Funct==`F_ERET&&inst[25:6]==`I_ERET)||
         (Op==`COP0 && Rs==`MTC0 && inst[10:0]==`SFC0)||
         (Op==`COP0 && Rs==`MFC0 && inst[10:0]==`SFC0)
         )
    )?1'b0:1'b1;
endmodule // Unknown_Check