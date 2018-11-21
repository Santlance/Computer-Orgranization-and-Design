`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:47:35 10/25/2018 
// Design Name: 
// Module Name:    ext 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ext(
    input[15:0] imm,
    input[1:0] EOp,
    output reg[31:0] ext
    );
    parameter [15:0]zero = 0;
    parameter [15:0]one  = 16'b1111111111111111 ;
    always @(*) 
    begin
        case (EOp)
          0: ext=(imm[15]==1)?{one,imm}:{zero,imm};
          1: ext={zero,imm};
          2: ext={imm,zero};
          3: ext=(imm[15]==1)?{one,imm}<<2:{zero,imm}<<2;
          default: ext=0;
        endcase  
    end

endmodule
