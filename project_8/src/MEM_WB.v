/*
 * name: MEM_WB
 * author: btapple
 * description: pipeline registers between MEM stage and WB stage.
 */

`ifndef __MEM_WB_V__
`define __MEM_WB_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module MEM_WB(
    input clk,
    input reset,
    input clr,
    input stall,

    input MemtoRegM,
    input RegWriteM,
    input [`Word] MemRDM,
    input [3:0] MemRDSelM,
    input [1:0] ByteSelM,
    input [`Word] RegDataM,
    input [4:0] RegAddrM,

    output reg MemtoRegW,
    output reg RegWriteW,
    output reg [`Word] MemRDW,
    output reg [3:0] MemRDSelW,
    output reg [1:0] ByteSelW,
    output reg [`Word] RegDataW,
    output reg [4:0] RegAddrW
);

    always @(posedge clk)
    begin
        if(reset)
            begin
                MemtoRegW<=0;
                RegWriteW<=0;
                MemRDW<=0;
                RegDataW<=0;
                RegAddrW<=0;
                MemRDSelW<=0;
                ByteSelW<=0;
            end
        else if(stall!=1)
            if(clr)
                begin
                    MemtoRegW<=0;
                    RegWriteW<=0;
                    MemRDW<=0;
                    RegDataW<=0;
                    RegAddrW<=0;
                    MemRDSelW<=0;
                    ByteSelW<=0;
                end
            else
                begin
                    MemtoRegW<=MemtoRegM;
                    RegWriteW<=RegWriteM;
                    MemRDW<=MemRDM;
                    RegDataW<=RegDataM;
                    RegAddrW<=RegAddrM;
                    MemRDSelW<=MemRDSelM;
                    ByteSelW<=ByteSelM;
                end
    end
endmodule // MEM_WB
`endif