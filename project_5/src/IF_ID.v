/*
 * 取指与译码取数之间的模块
 */
`ifndef __IF_ID_V__
`define __IF_ID_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module IF_ID(
    input clk,
    input reset,
    input clr,
    input en,
    input [`Word] InstF,
    input [`Word] PC4F,

    output reg [`Word] InstD,
    output reg [`Word] PC4D,

    input [`Word] PCF,
    output reg [`Word] PCD
);
    initial
    begin
        InstD<=0;
        PC4D<=0;
        PCD<=0;
    end

    always @(posedge clk)
    begin
        if(reset)
            begin
                InstD<=0;
                PC4D<=0;
                PCD<=0;
            end
        else if(en!=1)
            begin
                if(clr)
                    begin
                        InstD<=0;
                        PC4D<=0;
                        PCD<=0;
                    end
                else
                    begin
                        InstD<=InstF;
                        PC4D<=PC4F;
                        PCD<=PCF;
                    end
            end
        end
endmodule // IF_ID
`endif