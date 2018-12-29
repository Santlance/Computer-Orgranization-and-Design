/*
 * name: Branch
 * author: btapple
 * description: preparing the branch address for NPC
 */

`ifndef __BRANCH_V__
`define __BRANCH_V__
`include "./macro.vh"
`include "./ext.v"
`timescale 1ns / 1ps
module Branch(
    input Branch,
    input JudgeRes,
    input [`Inst_J] J_Index,
    input [`Word] PC4,
    input [`Half] Imm,
    output pc_branch,
    output [`Word] B_addr,
    output [`Word] J_addr,
    output [`Word] PC8
);
    
    wire [`Word] branch_imm;
    sign_extend #(18,32) imm_extenderD(
        .in({Imm,2'b00}),
        .out(branch_imm)
    );

    assign pc_branch = Branch & JudgeRes;
    assign B_addr = branch_imm + PC4;
    assign J_addr = {PC4[31:28],J_Index,2'b00};
    assign PC8 = PC4 + 4;
    
endmodule // Branch
`endif