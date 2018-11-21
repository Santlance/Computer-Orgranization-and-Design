`ifndef __NPC_V__
`define __NPC_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module NPC(
    input clk,
    input branch,
    input jump,
    input jump_r,
    input [`Word] PC,
    input [`Word] imm,  // sign_ext(offset,00)
    input [`Inst_J] J_Index,
    input [`Word] RD,
    output [`Word] PC4,
    output [`Word] nPC
);
    assign PC4=PC+4;
    wire [`Word]j_addr={PC4[31:28],J_Index,2'b00};
    wire [`Word]b_addr=PC4+imm;
    assign nPC=(branch==1)?b_addr:
               (jump==1)?j_addr:
               (jump_r==1)?RD:PC4;
endmodule // NPC
`endif