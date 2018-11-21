`ifndef __PC_V__
`define __PC_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module PC(
    input clk,
    input reset,
    input PCWrite,
    input [`Word] nPC,
    output reg [`Word] PC
);
    parameter INIT =32'h0000_3000 ;
    initial
        begin
            PC<=INIT;
        end
    always @(posedge clk) 
        begin
            if(reset)
                begin
                    PC<=INIT;
                end
            else if(PCWrite)
                begin
                    PC<=nPC;
                end
        end
endmodule // PC
`endif