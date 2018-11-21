`ifndef __BRANCH_V__
`define __BRANCH_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module Branch(
    input [`Word] SrcA,
    input [`Word] SrcB,
    input Branch,
    input [3:0] BranchOp,
    output pc_branch
);
    assign pc_branch =(Branch==0)?1'b0:
                      (BranchOp==`B_EQ && SrcA==SrcB)?1'b1:
                      (BranchOp==`B_NE && SrcA!=SrcB)?1'b1:
                      (BranchOp==`B_GTZ && SrcA>0)?1'b1:
                      (BranchOp==`B_LEZ && SrcA<=0)?1'b1:
                      (BranchOp==`B_GEZ && SrcA>=0)?1'b1:
                      (BranchOp==`B_LTZ && SrcA<0)?1'b1:1'b0;
endmodule // Branch
`endif