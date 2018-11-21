`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:28:32 10/25/2018 
// Design Name: 
// Module Name:    string 
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
module string(
  input clk,
  input clr,
  input [7:0]in,
  output reg out
  );
  reg [1:0]temp;
  parameter [1:0]S0 = 0;
  parameter [1:0]S1 = 1;
  parameter [1:0]S2 = 2;
  parameter [1:0]S3 = 3;
  initial
  begin
    temp<=0;
  end
  always @(posedge clk or posedge clr) 
  begin
    if(clr)
      begin
        temp<=0;
        out<=0;
      end
    else
      begin
        if(temp==S0)
          begin
              if(in>="0"&&in<="9")
                begin
                  temp<=S1;
                  out<=1;
                end
              else
                begin
                  temp<=S3;
                  out<=0;
                end
          end
        else if(temp==S1)
          begin
            if(in>="0"&&in<="9")
              begin
                temp<=S3;
                out<=0;
              end
            else
              begin
                temp<=S2;
                out<=0;
              end
          end
        else if(temp==S2)
          begin
            if(in>="0"&&in<="9")
              begin
                temp<=S1;
                out<=1;
              end
            else 
              begin
                temp<=S3;
                out<=0;
              end
          end
      end
  end

endmodule
