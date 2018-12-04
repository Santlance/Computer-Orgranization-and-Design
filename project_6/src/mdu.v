`ifndef __MDU_V__
`define __MDU_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module MDU(
    input clk,
    input reset,
    input [1:0] MTHILO,
    input [`Word] SrcA,
    input [`Word] SrcB,
    input [3:0] MDUOp,
    input MDU_Result,
    output reg [`Word] HI,
    output reg [`Word] LO,
    output busy,
    output [1:0] MDU_Result_Stall
);
    reg [3:0] counter;
    reg state,_state;

    initial
    begin
        HI<=0;
        LO<=0;
        counter<=0;
        state<=0;
        _state<=0;
    end

    reg [`Word] temp_hi,temp_lo;

    always @(posedge clk)
    begin
        if(reset)
            begin
                temp_hi<=0;
                temp_lo<=0;
                HI<=0;
                LO<=0;
                counter<=0;
            end
        else if(counter>0)
            begin
                if(counter==4'b1)
                    begin
                        HI<=temp_hi;
                        LO<=temp_lo;
                    end
                counter<=counter-4'b1;
            end
        else if(~state)
            begin
                case (MDUOp)
                    4'b0000:  // unsigned mult
                        begin
                            counter<=5;
                            {temp_hi,temp_lo}<={1'b0,SrcA}*{1'b0,SrcB};
                        end
                    4'b0001: // mult
                        begin
                            counter<=5;
                            {temp_hi,temp_lo}<=$signed(SrcA)*$signed(SrcB);
                        end
                    4'b0010: // unsigned div
                        begin
                            counter<=10;
                            temp_hi<={1'b0,SrcA}%{1'b0,SrcB};
                            temp_lo<={1'b0,SrcA}/{1'b0,SrcB};
                        end
                    4'b0011: // div
                        begin
                            counter<=10;
                            temp_hi<=$signed(SrcA)%$signed(SrcB);
                            temp_lo<=$signed(SrcA)/$signed(SrcB);
                        end
                    4'b0100: // maddu
                        begin
                            counter<=5;
                            {temp_hi,temp_lo}<={1'b0,SrcA}*{1'b0,SrcB}+{HI,LO};
                        end
                    4'b0101: // madd
                        begin
                            counter<=5;
                            {temp_hi,temp_lo}<=$signed(SrcA)*$signed(SrcB)+{HI,LO};
                        end
                    4'b0110: // msubu
                        begin
                            counter<=5;
                            {temp_hi,temp_lo}<={1'b0,SrcA}*{1'b0,SrcB}-{HI,LO};
                        end
                    4'b0111: // msub
                        begin
                            counter<=5;
                            {temp_hi,temp_lo}<=$signed(SrcA)*$signed(SrcB)-{HI,LO};
                        end
                endcase

                case (MTHILO)
                    2'b01:
                        LO<=SrcA;
                    2'b11:
                        HI<=SrcA;
                endcase
            end
    end

    assign busy = (counter==0)?1'b0:1'b1;

    always@(posedge clk)
    begin
        if(state)
            state<=0;
    end

    always@(negedge busy)
    begin
        if(~state && MDU_Result)
            state<=1;
    end

    always@(negedge clk)
    begin
        if(state)
            _state<=1;
        else _state<=0;
    end

    assign MDU_Result_Stall={_state,state};
    
endmodule // Multiplier
`endif