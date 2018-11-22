`ifndef __INST_V__
`define __INST_V__
`include "./macro.vh"
`timescale 1ns / 1ps

module Inst_Filter(
    input [`Word] inst,
    output [`Inst_OP]op,
    output [`Inst_RS]rs,
    output [`Inst_RT]rt,
    output [`Inst_RD]rd,
    output [`Inst_Imm]imm,
    output [`Inst_S]shamt,
    output [`Inst_Funct]funct,
    output [`Inst_J]j_index
);
    assign op=inst[`Inst_OP];
    assign rs=inst[`Inst_RS];
    assign rt=inst[`Inst_RT];
    assign rd=inst[`Inst_RD];
    assign imm=inst[`Inst_Imm];
    assign shamt=inst[`Inst_S];
    assign funct=inst[`Inst_Funct];
    assign j_index=inst[`Inst_J];
endmodule // Inst
`endif