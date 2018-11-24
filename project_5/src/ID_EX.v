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
    input BranchD,
    input [3:0] BranchOpD,
    input [3:0] ALUCtrlD,
    input ALUASrcD,
    input ALUSrcD,
    input RegDstD,
    input RegWriteD,
    input ExtendD,
    input JumpD,
    input Jump_RD,
    input LinkD,
    input [2:0] DataTypeD,
    input [`Word] RD1D,
    input [`Word] RD2D,
    input [4:0] RsD,
    input [4:0] RtD,
    input [4:0] RdD,
    input [`Word] Imm_ExtendD,
    input [`Word] Shamt_ExtendD,
    input [`Word] PC8D,

    output reg MemtoRegE,
    output reg MemWriteE,
    output reg [3:0] ALUCtrlE,
    output reg ALUASrcE,
    output reg ALUSrcE,
    output reg RegWriteE,
    output reg RegDstE,
    output reg ExtendE,
    output reg JumpE,
    output reg Jump_RE,
    output reg LinkE,
    output reg [2:0] DataTypeE,
    output reg [`Word] RD1E,
    output reg [`Word] RD2E,
    output reg [4:0] RsE,
    output reg [4:0] RtE,
    output reg [4:0] RdE,
    output reg [`Word] Imm_ExtendE,
    output reg [`Word] Shamt_ExtendE,
    output reg [`Word] PC8E,

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
        JumpE<=0;
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
                JumpE<=0;
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
                    JumpE<=0;
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
                    JumpE<=JumpD;
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
                    PCE<=PCD;
                end
endmodule //ID_EX
`endif