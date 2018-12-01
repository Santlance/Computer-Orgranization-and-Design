`ifndef __MIPS_V__
`define __MIPS_V__
`include "./cpu.v"
`include "./memory.v"
`include "./TC.v"
`timescale 1ns / 1ps

module mips(
    input clk,
    input reset
);
    wire [`Word] PrRD;
    wire [`Word] PrAddr;
    wire [`Word] PrWD;
    wire [`Word] PrPC;
    wire PrWE;
    wire [3:0] PrDataType,MEMDataType;
    wire [5:0] HWInt;
    wire MEMWE,Dev0WE,Dev1WE;
    wire [`Word] MEMRD,Dev0RD,Dev1RD;
    wire Dev0Irq,Dev1Irq;
    cpu _cpu(
        .clk(clk),
        .reset(reset),
        .PrRD(PrRD),
        .HWInt(HWInt),
        .PrAddr(PrAddr),
        .PrWD(PrWD),
        .PrWE(PrWE),
        .PrDataType(PrDataType),
        .PrPC(PrPC)
    );

    Bridge _bridge(
        .PrAddr(PrAddr),
        .PrWE(PrWE),
        .PrWD(PrWD),
        .PrDataType(PrDataType),
        .MEMDataType(MEMDataType),
        .MEMWE(MEMWE), .Dev0WE(Dev0WE), .Dev1WE(Dev1WE),
        .MEMRD(MEMRD), .Dev0RD(Dev0RD), .Dev1RD(Dev1RD),
        .PrRD(PrRD),
        .Dev0Irq(Dev0Irq), .Dev1Irq(Dev1Irq),
        .HWInt(HWInt)
    );

    memory #(12) _memoey
    (
        .clk(clk),
        .reset(reset),
        .we(MEMWE),
        .type(MEMDataType),
        .addr_in(PrAddr),
        .wd(PrWD),
        .PC(PrPC),
        .rd(MEMRD)
    );

    TC #(`DEV0ADDR_BEGIN) _dev0
    (
        .clk(clk),
        .reset(reset),
        .Addr(PrAddr),
        .we(Dev0WE),
        .wd(PrWD),
        .RD(Dev0RD),
        .IRQ(Dev0Irq)
    );

    TC #(`DEV1ADDR_BEGIN) _dev1
    (
        .clk(clk),
        .reset(reset),
        .Addr(PrAddr),
        .we(Dev1WE),
        .wd(PrWD),
        .RD(Dev1RD),
        .IRQ(Dev1Irq)
    );

endmodule // mips
`endif