/*
 * name: Program counter
 * author: btapple
 */

`ifndef __PC_V__
`define __PC_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module PC(
    input clk,
    input reset,
    input stall,
    input ERET,
    input ExcHandle,
    input [`Word] nPC,
    input [`Word] EPC,
    output [`Word] current_PC,

    output ExcOccur,
    output [4:0] ExcCode
);
    parameter INIT = 32'h0000_3000;
    reg [`Word] PC;

    initial
    begin
        PC<=INIT;
    end

    always @(posedge clk) 
    begin
        if(reset)
            PC<=INIT;
        else if(stall!=1)
            PC<=nPC;
    end
    
    assign current_PC = (ExcHandle)?`EXCEPTION_HANDLER_ADDR:
                        (ERET)?     EPC:
                                    PC;

    assign ExcOccur = (~(PC>=`TEXTADDR_BEGIN && PC<=`TEXTADDR_END) || (PC[1:0]!=2'b0))?1'b1:1'b0;
    assign ExcCode = (ExcOccur==1'b1)?`EXC_ADEL:
                     5'b0;

endmodule // PC
`endif