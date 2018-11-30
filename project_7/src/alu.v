// Description: 32bit_ALU
`ifndef __ALU_V__
`define __ALU_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module ALU(
    input [`Word] SrcA,
    input [`Word] SrcB,
    input [3:0] ALUCtrl,
    input IgnoreExcRI,
    output reg [`Word] ALURes,
    output ExcOccur,
    output [4:0] ExcCode,
    output Zero
);

    wire [32:0] ADD_Res_Temp = {SrcA[31],SrcA} + {SrcB[31],SrcB};
    wire [32:0] SUB_Res_Temp = {SrcA[31],SrcA} - {SrcB[31],SrcB};
    
    always @( * )
        begin
            case (ALUCtrl)
                `ALU_ADD : ALURes <= ADD_Res_Temp[31:0];             // ADD
                `ALU_SUB : ALURes <= SUB_Res_Temp[31:0];             // SUB
                `ALU_AND : ALURes <= SrcA & SrcB;                    // AND
                `ALU_OR  : ALURes <= SrcA | SrcB;                    // OR
                `ALU_XOR : ALURes <= SrcA ^ SrcB;                    // XOR
                `ALU_NOR : ALURes <= ~(SrcA | SrcB);                 // NOR
                `ALU_SLL : ALURes <= SrcB << SrcA [`Low5];           // SLL
                `ALU_SRA : ALURes <= $signed(SrcB) >>> SrcA[`Low5];  // SRA
                `ALU_SRL : ALURes <= SrcB >> SrcA[`Low5];            // SRL
                `ALU_LUI : ALURes <= {SrcB[`Half0], 16'b0};          // LUI
                `ALU_LT  : ALURes <= $signed(SrcA) < $signed(SrcB);  // Less than, signed
                `ALU_LTU : ALURes <= {1'b0,SrcA} < {1'b0,SrcB};            // Less than, unsigned
                default  : ALURes <= SrcA;
            endcase
        end
    assign Zero=(ALURes==0)?1'b1:1'b0;

    wire ADD_SUB_Overflow = ((ALUCtrl==`ALU_ADD && ADD_Res_Temp[32]!=ADD_Res_Temp[31])||
                             (ALUCtrl==`ALU_SUB && SUB_Res_Temp[32]!=SUB_Res_Temp[31]))
                             ?1'b1:1'b0;
    assign ExcOccur = (~IgnoreExcRI && ADD_SUB_Overflow)?1'b1:1'b0;
    assign ExcCode = ExcOccur?`EXC_OV:5'b0;
endmodule //
`endif