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
    assign JudgeRes=(JudgeOp==`EQ && SrcA==SrcB)?1'b1:
                    (JudgeOp==`NE && SrcA!=SrcB)?1'b1:
                    (JudgeOp==`GTZ && $signed(SrcA)>0)?1'b1:
                    (JudgeOp==`LEZ && $signed(SrcA)<=0)?1'b1:
                    (JudgeOp==`GEZ && $signed(SrcA)>=0)?1'b1:
                    (JudgeOp==`LTZ && $signed(SrcA)<0)?1'b1:
                    1'b0;
endmodule // Judge
`endif