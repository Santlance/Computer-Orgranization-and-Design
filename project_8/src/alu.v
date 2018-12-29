/*
 * name: ALU
 * author: btapple
 * description: 32bit-ALU
 */

`ifndef __ALU_V__
`define __ALU_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module ALU(
    input [`Word] SrcA,
    input [`Word] SrcB,
    input [3:0] ALUCtrl,
    input IgnoreExcRI,
    output [`Word] ALURes,
    output ExcOccur
);

    // wire [`Word] leading_zero_result;
    // wire [`Word] leading_ones_result;

    wire [32:0] ADD_Res_Temp = {SrcA[31],SrcA} + {SrcB[31],SrcB};
    wire [32:0] SUB_Res_Temp = {SrcA[31],SrcA} - {SrcB[31],SrcB};

    wire [`Word] ADD_Result = {32{~(|(ALUCtrl ^ `ALU_ADD))}} & ADD_Res_Temp[31:0];
    wire [`Word] SUB_Result = {32{~(|(ALUCtrl ^ `ALU_SUB))}} & SUB_Res_Temp[31:0];
    wire [`Word] AND_Result = {32{~(|(ALUCtrl ^ `ALU_AND))}} & (SrcA & SrcB);
    wire [`Word] OR_Result  = {32{~(|(ALUCtrl ^ `ALU_OR ))}} & (SrcA | SrcB);
    wire [`Word] XOR_Result = {32{~(|(ALUCtrl ^ `ALU_XOR))}} & (SrcA ^ SrcB);
    wire [`Word] NOR_Result = {32{~(|(ALUCtrl ^ `ALU_NOR))}} & (~ (SrcA | SrcB));
    wire [`Word] SLL_Result = {32{~(|(ALUCtrl ^ `ALU_SLL))}} & (SrcB << SrcA[`Low5]);
    wire [`Word] SRA_Result = {32{~(|(ALUCtrl ^ `ALU_SRA))}} & ($signed(SrcB) >>> SrcA[`Low5]);
    wire [`Word] SRL_Result = {32{~(|(ALUCtrl ^ `ALU_SRL))}} & (SrcB >> SrcA[`Low5]);
    wire [`Word] LUI_Result = {32{~(|(ALUCtrl ^ `ALU_LUI))}} & ({SrcB[`Half0],16'b0});
    wire [`Word] LT_Result  = ~(|(ALUCtrl ^ `ALU_LT )) & (SUB_Res_Temp[32]);
    wire [`Word] LTU_Result = ~(|(ALUCtrl ^ `ALU_LTU)) & (SUB_Res_Temp[31]);
    wire [`Word] DUM_Result = {32{~(|(ALUCtrl ^ `ALU_DUM))}} & SrcA;
    assign ALURes = ADD_Result |
                    SUB_Result |
                    AND_Result |
                    OR_Result  |
                    XOR_Result |
                    NOR_Result |
                    SLL_Result |
                    SRA_Result |
                    SRL_Result |
                    LUI_Result |
                    LT_Result  |
                    LTU_Result |
                    DUM_Result;

    // always @( * )
    //     begin
    //         case (ALUCtrl)
    //             `ALU_ADD : ALURes <= ADD_Result;                             // ADD
    //             `ALU_SUB : ALURes <= SUB_Result;                             // SUB
    //             `ALU_AND : ALURes <= AND_Result;                             // AND
    //             `ALU_OR  : ALURes <= OR_Result ;                             // OR
    //             `ALU_XOR : ALURes <= XOR_Result;                             // XOR
    //             `ALU_NOR : ALURes <= NOR_Result;                             // NOR
    //             `ALU_SLL : ALURes <= SLL_Result;                             // SLL
    //             `ALU_SRA : ALURes <= SRA_Result;                             // SRA
    //             `ALU_SRL : ALURes <= SRL_Result;                             // SRL
    //             `ALU_LUI : ALURes <= LUI_Result;                             // LUI
    //             `ALU_LT  : ALURes <= LT_Result ;                             // Less than, signed
    //             `ALU_LTU : ALURes <= LTU_Result;                             // Less than, unsigned
    //             // `ALU_CLO : ALURes <= leading_ones_result;                                       // Counting leading ones
    //             // `ALU_CLZ : ALURes <= leading_zero_result;                                       // Counting leading zeros
    //             default  : ALURes <= SrcA;
    //         endcase
    //     end

    // leading_zero_counter _leading_zero_counter(
    //     .in(SrcA),
    //     .out(leading_zero_result)
    // );

    // leading_ones_counter _leading_ones_counter(
    //     .in(SrcA),
    //     .out(leading_ones_result)
    // );

    wire ADD_SUB_Overflow = ((~(|(ALUCtrl ^ `ALU_ADD))) & (ADD_Res_Temp[32] ^ ADD_Res_Temp[31])) |
                            ((~(|(ALUCtrl ^ `ALU_SUB))) & (SUB_Res_Temp[32] ^ SUB_Res_Temp[31])) ;
    assign ExcOccur = ~IgnoreExcRI & ADD_SUB_Overflow;
endmodule //

// module leading_zero_counter(
//     input [`Word] in,
//     output [`Word] out
// );
//     wire [5:0] result;
//     wire [15:0] Val16;
//     wire [7:0] Val8;
//     wire [3:0] Val4;
//     assign result[5] = (in==32'b0);
//     assign result[4] = (in[31:16]==16'b0) & (~result[5]);
//     assign Val16     = result[4]? in[15:0] : in[31:16];
//     assign result[3] = (Val16[15:8]==8'b0) & (~result[5]);
//     assign Val8      = result[3]? Val16[7:0] : Val16[15:8];
//     assign result[2] = (Val8[7:4]==4'b0) & (~result[5]);
//     assign Val4      = result[2]? Val8[3:0] : Val8[7:4];
//     assign result[1] = (Val4[3:2]==2'b0) & (~result[5]);
//     assign result[0] = result[1]? (~Val4[1]&~result[5]) : (~Val4[3]&~result[5]);

//     assign out={26'b0,result};
// endmodule // leading_zero_counter

// module leading_ones_counter(
//     input [`Word] in,
//     output [`Word] out
// );
//     wire [5:0] result;
//     wire [15:0] Val16;
//     wire [7:0] Val8;
//     wire [3:0] Val4;
//     assign result[5] = (in==32'hffff_ffff);
//     assign result[4] = (in[31:16]==16'hffff) & (~result[5]);
//     assign Val16     = result[4]? in[15:0] : in[31:16];
//     assign result[3] = (Val16[15:8]==8'hff) & (~result[5]);
//     assign Val8      = result[3]? Val16[7:0] : Val16[15:8];
//     assign result[2] = (Val8[7:4]==4'hf) & (~result[5]);
//     assign Val4      = result[2]? Val8[3:0] : Val8[7:4];
//     assign result[1] = (Val4[3:2]==2'b11) & (~result[5]);
//     assign result[0] = result[1]? (Val4[1]&~result[5]) : (Val4[3]&~result[5]);

//     assign out={26'b0,result};
// endmodule // leading_ones_counter
`endif
