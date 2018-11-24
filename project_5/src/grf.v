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
    input [`Word] PC,       // for test
    output [`Word] r1,
    output [`Word] r2
);

    reg [31:0] grf[`Word];
    
    assign r1=grf[A1];
    assign r2=grf[A2];

    integer i;
    initial
        begin
            for(i=0;i<32;i=i+1)
            grf[i]<=0;
        end
    always @(posedge clk) 
        begin
            if(reset)
                begin
                    for(i=0;i<32;i=i+1)
                    grf[i]<=0;
                end
            else if(we==1 && A3!=0)
                begin
                    $display("%d@%h: $%d <= %h", $time, PC, A3,wd);
                    if(A3!=0)
                    begin
                        grf[A3]<=wd;
                    end
                end
        end
endmodule // GRF
