`ifndef __EX_MEM_V__
`define __EX_MEM_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module EX_MEM(
    input clk,
    input reset,
    input clr,
    input en,

    input MemtoRegE,
    input MemWriteE,
    input RegWriteE,
    input [4:0] RegAddrE,
    input [`Word] WriteDataE,
    input [3:0] DataTypeE,
    input [`Word] ALUResE,
    input [3:0] MDUOpE,

    output reg [4:0] RegAddrM,
    output reg [`Word] WriteDataM,
    output reg [`Word] ALUResM,
    output reg MemtoRegM,
    output reg MemWriteM,
    output reg [3:0] DataTypeM,
    output reg RegWriteM,
    output reg [3:0] MDUOpM,

    input ExcBDE,
    output reg ExcBDM,
    input ExcOccurE,
    input [4:0] ExcCodeE,
    output reg ExcOccurM,
    output reg [4:0] ExcCodeM,

    input [`Word] PC4E,
    output reg [`Word] PC4M,
    input [`Word] PCE,
    output reg [`Word] PCM
);
    initial
    begin
        RegAddrM<=0;
        WriteDataM<=0;
        ALUResM<=0;
        MemtoRegM<=0;
        MemWriteM<=0;
        RegWriteM<=0;
        DataTypeM<=0;
        ExcBDM<=0;
        ExcOccurM<=0;
        ExcCodeM<=0;
        MDUOpM<=0;

        PC4M<=0;
        PCM<=0;
    end
    always @(posedge clk)
    begin
        if(reset)
            begin
                RegAddrM<=0;
                WriteDataM<=0;
                ALUResM<=0;
                MemtoRegM<=0;
                MemWriteM<=0;
                RegWriteM<=0;
                DataTypeM<=0;
                ExcBDM<=0;
                ExcOccurM<=0;
                ExcCodeM<=0;
                MDUOpM<=0;

                PC4M<=0;
                PCM<=0;
            end
        else if(en!=1)
            if(clr)
                begin
                    RegAddrM<=0;
                    WriteDataM<=0;
                    ALUResM<=0;
                    MemtoRegM<=0;
                    MemWriteM<=0;
                    RegWriteM<=0;
                    DataTypeM<=0;
                    ExcBDM<=0;
                    ExcOccurM<=0;
                    ExcCodeM<=0;
                    MDUOpM<=0;

                    PC4M<=0;
                    PCM<=0;
                end
            else
                begin
                    RegAddrM<=RegAddrE;
                    WriteDataM<=WriteDataE;
                    ALUResM<=ALUResE;
                    MemtoRegM<=MemtoRegE;
                    MemWriteM<=MemWriteE;
                    RegWriteM<=RegWriteE;
                    DataTypeM<=DataTypeE;
                    ExcBDM<=ExcBDE;
                    ExcOccurM<=ExcOccurE;
                    ExcCodeM<=ExcCodeE;
                    MDUOpM<=MDUOpE;

                    PC4M<=PC4E;
                    PCM<=PCE;
                end
    end
endmodule // EX_MEM
`endif
