/*
 * name: GRF
 * author: btapple
 * description: general registers file.
 */

`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps

module GRF(
    input clk,
    input reset,
    input we,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [`Word] wd,
    output [`Word] r1,
    output [`Word] r2
);

    reg [`Word] grf[31:0];
    
    assign r1 = (A1==A3)?wd:
                         grf[A1];
    assign r2 = (A2==A3)?wd:
                         grf[A2];

    integer i;
    // initial
    //     begin
    //         for(i=0;i<32;i=i+1)
    //         grf[i]<=0;
    //     end
    always @(posedge clk) 
        begin
            if(reset)
                begin
                    for(i=0;i<32;i=i+1)
                    grf[i]<=0;
                end
            else if(we && A3!=0)
                begin
                    $display("%d: $%d <= %h", $time,A3,wd);
                    grf[A3]<=wd;
                end
        end
        
endmodule // GRF
