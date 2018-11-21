`timescale 1ns / 1ps
module mips_tb();
    reg clk;
    reg reset;
    initial
        begin
            clk=1;
            forever #10 
                begin
                    clk=!clk;
                    //$display("%h",mips._im.Inst);
                end
        end
    initial
        begin
            reset=1;
            #40
            reset=0;
        end
    mips mips(clk,reset);
endmodule // mips_tb