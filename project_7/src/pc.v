`ifndef __PC_V__
`define __PC_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module PC(
    input clk,
    input reset,
    input we,
    input [`Word] nPC,
    output reg [`Word] PC,

    output ExcOccur,
    output [4:0] ExcCode
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
            else if(we!=1)
                begin
                    PC<=nPC;
                end
        end
    
    assign ExcOccur = (~(PC>=`TEXTADDR_BEGIN && PC<=`TEXTADDR_END) || (PC[1:0]!=2'b0))?1'b1:1'b0;
    assign ExcCode = (ExcOccur==1'b1)?`EXC_ADEL:
                     5'b0;

endmodule // PC
`endif