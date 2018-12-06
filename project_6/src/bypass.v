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
    input MemtoRegE,
    input branchD,
    input LikelyD,
    input [3:0] MDUOpD,
    input [1:0] MTHILOD,
    input [1:0] MFHILOD,
    input MDUBusyE,
    input MDU_ResultE,
    input [1:0] MDU_Result_Stall,
    output [1:0] Forward_A_D,
    output [1:0] Forward_B_D,
    output [1:0] Forward_A_E,
    output [1:0] Forward_B_E,

    output Stall_PC,
    output Stall_IF_ID,
    output Stall_ID_EX,
    output Stall_EX_MEM,
    output Stall_MEM_WB,
    output Flush_IF_ID,
    output Flush_ID_EX,
    output Flush_EX_MEM
);

    // ID forward
    assign Forward_A_D = (RsD==5'b0)?`FW_NONED:
                         (RegWriteM && RsD==RegAddrM)?`FW_MD:
                         (RegWriteW && RsD==RegAddrW)?`FW_WD:
                         `FW_NONED;
    assign Forward_B_D = (RtD==5'b0)?`FW_NONED:
                         (RegWriteM && RtD==RegAddrM)?`FW_MD:
                         (RegWriteW && RtD==RegAddrW)?`FW_WD:
                         `FW_NONED;

    // EXE forward
    assign Forward_A_E = (RsE==5'b0)?`FW_NONEE:
                         (RegWriteM && RsE==RegAddrM)?`FW_ME:
                         (RegWriteW && RsE==RegAddrW)?`FW_WE:
                         `FW_NONEE;
    assign Forward_B_E = (RtE==5'b0)?`FW_NONEE:
                         (RegWriteM && RtE==RegAddrM)?`FW_ME:
                         (RegWriteW && RtE==RegAddrW)?`FW_WE:
                         `FW_NONEE;

    // Load Stall
    wire Stall_Mem = (MemtoRegE) && (RsD==RegAddrE || RtD==RegAddrE);

    // Multiply Stall
    wire MDUOp = (MDUOpD!=`MDU_DUM)?1'b1:1'b0;
    wire MTHILO = (MTHILOD!=2'b10)?1'b1:1'b0;
    wire MFHILO = (MFHILOD!=2'b00)?1'b1:1'b0;
    wire Stall_MDU = (MDUBusyE && (MDUOp || MTHILO || MFHILO))?1'b1:1'b0;
    wire Stall_MDU_Result = (MDU_ResultE && ~MDU_Result_Stall[1])?1'b1:1'b0;

    assign Stall_PC = (Stall_Mem || Stall_MDU || Stall_MDU_Result)?1'b1:1'b0;
    assign Stall_IF_ID = (Stall_Mem || Stall_MDU || Stall_MDU_Result)?1'b1:1'b0;
    assign Stall_ID_EX = (Stall_MDU_Result)?1'b1:1'b0;
    assign Flush_ID_EX = (Stall_Mem || Stall_MDU)?1'b1:1'b0;
    assign Flush_IF_ID = (LikelyD && ~branchD)?1'b1:1'b0;
    assign Flush_EX_MEM = (MDU_ResultE && ~MDU_Result_Stall[0])?1'b1:1'b0;
endmodule // BYPASS
`endif