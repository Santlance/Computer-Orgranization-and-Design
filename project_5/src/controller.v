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
    output [2:0] DataType
);
    wire [5:0] Op=inst[`Inst_OP];
    wire [4:0] Rt=inst[`Inst_RT];
    wire [5:0] Funct=inst[`Inst_Funct];

    wire R_Type=(Op==0)?1:0;
    
    assign MemtoReg=(Op==`LW||Op==`LH||Op==`LHU||Op==`LB||Op==`LBU)?1:0;
    assign MemWrite=(Op==`SW||Op==`SH||Op==`SB)?1:0;
    assign Branch=(Op==`BEQ ||
                   Op==`BNE ||
                   Op==`BGTZ ||
                   Op==`BLEZ ||
                   Op==`BGEZ_OP)?1:0;
    assign JudgeOp=(Op==`BEQ)?`EQ:
                    (Op==`BNE)?`NE:
                    (Op==`BGTZ)?`GTZ:
                    (Op==`BLEZ)?`LEZ:
                    (Op==`BGEZ_OP && Rt==`BGEZ_RT)?`GEZ:
                    (Op==`BLTZ_OP && Rt==`BLTZ_RT)?`LTZ:4'bxxxx;
    assign ALUCtrl=(
        (R_Type && Funct==`ADDU)||Op==`ADDIU||Op==`LW||Op==`SW||Op==`LH||Op==`LHU||Op==`SH||Op==`LB||Op==`LBU||Op==`SB
        )?`ALU_ADD:
        (R_Type && Funct==`SUBU)?`ALU_SUB:
        (Op==`LUI)?`ALU_LUI:
        (Op==`ANDI||(R_Type && Funct==`AND))?`ALU_AND:
        (Op==`ORI||(R_Type && Funct==`OR))?`ALU_OR:
        (Op==`XORI||(R_Type && Funct==`XOR))?`ALU_XOR:
        ((R_Type && Funct==`SLL)||(R_Type && Funct==`SLLV))?`ALU_SLL:
        ((R_Type && Funct==`SRA)||(R_Type && Funct==`SRAV))?`ALU_SRA:
        ((R_Type && Funct==`SRL)||(R_Type && Funct==`SRLV))?`ALU_SRL:
        (Op==`SLTI||(R_Type && Funct==`SLT))?`ALU_LT:
        (Op==`SLTIU||(R_Type && Funct==`SLTU))?`ALU_LTU:4'bxxxx;

    assign ALUASrc=((R_Type && Funct==`SLL)||(R_Type && Funct==`SRA)||(R_Type && Funct==`SRL))?1:0;

    assign ALUSrc=(
        Op==`LUI || Op==`LW || Op==`SW || Op==`LH || Op==`LHU || Op==`SH || Op==`LB || Op==`LBU || Op==`SB || Op==`ORI || Op==`ANDI || Op==`ADDIU || Op==`XORI || Op==`SLTI || Op==`SLTIU
        )?1:0;

    assign RegDst=R_Type;

    assign RegWrite=(
        (R_Type && Funct==`ADDU)||(R_Type && Funct==`SLL)||(R_Type && Funct==`SLLV)||
        (R_Type && Funct==`SRL)||(R_Type && Funct==`SRLV)||(R_Type && Funct==`SUBU)||
        (R_Type && Funct==`SRA)||(R_Type && Funct==`SRAV)||(R_Type && Funct==`JALR)||
        (R_Type && Funct==`AND)||(R_Type && Funct==`OR)||(R_Type && Funct==`XOR)||
        (R_Type && Funct==`SLT)||(R_Type && Funct==`SLTU)||
        Op==`LW||Op==`JAL||Op==`LUI||Op==`ANDI||Op==`ORI||Op==`LH||Op==`LHU||Op==`LB||Op==`LBU||Op==`ADDIU||Op==`XORI||Op==`SLTI||Op==`SLTIU
        )?1:0;

    assign Extend=(Op==`LW||Op==`SW||Op==`BEQ||Op==`LH||Op==`LHU||Op==`SH||Op==`LB||Op==`LBU||Op==`SB||
        Op==`ADDIU||Op==`SLTI||Op==`SLTIU||Op==`BNE||Op==`BGTZ||Op==`BLEZ||(Op==`BGEZ_OP && Rt==`BGEZ_RT)||
        (Op==`BLTZ_OP && Rt==`BLTZ_RT)
    )?1:0;

    assign Jump=(Op==`JAL||Op==`J)?1:0;

    assign Jump_R=((R_Type && Funct==`JR)||(R_Type && Funct==`JALR))?1:0;

    assign Link=(Op==`JAL||(R_Type && Funct==`JALR))?1:0;

    assign DataType=(Op==`LW || Op==`SW)?3'b000:
                    (Op==`LHU||Op==`SH)?3'b010:
                    (Op==`LH)?3'b011:
                    (Op==`LBU || Op==`SB)?3'b100:
                    (Op==`LB)?3'b101:3'bxxx;
endmodule // ControlUnit
`endif