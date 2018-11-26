`ifndef __IM_V__
`define __IM_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module IM(
    input [`Word] addr,
    output [`Word] Inst
);
    reg [`Word] im_4k[1023:0];
    initial
        begin
            $readmemh("code.txt",im_4k);
            //$readmemh("../code.txt",im_4k,32'h0000_0C00);   // 32'h0000_3000 >> 2
        end
    assign Inst=im_4k[addr[11:2]];      // 1024
endmodule // IM
`endif