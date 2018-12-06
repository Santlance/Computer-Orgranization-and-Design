/*
 * 译码取数与执行之间的模块
 */
`ifndef __ID_EX_V__
`define __ID_EX_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module ID_EX(
    input clk,
    input reset,
    input clr,
    input en,

    input MemtoRegD,
    input MemWriteD,
    input [3:0] ALUCtrlD,
    input ALUASrcD,
    input ALUSrcD,
    input RegDstD,
    input RegWriteD,
    input ExtendD,
    input Jump_RD,
    input LinkD,
    input [3:0] DataTypeD,
    input [`Word] RD1D,
    input [`Word] RD2D,
    input [4:0] RsD,
    input [4:0] RtD,
    input [4:0] RdD,
    input [`Word] Imm_ExtendD,
    input [`Word] Shamt_ExtendD,
    input [`Word] PC8D,
    input [3:0] MDUOpD,
    input [1:0] MTHILOD,
    input [1:0] MFHILOD,
    input MDU_ResultD,
    input IgnoreExcRID,
    input cpzWriteD,
    input cpztoRegD,
    input ExcBDD,

    output reg MemtoRegE,
    output reg MemWriteE,
    output reg [3:0] ALUCtrlE,
    output reg ALUASrcE,
    output reg ALUSrcE,
    output reg RegWriteE,
    output reg RegDstE,
    output reg ExtendE,
    output reg Jump_RE,
    output reg LinkE,
    output reg [3:0] DataTypeE,
    output reg [`Word] RD1E,
    output reg [`Word] RD2E,
    output reg [4:0] RsE,
    output reg [4:0] RtE,
    output reg [4:0] RdE,
    output reg [`Word] Imm_ExtendE,
    output reg [`Word] Shamt_ExtendE,
    output reg [`Word] PC8E,
    output reg [3:0] MDUOpE,
    output reg [1:0] MTHILOE,
    output reg [1:0] MFHILOE,
    output reg MDU_ResultE,
    output reg IgnoreExcRIE,
    output reg cpzWriteE,
    output reg cpztoRegE,
    output reg ExcBDE,

    input ExcOccurD,
    input [4:0] ExcCodeD,
    output reg ExcOccurE,
    output reg [4:0] ExcCodeE,

    input [`Word] PC4D,
    output reg [`Word] PC4E,
    input [`Word] PCD,
    output reg [`Word] PCE              // for test
);
    initial
    begin
        MemtoRegE<=0;
        MemWriteE<=0;
        ALUCtrlE<=0;
        ALUASrcE<=0;
        ALUSrcE<=0;
        RegWriteE<=0;
        RegDstE<=0;
        ExtendE<=0;
        Jump_RE<=0;
        LinkE<=0;
        DataTypeE<=0;
        RD1E<=0;
        RD2E<=0;
        RsE<=0;
        RtE<=0;
        RdE<=0;
        Imm_ExtendE<=0;
        Shamt_ExtendE<=0;
        PC8E<=0;
        MDUOpE<=`MDU_DUM;
        MTHILOE<=0;
        MFHILOE<=0;
        MDU_ResultE<=0;
        IgnoreExcRIE<=0;
        cpzWriteE<=0;
        cpztoRegE<=0;
        ExcBDE<=0;
        ExcOccurE<=0;
        ExcCodeE<=0;

        PC4E<=0;
        PCE<=0;
    end
    always @(posedge clk)
        if(reset)
            begin
                MemtoRegE<=0;
                MemWriteE<=0;
                ALUCtrlE<=0;
                ALUASrcE<=0;
                ALUSrcE<=0;
                RegWriteE<=0;
                RegDstE<=0;
                ExtendE<=0;
                Jump_RE<=0;
                LinkE<=0;
                DataTypeE<=0;
                RD1E<=0;
                RD2E<=0;
                RsE<=0;
                RtE<=0;
                RdE<=0;
                Imm_ExtendE<=0;
                Shamt_ExtendE<=0;
                PC8E<=0;
                MDUOpE<=`MDU_DUM;
                MTHILOE<=0;
                MFHILOE<=0;
                MDU_ResultE<=0;
                IgnoreExcRIE<=0;
                cpzWriteE<=0;
                cpztoRegE<=0;
                ExcBDE<=0;
                ExcOccurE<=0;
                ExcCodeE<=0;

                PC4E<=0;
                PCE<=0;
            end
        else if(en!=1)
            if(clr)
                begin
                    MemtoRegE<=0;
                    MemWriteE<=0;
                    ALUCtrlE<=0;
                    ALUASrcE<=0;
                    ALUSrcE<=0;
                    RegWriteE<=0;
                    RegDstE<=0;
                    ExtendE<=0;
                    Jump_RE<=0;
                    LinkE<=0;
                    DataTypeE<=0;
                    RD1E<=0;
                    RD2E<=0;
                    RsE<=0;
                    RtE<=0;
                    RdE<=0;
                    Imm_ExtendE<=0;
                    Shamt_ExtendE<=0;
                    PC8E<=0;
                    MDUOpE<=`MDU_DUM;
                    MTHILOE<=0;
                    MFHILOE<=0;
                    MDU_ResultE<=0;
                    IgnoreExcRIE<=0;
                    cpzWriteE<=0;
                    cpztoRegE<=0;
                    ExcBDE<=0;
                    ExcOccurE<=0;
                    ExcCodeE<=0;

                    PC4E<=0;
                    PCE<=0;
                end
            else
                begin
                    MemtoRegE<=MemtoRegD;
                    MemWriteE<=MemWriteD;
                    ALUCtrlE<=ALUCtrlD;
                    ALUASrcE<=ALUASrcD;
                    ALUSrcE<=ALUSrcD;
                    RegWriteE<=RegWriteD;
                    RegDstE<=RegDstD;
                    ExtendE<=ExtendD;
                    Jump_RE<=Jump_RD;
                    LinkE<=LinkD;
                    DataTypeE<=DataTypeD;
                    RD1E<=RD1D;
                    RD2E<=RD2D;
                    RsE<=RsD;
                    RtE<=RtD;
                    RdE<=RdD;
                    Imm_ExtendE<=Imm_ExtendD;
                    Shamt_ExtendE<=Shamt_ExtendD;
                    PC8E<=PC8D;
                    MDUOpE<=MDUOpD;
                    MTHILOE<=MTHILOD;
                    MFHILOE<=MFHILOD;
                    MDU_ResultE<=MDU_ResultD;
                    IgnoreExcRIE<=IgnoreExcRID;
                    cpzWriteE<=cpzWriteD;
                    cpztoRegE<=cpztoRegD;
                    ExcBDE<=ExcBDD;
                    ExcOccurE<=ExcOccurD;
                    ExcCodeE<=ExcCodeD;

                    PC4E<=PC4D;
                    PCE<=PCD;
                end
endmodule //ID_EX
`endif