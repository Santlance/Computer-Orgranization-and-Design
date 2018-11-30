`ifndef __IM_V__
`define __IM_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module IM(
    input [`Word] addr,
    output [`Word] Inst
);
    reg [`Word] im_8k[2047:0];
    wire [`Word] _addr=addr-'h0000_3000;
    initial
        begin
            $readmemh("code.txt",im_8k,0,1119);
            $readmemh("exc.txt",im_8k,1120,2047);
        end
    assign Inst=im_8k[_addr[13:2]];      // 1024
endmodule // IM
`endif