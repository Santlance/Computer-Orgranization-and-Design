/*
 * name: LED
 * author: btapple
 * description: 32bit-LED
 */
`ifndef __LED_V__
`define __LED_V__
`include "../macro.vh"
`timescale 1ns / 1ps
module LED(
    input clk,
    input reset,
    input we,
    input [31:0] wd,
    output [31:0] RD,
    output [31:0] led
);
    reg [31:0] data;

    assign RD = (reset==1'b1)?0:
                data;
    
    assign led = data;

    always @(posedge clk)
    begin
        if(reset)
            data<=0;
        else if(we)
            data<=wd;
    end
endmodule // LED
`endif