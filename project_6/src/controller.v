`ifndef __CONTROLLER_V__
`define __CONTROLLER_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module ControlUnit(
    input [`Word] inst,
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
    output [2:0] DataType,
    output JudgeMove,
    output Likely,
    output [2:0] MulOp,
    output [1:0] MTHILO,
    output [1:0] MFHILO
);
    wire [5:0] Op=inst[`Inst_OP];
    wire [4:0] Rt=inst[`Inst_RT];
    wire [5:0] Funct=inst[`Inst_Funct];

    wire R_Type=(Op==0)?1'b1:1'b0;
    
    assign MemtoReg=(Op==`LW||Op==`LH||Op==`LHU||Op==`LB||Op==`LBU||Op==`LWL||Op==`LWR)?1'b1:1'b0;
    assign MemWrite=(Op==`SW||Op==`SH||Op==`SB||Op==`SWL||Op==`SWR)?1'b1:1'b0;
    assign Branch=(Op==`BEQ || Op==`BEQL ||
                   Op==`BNE || Op==`BNEL ||
                   Op==`BGTZ ||
                   Op==`BLEZ ||
                   Op==`BGEZ_OP)?1'b1:1'b0;
    assign JudgeOp=(Op==`BEQ ||(R_Type && Funct==`MOVZ) || (Op==`BEQL))?`EQ:
                    (Op==`BNE ||(R_Type && Funct==`MOVN) || Op==`BNEL)?`NE:
                    (Op==`BGTZ)?`GTZ:
                    (Op==`BLEZ)?`LEZ:
                    (Op==`BGEZ_OP && Rt==`BGEZ_RT)?`GEZ:
                    (Op==`BLTZ_OP && Rt==`BLTZ_RT)?`LTZ:4'bxxxx;
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
        (Op==`SLTIU||(R_Type && Funct==`SLTU))?`ALU_LTU:4'bxxxx;

    assign ALUASrc=((R_Type && Funct==`SLL)||(R_Type && Funct==`SRA)||(R_Type && Funct==`SRL))?1'b1:1'b0;

    assign ALUSrc=(
        Op==`LUI || Op==`LW || Op==`SW || Op==`LH || Op==`LHU || Op==`SH || Op==`LB || Op==`LBU || Op==`SB || Op==`ORI || Op==`ANDI || Op==`ADDIU || Op==`ADDI || Op==`XORI || Op==`SLTI || Op==`SLTIU ||
        Op==`LWL || Op==`LWR || Op==`SWL || Op==`SWR
        )?1'b1:1'b0;

    assign RegDst=R_Type;

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
        Op==`LWL||Op==`LWR
        )?1'b1:1'b0;

    assign Extend=(Op==`LW||Op==`SW||Op==`BEQ||Op==`LH||Op==`LHU||Op==`SH||Op==`LB||Op==`LBU||Op==`SB||Op==`ADDI||
        Op==`ADDIU||Op==`SLTI||Op==`SLTIU||Op==`BNE||Op==`BGTZ||Op==`BLEZ||(Op==`BGEZ_OP && Rt==`BGEZ_RT)||
        (Op==`BLTZ_OP && Rt==`BLTZ_RT)||Op==`BEQL||Op==`BNEL||Op==`LWL||Op==`LWR||Op==`SWL||Op==`SWR
    )?1'b1:1'b0;

    assign Jump=(Op==`JAL||Op==`J)?1'b1:1'b0;

    assign Jump_R=((R_Type && Funct==`JR)||(R_Type && Funct==`JALR))?1'b1:1'b0;

    assign Link=(Op==`JAL||(R_Type && Funct==`JALR))?1'b1:1'b0;

    assign DataType=(Op==`LW || Op==`SW)?3'b000:
                    (Op==`LHU||Op==`SH)?3'b010:
                    (Op==`LH)?3'b011:
                    (Op==`LBU || Op==`SB)?3'b100:
                    (Op==`LB)?3'b101:
                    (Op==`LWL||Op==`SWL)?3'b110:
                    (Op==`LWR||Op==`SWR)?3'b111:3'bxxx;
    
    assign JudgeMove = ((R_Type && Funct==`MOVZ)||(R_Type && Funct==`MOVN))?1'b1:1'b0;

    assign Likely = (Op==`BEQL || Op==`BNEL)?1'b1:1'b0;

    assign MulOp = (R_Type && Funct==`MULTU)?3'b000:
                   (R_Type && Funct==`MULT)?3'b001:
                   (R_Type && Funct==`DIVU)?3'b010:
                   (R_Type && Funct==`DIV)?3'b011:
                   3'b100;
    assign MTHILO = (R_Type && Funct==`MTLO)?2'b00:
                    (R_Type && Funct==`MTHI)?2'b01:
                    2'b10;
    assign MFHILO = (R_Type && Funct==`MFLO)?2'b01:
                    (R_Type && Funct==`MFHI)?2'b10:
                    2'b00;
endmodule // ControlUnit
`endif