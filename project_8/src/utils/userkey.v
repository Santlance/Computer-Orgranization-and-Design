/*
 * name: userkey
 * author: btapple
 * description: 8 general user keys and 1 reset key
 */
`ifndef __USERKEY_V__
`define __USERKEY_V__
`include "../macro.vh"
`timescale 1ns / 1ps
module Userkey(
    input sys_rstn,
    input [7:0] user_key,
    output reset,
    output [31:0] RD
);
    assign reset = ~sys_rstn;
    assign RD = (reset==1'b1)? 32'b0:
                               {24'b0,user_key};
endmodule // Userkey
`endif