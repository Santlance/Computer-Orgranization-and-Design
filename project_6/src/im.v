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
        end
    assign Inst=im_16k[addr[31:2]-32'h0000_0C00];      // 1024
endmodule // IM
`endif