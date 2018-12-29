/*
 * name: IM
 * author: btapple
 * description: instruction memory.
 */

`ifndef __IM_V__
`define __IM_V__
// `define DEBUG
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module IM(
    input clk,
    input [15:0] addr_in,
    output [`Word] Inst
);
`ifndef DEBUG
    wire [`Word] addr = addr_in - 32'h0000_3000;
    Instruction_Memory _im(
        .clka(clk),     // input clka
        .wea(4'b0),      // input [3 : 0] wea
        .addra(addr_in[14:2]), // input [12 : 0] addra
        .dina(32'b0), // input [31 : 0] dina
        .douta(Inst) // output [31 : 0] douta
    );
`endif
`ifdef DEBUG
    always @(posedge clk)
    begin
        $display("%d@%h",$time,Inst);
    end
    integer i;
    reg [`Word] im_16k[4095:0];
    initial
        begin
            for(i=0;i<4096;i=i+1)
                im_16k[i]=0;
            $readmemh("code.txt",im_16k);
            $readmemh("code_handler.txt",im_16k,1120,2047);
        end
    assign Inst=im_16k[addr_in[15:2]];
`endif
endmodule
`endif