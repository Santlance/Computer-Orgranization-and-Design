`ifndef __NPC_V__
`define __NPC_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module NPC(
    input clk,
    input reset,
    input branch,
    input jump,
    input jump_r,
    input [`Word] PC,
    input [`Word] imm,  // sign_ext(offset,00)
    input [`Inst_J] J_Index,
    input [`Word] RD,
    output [`Word] PC4,
    output reg [`Word] nPC
);
    assign PC4=PC+4;
    wire [`Word]j_addr={PC4[31:28],J_Index,2'b00};
    wire [`Word]b_addr=PC4+imm;
    always @(clk) 
    begin
        if(reset)
            nPC<=32'h0000_3000;
        else if(branch)
            nPC<=b_addr;
        else if(jump)
            nPC<=j_addr;
        else if(jump_r)
            nPC<=RD;
        else nPC<=PC4;
    end
endmodule // NPC
`endif