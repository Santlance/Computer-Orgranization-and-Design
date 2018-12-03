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
    input [3:0] MemRDSelM,
    input [1:0] ByteSelM,
    input [`Word] ALUResM,
    input [4:0] RegAddrM,

    output reg MemtoRegW,
    output reg RegWriteW,
    output reg [`Word] MemRDW,
    output reg [3:0] MemRDSelW,
    output reg [1:0] ByteSelW,
    output reg [`Word] ALUResW,
    output reg [4:0] RegAddrW,

    input [`Word] PCM,
    output reg [`Word] PCW
);
    initial
    begin
        MemtoRegW<=0;
        RegWriteW<=0;
        MemRDW<=0;
        ALUResW<=0;
        RegAddrW<=0;
        MemRDSelW<=0;
        ByteSelW<=0;
        PCW<=0;
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
                MemRDSelW<=0;
                ByteSelW<=0;
                PCW<=0;
            end
        else if(en!=1)
            if(clr)
                begin
                    MemtoRegW<=0;
                    RegWriteW<=0;
                    MemRDW<=0;
                    ALUResW<=0;
                    RegAddrW<=0;
                    MemRDSelW<=0;
                    ByteSelW<=0;
                    PCW<=0;
                end
            else
                begin
                    MemtoRegW<=MemtoRegM;
                    RegWriteW<=RegWriteM;
                    MemRDW<=MemRDM;
                    ALUResW<=ALUResM;
                    RegAddrW<=RegAddrM;
                    MemRDSelW<=MemRDSelM;
                    ByteSelW<=ByteSelM;
                    PCW<=PCM;
                end
    end
endmodule // MEM_WB
`endif