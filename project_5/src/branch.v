`ifndef __BRANCH_V__
`define __BRANCH_V__
`include "./macro.vh"
`include "./ext.v"
`timescale 1ns / 1ps
module Branch(
    input [`Word] SrcA,
    input [`Word] SrcB,
    input Branch,
    input [3:0] BranchOp,
    input [`Word] PC4,
    input [`Half] Imm,
    output pc_branch,
    output [`Word] B_addr,
    output [`Word] PC8
);
    wire [`Word] branch_imm;
    assign pc_branch =(Branch==0)?1'b0:
                      (BranchOp==`B_EQ && SrcA==SrcB)?1'b1:
                      (BranchOp==`B_NE && SrcA!=SrcB)?1'b1:
                      (BranchOp==`B_GTZ && $signed(SrcA)>0)?1'b1:
                      (BranchOp==`B_LEZ && $signed(SrcA)<=0)?1'b1:
                      (BranchOp==`B_GEZ && $signed(SrcA)>=0)?1'b1:
                      (BranchOp==`B_LTZ && $signed(SrcA)<0)?1'b1:1'b0;
    
    sign_extend #(18,32) imm_extenderD(
        .in({Imm,2'b00}),
        .out(branch_imm)
    );
    assign B_addr=branch_imm+PC4;
    assign PC8=PC4+4;
endmodule // Branch
`endif