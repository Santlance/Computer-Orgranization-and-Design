`timescale 1ns / 1ps
module mips_tb;
    reg clk;
    reg reset;
    initial
        begin
            clk=0;
            reset=1;
            #40;
            reset=0;
            forever #10 clk=~clk;
        end
    mips _mips(clk,reset);
endmodule // mips_tb