`ifndef __MIPS_V__
`define __MIPS_V__
`include "./macro.vh"
`include "./core.v"
`include "./bridge.v"
`include "./memory.v"
`timescale 1ns / 1ps

module mips(
    input clk,
    input reset
);
    wire clk_re = ~clk;

    wire [`Word] PrRD;
    wire [`Word] PrAddr,Addr;
    wire [`Word] PrWD,WD;
    wire [`Word] PrPC,PC;
    wire PrWE;
    wire [3:0] PrBE,BE;
    wire MEMWE;
    wire [`Word] MEMRD;

    Core _core(
        .clk(clk),
        .reset(reset),
        .PrRD(PrRD),
        .PrAddr(PrAddr),
        .PrWD(PrWD),
        .PrWE(PrWE),
        .PrBE(PrBE),
        .PrPC(PrPC)
    );

    Bridge _bridge(
        .PrAddr(PrAddr),
        .Addr(Addr),
        .PrWE(PrWE),
        .PrWD(PrWD),
        .WD(WD),
        .PrBE(PrBE),
        .BE(BE),
        .MEMWE(MEMWE),
        .MEMRD(MEMRD),
        .PrRD(PrRD),
        .PrPC(PrPC),
        .PC(PC)
    );

    memory #(12) _memoey
    (
        .clk(clk_re),
        .reset(reset),
        .we(MEMWE),
        .be(BE),
        .addr(Addr),
        .wd(WD),
        .PC(PC),
        .rd(MEMRD)
    );
endmodule // mips
`endif