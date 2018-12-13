`timescale 1ns / 1ps
module mips_tb;
    reg clk;
    reg reset;
    
    mips _mips(clk,reset);
    initial
        begin
            clk=0;
            reset=1;
            #10;
            reset<=0;
        end
    always #5 clk=~clk;
endmodule // mips_tb
