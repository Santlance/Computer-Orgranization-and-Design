`ifndef __BRIDGE_V__
`define __BRIDGE_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module Bridge(
    input [`Word] PrAddr,
    input PrWE,
    inout [`Word] PrWD,

    input Dev0Irq,
    input Dev1Irq,
    input Dev2Irq,
    input Dev3Irq,
    input Dev4Irq,
    input Dev5Irq,
    output [5:0] HWInt,

    output Dev0WE,
    output Dev1WE,

    input [`Word] Dev0RD,
    input [`Word] Dev1RD,
    input [`Word] Dev2RD,
    input [`Word] Dev3RD,
    input [`Word] Dev4RD,
    input [`Word] Dev5RD,
    output [`Word] PrRD
);
    wire Dev0HIT = (PrAddr>=`DEV0ADDR_BEGIN) && (PrAddr<=`DEV0ADDR_END);
    wire Dev1HIT = (PrAddr>=`DEV1ADDR_BEGIN) && (PrAddr<=`DEV1ADDR_END);
    assign Dev0WE = PrWE & Dev0HIT;
    assign Dev1WE = PrWE & Dev1HIT;
    assign PrRD = (Dev0HIT)?Dev0RD:
                  (Dev1HIT)?Dev1RD:
                  0;
    assign HWInt = {4'b0,Dev1Irq,Dev0Irq};
endmodule // Bridge
`endif