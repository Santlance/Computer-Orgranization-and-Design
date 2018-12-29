/*
 * name: Judge
 * author: btapple
 * description: comparator
 */

`ifndef __JUDGE_V__
`define __JUDGE_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module Judge(
    input [`Word] SrcA,
    input [`Word] SrcB,
    input [3:0] JudgeOp,
    output JudgeRes
);
    assign JudgeRes = (JudgeOp==`EQ && SrcA==SrcB)?1'b1:
                      (JudgeOp==`NE && SrcA!=SrcB)?1'b1:
                      (JudgeOp==`GTZ && ~SrcA[31] && | SrcA)?1'b1:
                      (JudgeOp==`LEZ && (~SrcA[31] || ~(|SrcA)))?1'b1:
                      (JudgeOp==`GEZ && ~SrcA[31])?1'b1:
                      (JudgeOp==`LTZ && SrcA[31])?1'b1:
                      1'b0;
endmodule // Judge
`endif