/*
 * name: IF_ID
 * author: btapple
 * description: pipeline registers between IF stage and ID stage.
 */

`ifndef __IF_ID_V__
`define __IF_ID_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module IF_ID(
    input clk,
    input reset,
    input clr,
    input stall,
    input [`Word] InstF,
    input [`Word] PC4F,
    input ExcBDF,
    input ExcOccurF,
    input [4:0] ExcCodeF,

    output reg [`Word] InstD,
    output reg [`Word] PC4D,
    output reg ExcBDD,
    output reg ExcOccurD,
    output reg [4:0] ExcCodeD

    // input [`Word] PCF,
    // output reg [`Word] PCD
);
    
    always @(posedge clk)
    begin
        if(reset)
            begin
                InstD<=0;
                PC4D<=0;
                // PCD<=0;
                ExcBDD<=0;
                ExcOccurD<=0;
                ExcCodeD<=0;
            end
        else if(clr)
            begin
                InstD<=0;
                ExcBDD<=0;
                ExcOccurD<=0;
                ExcCodeD<=0;
            end
        else if(~stall)
            begin
                InstD<=InstF;
                PC4D<=PC4F;
                // PCD<=PCF;
                ExcBDD<=ExcBDF;
                ExcOccurD<=ExcOccurF;
                ExcCodeD<=ExcCodeF;
            end
        end
endmodule // IF_ID
`endif