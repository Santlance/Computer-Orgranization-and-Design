/*
 * name: NPC
 * author: btapple
 * description: caculating the next PC.
 */

`ifndef __NPC_V__
`define __NPC_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module NPC(
    input Branch,
    input Jump,
    input Jump_r,
    input ExcHandle,
    input [`Word] PC,
    input [`Word] B_addr,
    input [`Word] J_addr,
    input [`Word] RD,
    output [`Word] PC4,
    output [`Word] nPC,
    output ExcBD
);
    assign PC4 = PC + 4;

    assign nPC = (ExcHandle==1)?PC4:
                 (Branch==1)?B_addr:
                 (Jump==1)?J_addr:
                 (Jump_r==1)?RD:PC4;

    assign ExcBD = (Branch || Jump || Jump_r)?1'b1:1'b0;
endmodule // NPC
`endif