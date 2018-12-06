`ifndef __BRIDGE_V__
`define __BRIDGE_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module Bridge(
    input [`Word] PrAddr,
    input PrWE,
    input [3:0] PrBE,
    input [`Word] PrWD,
    
    output [`Word] Addr,
    output [3:0] BE,
    output [`Word] WD,

    output MEMWE,
    output Dev0WE,
    output Dev1WE,

    input [`Word] MEMRD,
    input [`Word] Dev0RD,
    input [`Word] Dev1RD,
    output [`Word] PrRD,

    input Dev0Irq,
    input Dev1Irq,
    output [5:0] HWInt,

    input [`Word] PrPC,
    output [`Word] PC
);
    assign Addr=PrAddr;
    assign BE=PrBE;
    assign WD=PrWD;
    assign PC=PrPC;

    wire MEMHIT  = (PrAddr>=`DATAADDR_BEGIN) & (PrAddr<=`DATAADDR_END);
    wire Dev0HIT = (PrAddr>=`DEV0ADDR_BEGIN) & (PrAddr<=`DEV0ADDR_END);
    wire Dev1HIT = (PrAddr>=`DEV1ADDR_BEGIN) & (PrAddr<=`DEV1ADDR_END);

    assign MEMWE  = PrWE & MEMHIT;
    assign Dev0WE = PrWE & Dev0HIT;
    assign Dev1WE = PrWE & Dev1HIT;
    
    assign PrRD = (MEMHIT)?MEMRD:
                  (Dev0HIT)?Dev0RD:
                  (Dev1HIT)?Dev1RD:
                  0;

    assign HWInt = {4'b0,Dev1Irq,Dev0Irq};

endmodule // Bridge
`endif