/*
 * name: ALU
 * author: btapple
 * description: 64 dipswitches
 */
`ifndef __DIP_SWITCH_V__
`define __DIP_SWITCH_V__
`include "../macro.vh"
`timescale 1ns / 1ps
module Dipswitch #(parameter base=`DEV2ADDR_BEGIN)
(
    input reset,
    input Addr,
    input [7:0] dip_switch0,
    input [7:0] dip_switch1,
    input [7:0] dip_switch2,
    input [7:0] dip_switch3,
    input [7:0] dip_switch4,
    input [7:0] dip_switch5,
    input [7:0] dip_switch6,
    input [7:0] dip_switch7,
    output [31:0] RD
);

    assign RD = (reset==1'b1)?32'b0:
                (Addr)? {dip_switch3,dip_switch2,dip_switch1,dip_switch0}:
                        {dip_switch7,dip_switch6,dip_switch5,dip_switch4};

endmodule // Dipswitch
`endif