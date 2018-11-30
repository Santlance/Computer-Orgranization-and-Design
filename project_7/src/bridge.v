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


    input [`Word] Dev0RD,
    input [`Word] Dev1RD,
    input [`Word] Dev2RD,
    input [`Word] Dev3RD,
    input [`Word] Dev4RD,
    input [`Word] Dev5RD,
    output [`Word] PrRD

);
    assign Dev0HIT=(PrAddr>=`Dev0Addr);
    
endmodule // Bridge
`endif