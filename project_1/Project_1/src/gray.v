`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:48:46 10/25/2018 
// Design Name: 
// Module Name:    gray 
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
module gray(
  input Clk,
  input Reset,
  input En,
  output [2:0]Output,
  output reg Overflow
  );
  reg [2:0]temp;

  initial
  begin
    temp=0;
    Overflow=0;
  end
  assign Output=(temp>>1)^temp;

  always @(posedge Clk) 
  begin
    if(Reset==1)
      begin
        temp<=0;
        Overflow<=0;
      end
    else if(En==1)
      begin
        if(temp==7)
          begin
            temp<=0;
            Overflow<=1;
          end
        else
            temp<=temp+1;
      end
  end
endmodule