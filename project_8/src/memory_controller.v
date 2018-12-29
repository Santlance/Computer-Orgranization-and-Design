/*
 * name: memory
 * author: btapple
 * description: memory
 */

`ifndef __MEMORY_V__
`define __MEMORY_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module Memory_Controller // #(parameter WIDTH=12)
(
    input clk,
    input reset,
    input we,
    input [3:0]be,
    input [15:0] addr,
    input [`Word] wd,
    // input [`Word] PC,
    output [`Word] rd
);
    wire [3:0] wea = (we==1'b1)?be:
                     4'b0;

    memory mem(
        .clka(clk),             // input clka
        .rsta(reset),           // input rsta
        .wea(wea),              // input [3 : 0] wea
        .addra(addr[14:2]),  // input [12 : 0] addra
        .dina(wd),              // input [31 : 0] dina
        .douta(rd)              // output [31 : 0] douta
    );
    // always @(posedge clk)
    // begin
    //     $display("%h",addr);
    // end
    // wire [29:0] addr = addr_in[31:2];

    // localparam RAM_SIZE = 2 ** (WIDTH-2);
    // reg [31:0] ram[RAM_SIZE-1:0];
    
    // integer i;
    // initial
    // begin
    //     for(i=0;i<RAM_SIZE;i=i+1)
    //         ram[i]=0;
    // end

    // // read
    // assign rd = ram[addr];

    // // write
    // always @(posedge clk)
    //     begin
    //         if(reset)
    //             begin
    //                 for(i=0;i<RAM_SIZE;i=i+1)
    //                 ram[i]=0;
    //             end
    //         else if(we==1)
    //         begin
    //             if(be[3])
    //                 ram[addr][`Byte3]=wd[`Byte3];
    //             if(be[2])
    //                 ram[addr][`Byte2]=wd[`Byte2];
    //             if(be[1])
    //                 ram[addr][`Byte1]=wd[`Byte1];
    //             if(be[0])
    //                 ram[addr][`Byte0]=wd[`Byte0];
    //             $display("%d@%h: *%h <= %h", $time, PC, addr_in,ram[addr]);
    //         end
    //     end
endmodule // memory
`endif