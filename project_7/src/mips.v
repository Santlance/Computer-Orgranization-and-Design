/*
 * name: mips
 * author: btapple
 * description: top module
 */

`ifndef __MIPS_V__
`define __MIPS_V__
`include "./macro.vh"
`include "./core.v"
`include "./bridge.v"
`include "./memory.v"
`include "./TC.v"
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
    wire [5:0] HWInt;
    wire MEMWE,Dev0WE,Dev1WE;
    wire [`Word] MEMRD,Dev0RD,Dev1RD;
    wire Dev0Irq,Dev1Irq;

    Core _core(
        .clk(clk),
        .reset(reset),
        .PrRD(PrRD),
        .HWInt(HWInt),
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
        .MEMWE(MEMWE), .Dev0WE(Dev0WE), .Dev1WE(Dev1WE),
        .MEMRD(MEMRD), .Dev0RD(Dev0RD), .Dev1RD(Dev1RD),
        .PrRD(PrRD),
        .Dev0Irq(Dev0Irq), .Dev1Irq(Dev1Irq),
        .HWInt(HWInt),
        .PrPC(PrPC),
        .PC(PC)
    );

    memory _memory(
        .clk(clk_re),
        .reset(reset),
        .we(MEMWE),
        .be(BE),
        .addr_in(Addr),
        .wd(WD),
        .PC(PC),
        .rd(MEMRD)
    );

    TC #(`DEV0ADDR_BEGIN) _dev0
    (
        .clk(clk_re),
        .reset(reset),
        .addr(Addr),
        .we(Dev0WE),
        .wd(WD),
        .RD(Dev0RD),
        .IRQ(Dev0Irq),
        .PC(PC)
    );

    TC #(`DEV1ADDR_BEGIN) _dev1
    (
        .clk(clk_re),
        .reset(reset),
        .addr(Addr),
        .we(Dev1WE),
        .wd(WD),
        .RD(Dev1RD),
        .IRQ(Dev1Irq),
        .PC(PC)
    );

endmodule // mips
`endif