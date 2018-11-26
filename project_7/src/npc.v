`ifndef __NPC_V__
`define __NPC_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module NPC(
    input clk,
    input Branch,
    input Jump,
    input Jump_r,
    input [`Word] PC,
    input [`Word] B_addr,
    input [`Word] J_addr,
    input [`Word] RD,
    output [`Word] PC4,
    output [`Word] nPC
);
    assign PC4=PC+4;
    assign nPC=(Branch==1)?B_addr:
               (Jump==1)?J_addr:
               (Jump_r==1)?RD:PC4;
endmodule // NPC
`endif