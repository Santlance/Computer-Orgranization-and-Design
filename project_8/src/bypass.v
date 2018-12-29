/*
 * name: Bypass
 * author: btapple
 * description: outside the pipelines, dealing with the forwarding, stalling and flushing, 
 *              and transmitting some controlling signals.
 */

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
    input RegWriteE,
    input RegWriteM,
    input RegWriteW,
    input MemtoRegE,
    input MemtoRegM,
    input [3:0] JudgeOpD,
    input Jump_R,
    input cpztoRegE,
    input cpztoRegM,
    // input branchD,
    // input LikelyD,
    // input [3:0] MDUOpD,
    // input [1:0] MTHILOD,
    // input [1:0] MFHILOD,
    // input [3:0] MDUOpM,
    // input MDUBusyE,
    input cpzWriteE,
    // input MDU_ResultE,
    // input [1:0] MDU_Result_Stall,
    output [1:0] Forward_A_D,
    output [1:0] Forward_B_D,
    output [1:0] Forward_A_E,
    output [1:0] Forward_B_E,
    output Forward_EPC,
    input ExcHandle,
    input ERETD,
    output pc_Exc,
    output pc_ERET,

    // output MDUCLR,

    output Stall_PC,
    output Stall_IF_ID,
    output Stall_ID_EX,
    output Stall_EX_MEM,
    output Stall_MEM_WB,
    output Flush_IF_ID,
    output Flush_ID_EX,
    output Flush_EX_MEM,
    output Flush_MEM_WB
);

    // ID forward
    assign Forward_A_D = (~(|RsD))?`FW_NONED:
                         (RegWriteM & ~(|(RsD ^ RegAddrM)))?`FW_MD:
                         (RegWriteW & ~(|(RsD ^ RegAddrW)))?`FW_WD:
                         `FW_NONED;
    assign Forward_B_D = (~(|RtD))?`FW_NONED:
                         (RegWriteM & ~(|(RtD ^ RegAddrM)))?`FW_MD:
                         (RegWriteW & ~(|(RtD ^ RegAddrW)))?`FW_WD:
                         `FW_NONED;

    // EXE forward
    assign Forward_A_E = (~(|RsE))?`FW_NONEE:
                         (RegWriteM & ~(|(RsE ^ RegAddrM)))?`FW_ME:
                         (RegWriteW & ~(|(RsE ^ RegAddrW)))?`FW_WE:
                         `FW_NONEE;
    
    assign Forward_B_E = (~(|RtE))?`FW_NONEE:
                         (RegWriteM & ~(|(RtE ^ RegAddrM)))?`FW_ME:
                         (RegWriteW & ~(|(RtE ^ RegAddrW)))?`FW_WE:
                         `FW_NONEE;

    // MEM Stall
    wire Stall_Mem = ((MemtoRegE | cpztoRegE) && (~(|(RsD ^ RegAddrE)) || ~(|(RtD ^ RegAddrE)))) ||
                     ((MemtoRegM | cpztoRegM) && ( |(JudgeOpD ^ `JUDGE_DUM) || Jump_R) && (~(|(RsD ^ RegAddrM)) || ~(|(RtD ^ RegAddrM))));

    // EX Stall
    wire Stall_EX = (RegWriteE && ((|(JudgeOpD ^ `JUDGE_DUM )) || Jump_R) && (~(|(RegAddrE ^ RsD)) || ~(|(RegAddrE  ^ RtD))));

    // ERET stall (due to MTC0)

    assign Forward_EPC = (cpzWriteE && ~(|(RegAddrE ^ `EPC_ID)));

    // Multiply Stall
    // wire MDUOp = (MDUOpD!=`MDU_DUM)?1'b1:1'b0;
    // wire MTHILO = (MTHILOD!=2'b10)?1'b1:1'b0;
    // wire MFHILO = (MFHILOD!=2'b00)?1'b1:1'b0;

    // wire Stall_MDU = (MDUBusyE && (MDUOp || MTHILO || MFHILO))?1'b1:1'b0;

    // wire Stall_MDU_Result = (MDU_ResultE && ~MDU_Result_Stall[1])?1'b1:1'b0;
    // wire Stall_MDU_Result = 0;

    // Exception NPC select
    assign pc_ERET = ERETD;
    assign pc_Exc = ExcHandle;

    // assign MDUCLR = ExcHandle && (MDUOpM != `MDU_DUM);

    // assign Stall_PC = ((Stall_Mem || Stall_MDU || Stall_MDU_Result) && ~ExcHandle)?1'b1:1'b0;
    assign Stall_PC = ((Stall_Mem || Stall_EX) && ~ExcHandle)?1'b1:1'b0;
    // assign Stall_IF_ID = ((Stall_Mem || Stall_MDU || Stall_MDU_Result) && ~ExcHandle) ?1'b1:1'b0;
    assign Stall_IF_ID = ((Stall_Mem || Stall_EX) && ~ExcHandle) ?1'b1:1'b0;
    // assign Stall_ID_EX = (Stall_MDU_Result)?1'b1:1'b0;
    assign Stall_ID_EX = 1'b0;
    assign Stall_EX_MEM = 1'b0;
    assign Stall_MEM_WB = 1'b0;
    // assign Flush_IF_ID = (LikelyD && ~branchD)?1'b1:1'b0;
    assign Flush_IF_ID = 1'b0;
    // assign Flush_ID_EX = (Stall_Mem || Stall_MDU || ExcHandle)?1'b1:1'b0;
    assign Flush_ID_EX = (Stall_Mem || Stall_EX || ExcHandle)?1'b1:1'b0;
    // assign Flush_EX_MEM = (ExcHandle || (MDU_ResultE && ~MDU_Result_Stall[0]))?1'b1:1'b0;
    assign Flush_EX_MEM = (ExcHandle)?1'b1:1'b0;
    assign Flush_MEM_WB = (ExcHandle)?1'b1:1'b0;
endmodule // BYPASS
`endif