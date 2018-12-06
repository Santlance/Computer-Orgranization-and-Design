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
    input [3:0] be,
    input [`Word] wd,
    output [`Word] RD,
    output IRQ,

    input [`Word] PC
);
    reg [`Word] ctrl,preset,count;

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

    assign IRQ = (IM && (Mode==1'b0) && (count==32'b0))?1'b1:1'b0;

    initial
    begin
        ctrl<=0;
        preset<=0;
        count<=0;
    end
    
    always @(posedge clk)
    begin
        if(reset)
            begin
                ctrl<=0;
                preset<=0;
                count<=0;
            end
        else
        begin
            if(we==1'b1)
                case (reg_select)
                    4'h0:
                        begin
                            if(be[3]) ctrl[`Byte3]=wd[`Byte3];
                            if(be[2]) ctrl[`Byte2]=wd[`Byte2];
                            if(be[1]) ctrl[`Byte1]=wd[`Byte1];
                            if(be[0]) ctrl[`Byte0]=wd[`Byte0];
                            $display("%d@%h: *%h <= %h", $time, PC, addr,ctrl);
                        end
                    4'h4:
                        begin
                            if(be[3]) preset[`Byte3]=wd[`Byte3];
                            if(be[2]) preset[`Byte2]=wd[`Byte2];
                            if(be[1]) preset[`Byte1]=wd[`Byte1];
                            if(be[0]) preset[`Byte0]=wd[`Byte0];
                            $display("%d@%h: *%h <= %h", $time, PC, addr,preset);
                        end
                endcase
                
            else if(count==32'b1 && CountEn==1'b1 && Mode==2'b00)
                ctrl<={ctrl[31:0],1'b0};

            if(CountEn==1'b1)
                count<=(count>32'b0)?count-1:
                                     preset;
        end
    end
endmodule // TC
`endif