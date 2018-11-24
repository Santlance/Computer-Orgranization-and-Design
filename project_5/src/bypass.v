`ifndef __BYPASS_V__
`define __BYPASS_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module BYPASS(
    input [4:0] RsD,
    input [4:0] RtD,
    input [4:0] RsE,
    input [4:0] RtE,
    input [4:0] RegAddrW,
    input [4:0] RegAddrM,
    input [4:0] RegAddrE,
    input RegWriteM,
    input RegWriteW,
    output Forward_A_D,
    output Forward_B_D,
    output [1:0] Forward_A_E,
    output [1:0] Forward_B_E,

    input MemtoRegE,
    output Stall_PC,
    output Stall_IF_ID,
    output Stall_ID_EX,
    output Stall_EX_MEM,
    output Stall_MEM_WB,
    output Flush_IF_ID,
    output Flush_ID_EX
);

    // ID forward
    assign Forward_A_D = (RsD!=5'b0 && RegWriteM && RegAddrM==RsD)?`FW_MD:`FW_NONED;
    assign Forward_B_D = (RtD!=5'b0 && RegWriteM && RegAddrM==RtD)?`FW_MD:`FW_NONED;
    
    // EXE forward
    assign Forward_A_E = (RsE==5'b0)?`FW_NONEE:
                         (RegWriteM && RsE==RegAddrM)?`FW_ME:
                         (RegWriteW && RsE==RegAddrW)?`FW_WE:
                         `FW_NONEE;
    assign Forward_B_E = (RtE==5'b0)?`FW_NONEE:
                         (RegWriteM && RtE==RegAddrM)?`FW_ME:
                         (RegWriteW && RtE==RegAddrW)?`FW_WE:
                         `FW_NONEE;
    wire Stall_Mem = (MemtoRegE) && (RsD==RegAddrE || RtD==RegAddrE);

    assign Stall_PC = Stall_Mem;
    assign Stall_IF_ID = Stall_Mem;
    assign Flush_ID_EX = Stall_Mem;
endmodule // BYPASS
`endif

// MOVEZ之类的也可以在这里解决