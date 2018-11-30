`ifndef __MULTIPLIER_V__
`define __MULTIPLIER_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module Multiplier(
    input clk,
    input reset,
    input [1:0] MTHILO,
    input [`Word] SrcA,
    input [`Word] SrcB,
    input [2:0] MulOp,
    output reg [`Word] HI,
    output reg [`Word] LO,
    output busy
);
    reg [3:0] counter;

    initial
    begin
        HI<=0;
        LO<=0;
        counter<=0;
    end

    always @(posedge clk)
    begin
        if(reset)
            begin
                HI<=0;
                LO<=0;
                counter<=0;
            end
        else if(counter>0)
            counter<=counter-4'b1;
        else
            begin
                case (MulOp)
                    3'b000:  // unsigned mult
                        begin
                            counter<=5;
                            {HI,LO}<={1'b0,SrcA}*{1'b0,SrcB};
                        end
                    3'b001:
                        begin
                            counter<=5;
                            {HI,LO}<=$signed(SrcA)*$signed(SrcB);
                        end
                    3'b010:
                        begin
                            counter<=10;
                            HI<={1'b0,SrcA}%{1'b0,SrcB};
                            LO<={1'b0,SrcA}/{1'b0,SrcB};
                        end
                    3'b011:
                        begin
                            counter<=10;
                            HI<=$signed(SrcA)%$signed(SrcB);
                            LO<=$signed(SrcA)/$signed(SrcB);
                        end
                endcase

                case (MTHILO)
                    2'b00:
                        LO<=SrcA;
                    2'b01:
                        HI<=SrcA;
                endcase
            end
    end

    assign busy = (counter==0)?1'b0:1'b1;
endmodule // Multiplier
`endif