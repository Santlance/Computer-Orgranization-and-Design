`ifndef __IM_V__
`define __IM_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module IM(
    input [`Word] addr,
    output [`Word] Inst
);
    reg [`Word] im_16k[4095:0];
    initial
        begin
            $readmemh("code.txt",im_16k);
            //$readmemh("../code.txt",im_4k,32'h0000_0C00);   // 32'h0000_3000 >> 2
        end
    assign Inst=im_16k[addr[13:2]-32'h0000_0C00];      // 1024
endmodule // IM
`endif