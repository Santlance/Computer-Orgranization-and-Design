`ifndef __DM_V__
`define __DM_V__
`include "./macro.vh"
`include "./mux.v"
`include "./ext.v"
`timescale 1ns / 1ps
module DM #(parameter WIDTH = 12)
(
    input clk,
    input reset,
    input we,
    input [3:0]type,
    input [`Word] addr_in,
    input [`Word] wd,
    input [`Word] PC,
    input [`Word] PrRD,
    output [`Word] rd,
    output [2:0] rd_extend_type,
    output [1:0] byte_select,

    output [`Word] PrAddr,
    output [`Word] PrWD,
    output PrWE,
    output [3:0] data_type,
    output [`Word] PrPC,

    input Before_ExcOccur,
    output ExcOccur,
    output [4:0]ExcCode
);
    
    // Exception
    assign ExcOccur = (
        (type==4'b0000 && byte_select!=2'b00)||
        ((type==4'b0010 || type==4'b0011)&&byte_select[0]!=1'b0)||
        (type!=4'b1111 && ~((addr_in>=`DATAADDR_BEGIN && addr_in<=`DATAADDR_END)||
                            (addr_in>=`DEV0ADDR_BEGIN && addr_in<=`DEV0ADDR_END)||
                            (addr_in>=`DEV1ADDR_BEGIN && addr_in<=`DEV1ADDR_END)))
    )?1:0;

    assign ExcCode = ExcOccur?(we?`EXC_ADES:`EXC_ADEL):5'b00000;

    assign PrWE = we & ~ExcOccur & ~Before_ExcOccur;

    assign rd_extend_type=(type==4'b0010)?3'b001:(type==4'b0011)?3'b010:
                          (type==4'b0100)?3'b011:(type==4'b0101)?3'b100:
                          3'b000;

    assign PrAddr=addr_in;
    assign PrWD=wd;
    assign byte_select = addr_in[1:0];
    assign data_type=type;
    assign rd=PrRD;
    assign PrPC=PC;
endmodule // 
`endif