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

    wire [`Word] leading_zero_result;
    wire [`Word] leading_ones_result;

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
                `ALU_CLO : ALURes <= leading_ones_result;
                `ALU_CLZ : ALURes <= leading_zero_result;
                default  : ALURes <= SrcA;
            endcase
        end
    assign Zero=(ALURes==0)?1'b1:1'b0;

    leading_zero_counter _leading_zero_counter(
        .in(SrcA),
        .out(leading_zero_result)
    );

    leading_ones_counter _leading_ones_counter(
        .in(SrcA),
        .out(leading_ones_result)
    );

    wire ADD_SUB_Overflow = ((ALUCtrl==`ALU_ADD && ADD_Res_Temp[32]!=ADD_Res_Temp[31])||
                             (ALUCtrl==`ALU_SUB && SUB_Res_Temp[32]!=SUB_Res_Temp[31]))
                             ?1'b1:1'b0;
    assign ExcOccur = (~IgnoreExcRI && ADD_SUB_Overflow)?1'b1:1'b0;
    assign ExcCode = ExcOccur?`EXC_OV:5'b0;
endmodule //

module leading_zero_counter(
    input [`Word] in,
    output [`Word] out
);
    wire [5:0] result;
    wire [15:0] Val16;
    wire [7:0] Val8;
    wire [3:0] Val4;
    assign result[5] = (in==32'b0);
    assign result[4] = (in[31:16]==16'b0) & (~result[5]);
    assign Val16     = result[4]? in[15:0] : in[31:16];
    assign result[3] = (Val16[15:8]==8'b0) & (~result[5]);
    assign Val8      = result[3]? Val16[7:0] : Val16[15:8];
    assign result[2] = (Val8[7:4]==4'b0) & (~result[5]);
    assign Val4      = result[2]? Val8[3:0] : Val8[7:4];
    assign result[1] = (Val4[3:2]==2'b0) & (~result[5]);
    assign result[0] = result[1]? (~Val4[1]&~result[5]) : (~Val4[3]&~result[5]);

    assign out={26'b0,result};
endmodule // leading_zero_counter

module leading_ones_counter(
    input [`Word] in,
    output [`Word] out
);
    wire [5:0] result;
    wire [15:0] Val16;
    wire [7:0] Val8;
    wire [3:0] Val4;
    assign result[5] = (in==32'hffff_ffff);
    assign result[4] = (in[31:16]==16'hffff) & (~result[5]);
    assign Val16     = result[4]? in[15:0] : in[31:16];
    assign result[3] = (Val16[15:8]==8'hff) & (~result[5]);
    assign Val8      = result[3]? Val16[7:0] : Val16[15:8];
    assign result[2] = (Val8[7:4]==4'hf) & (~result[5]);
    assign Val4      = result[2]? Val8[3:0] : Val8[7:4];
    assign result[1] = (Val4[3:2]==2'b11) & (~result[5]);
    assign result[0] = result[1]? (Val4[1]&~result[5]) : (Val4[3]&~result[5]);

    assign out={26'b0,result};
endmodule // leading_ones_counter
`endif
