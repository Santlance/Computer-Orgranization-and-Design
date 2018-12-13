`ifndef __TC_V__
`define __TC_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module TC #(parameter base=`DEV0ADDR_BEGIN)
(
    input clk,
    input reset,
    input [`Word] addr,
    input we,
    input [`Word] wd,
    output [`Word] RD,
    output IRQ,

    input [`Word] PC
);
    reg [`Word] ctrl,preset,count;
    reg irq;
    wire [3:0] reg_select = addr-base;

    // -------- ctrl寄存器定义
    // ctrl[31:4] reserved
    // ctrl[3] Interrupt Mask
    // ctrl[2:1] Mode Select
    // ctrl[0] Count Enable
    wire IM            = ctrl[3];
    wire [1:0] Mode    = ctrl[2:1];
    wire CountEn       = ctrl[0];

    assign RD = (reg_select==4'h0)?ctrl:
                (reg_select==4'h4)?preset:
                (reg_select==4'h8)?count:
                0;

    reg [1:0] state;
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam CNT  = 2'b10;
    localparam INT  = 2'b11;

    initial
    begin
        ctrl<=0;
        preset<=0;
        count<=0;
        irq<=0;
        state<=IDLE;
    end

    assign IRQ = IM & irq;

    always @(posedge clk)
    begin
        if(reset)
            begin
                state<=IDLE;
                ctrl<=0;
                preset<=0;
                count<=0;
                irq<=0;
            end
        else
        begin
            if(we==1'b1)
                case (reg_select)
                    4'h0: ctrl<=wd;
                    4'h4: preset<=wd;
                endcase
            else 
                case (state)
                IDLE:
                    if(CountEn==1)
                        begin
                            state<=LOAD;
                            irq<=0;
                        end
                LOAD:
                    begin
                        state<=CNT;
                        count<=preset;
                    end
                CNT:
                    if(CountEn==0)
                        state<=IDLE;
                    else if(count<=1 && CountEn==1)
                        begin
                            irq<=1;
                            state<=INT;
                            if(Mode==0)
                                ctrl[0]<=0;
                        end
                    else count<=count-1;
                INT:
                    begin
                        if(Mode!=0)
                            irq<=0;
                        state<=IDLE;
                    end
                endcase
        end
    end
endmodule // TC
`endif