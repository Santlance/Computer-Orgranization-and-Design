`ifndef __MEM_WB_V__
`define __MEM_WB_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module MEM_WB(
    input clk,
    input reset,
    input clr,
    input en,

    input MemtoRegM,
    input RegWriteM,
    input [`Word] MemRDM,
    input [`Word] ALUResM,
    input [4:0] RegAddrM,

    output reg MemtoRegW,
    output reg RegWriteW,
    output reg [`Word] MemRDW,
    output reg [`Word] ALUResW,
    output reg [4:0] RegAddrW
);
    initial
    begin
        MemtoRegW<=0;
        RegWriteW<=0;
        MemRDW<=0;
        ALUResW<=0;
        RegAddrW<=0;
    end
    always @(posedge clk)
    begin
        if(reset)
            begin
                MemtoRegW<=0;
                RegWriteW<=0;
                MemRDW<=0;
                ALUResW<=0;
                RegAddrW<=0;
            end
        else if(en!=1)
            if(clr)
                begin
                    MemtoRegW<=0;
                    RegWriteW<=0;
                    MemRDW<=0;
                    ALUResW<=0;
                    RegAddrW<=0;
                end
            else
                begin
                    MemtoRegW<=MemtoRegM;
                    RegWriteW<=RegWriteM;
                    MemRDW<=MemRDM;
                    ALUResW<=ALUResM;
                    RegAddrW<=RegAddrM;
                end
    end
endmodule // MEM_WB
`endif