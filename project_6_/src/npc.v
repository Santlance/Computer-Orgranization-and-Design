`ifndef __NPC_V__
`define __NPC_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module NPC(
    input clk,
    input Branch,
    input Jump,
    input Jump_r,
    input ExcOccur,
    input ERET,
    input [`Word] PC,
    input [`Word] B_addr,
    input [`Word] J_addr,
    input [`Word] RD,
    input [`Word] EPC,
    output [`Word] PC4,
    output [`Word] nPC,
    output ExcBD
);
    assign PC4=PC+4;
    assign nPC=(ExcOccur==1)?`EXCEPTION_HANDLER_ADDR:
               (ERET==1)?EPC:
               (Branch==1)?B_addr:
               (Jump==1)?J_addr:
               (Jump_r==1)?RD:PC4;
    assign ExcBD=(Branch || Jump || Jump_r)?1'b1:1'b0;
endmodule // NPC
`endif