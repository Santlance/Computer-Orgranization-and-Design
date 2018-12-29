/*
 * name: MUX
 * author: btapple
 * description: some multiplexers.
 */

`ifndef __MUX_V__
`define __MUX_V__
`include "./macro.vh"
`timescale 1ns / 1ps

module Mux4 #(parameter WIDTH=8)
(
    input [WIDTH-1:0] a0,
    input [WIDTH-1:0] a1,
    input [WIDTH-1:0] a2,
    input [WIDTH-1:0] a3,
    input [1:0] select,
    output [WIDTH-1:0] out
);
    assign out= (select==0)? a0 :
                (select==1)? a1 :
                (select==2)? a2 :
                a3;
endmodule // mux4

module Mux2 #(parameter WIDTH=16)
(
    input [WIDTH-1:0] a0,
    input [WIDTH-1:0] a1,
    input select,
    output [WIDTH-1:0] out
);
    assign out= (select==0)?a0:a1;
endmodule // mux2

`endif