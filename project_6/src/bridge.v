`ifndef __BRIDGE_V__
`define __BRIDGE_V__
`include "./macro.vh"
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

    input [`Word] MEMRD,
    output [`Word] PrRD,

    input [`Word] PrPC,
    output [`Word] PC
);
    assign Addr=PrAddr;
    assign BE=PrBE;
    assign WD=PrWD;
    assign PC=PrPC;

    assign MEMWE  = PrWE;
    
    assign PrRD = MEMRD;

endmodule // Bridge
`endif