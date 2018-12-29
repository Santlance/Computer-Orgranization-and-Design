/*
 * name: Bridge
 * author: btapple
 * description: outside the core, connecting the core and devices.
 */

`ifndef __BRIDGE_V__
`define __BRIDGE_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module Bridge(
    input [15:0] PrAddr,
    input PrWE,
    input [3:0] PrBE,
    input [`Word] PrWD,
    input [6:0] PrHIT,
    output [15:0] Addr,
    output [3:0] BE,
    output [`Word] WD,

    output MEMWE,
    output Dev0WE,
    output Dev1WE,
    output Dev2WE,
    output Dev3WE,
    output Dev4WE,
    output Dev5WE,

    output Dev1STB,

    input [`Word] MEMRD,
    input [`Word] Dev0RD,
    input [`Word] Dev1RD,
    input [`Word] Dev2RD,
    input [`Word] Dev3RD,
    input [`Word] Dev4RD,
    input [`Word] Dev5RD,
    output [`Word] PrRD,

    input Dev0Irq,
    input Dev1Irq,
    output [5:0] HWInt

    // input [`Word] PrPC,
    // output [`Word] PC
);
    assign Addr=PrAddr;
    assign BE=PrBE;
    assign WD=PrWD;
    // assign PC=PrPC;
    wire MEMHIT,
         Dev0HIT,
         Dev1HIT,
         Dev2HIT,
         Dev3HIT,
         Dev4HIT,
         Dev5HIT;
         
    assign {Dev5HIT,Dev4HIT,Dev3HIT,Dev2HIT,Dev1HIT,Dev0HIT,MEMHIT} = PrHIT;

    assign MEMWE  = PrWE & MEMHIT;
    assign Dev0WE = PrWE & Dev0HIT;
    assign Dev1WE = PrWE & Dev1HIT;
    assign Dev2WE = PrWE & Dev2HIT;
    assign Dev3WE = PrWE & Dev3HIT;
    assign Dev4WE = PrWE & Dev4HIT;
    assign Dev5WE = PrWE & Dev5HIT;

    assign Dev1STB = Dev1HIT;

    assign PrRD = (MEMHIT)?MEMRD:
                  (Dev0HIT)?Dev0RD:
                  (Dev1HIT)?Dev1RD:
                  (Dev2HIT)?Dev2RD:
                  (Dev3HIT)?Dev3RD:
                  (Dev4HIT)?Dev4RD:
                  (Dev5HIT)?Dev5RD:
                  0;

    assign HWInt = {4'b0,Dev1Irq,Dev0Irq};

endmodule // Bridge
`endif