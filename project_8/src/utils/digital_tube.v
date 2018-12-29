/*
 * name: digital_tube
 * author: btapple
 * description: 8 bit digital tube
 */
`ifndef __DIGITAL_TUBE_V__
`define __DIGITAL_TUBE_V__
`include "../macro.vh"
`timescale 1ns / 1ps
module Digital_Tube #(parameter base=`DEV4ADDR_BEGIN)
(
    input clk,
    input reset,
    input we,
    input [31:0] wd,
    output [31:0] RD,

    output [7:0] digital_tube2,
    output digital_tube_sel2,

    output [7:0] digital_tube1,
    output [3:0] digital_tube_sel1,

    output [7:0] digital_tube0,
    output [3:0] digital_tube_sel0
);
    localparam NEG  = 8'b11111110;
    localparam NONE = 8'b11111111;
    localparam DURING = 32'h1000;

    reg [31:0] data,
               count;
    wire [31:0] show = (data[31])? (~data + 1):    // negative
                            data;

    reg [3:0] digital_tube_sel_state0,
              digital_tube_sel_state1;
    wire [3:0] digital_tube_content0,
               digital_tube_content1;

    assign RD = (reset)? 0:
                         data;

    assign digital_tube_sel0 = digital_tube_sel_state0;
    assign digital_tube_sel1 = digital_tube_sel_state1;
    assign digital_tube_sel2 = 1'b1;
    // assign digital_tube_content0 = show[3:0];
     assign digital_tube_content0 = (digital_tube_sel_state0==4'b0001)?show[3:0]:
                                    (digital_tube_sel_state0==4'b0010)?show[7:4]:
                                    (digital_tube_sel_state0==4'b0100)?show[11:8]:
                                    (digital_tube_sel_state0==4'b1000)?show[15:12]:
                                                                       4'b0;
    assign digital_tube_content1 = (digital_tube_sel_state1==4'b0001)?show[19:16]:
                                   (digital_tube_sel_state1==4'b0010)?show[23:20]:
                                   (digital_tube_sel_state1==4'b0100)?show[27:24]:
                                   (digital_tube_sel_state1==4'b1000)?show[31:28]:
                                                                      4'b0;
    // assign digital_tube_content2 = data_1[3:0];
    assign digital_tube2 = (data[31])? NEG:
                                       NONE;

    Digital_Tube_Selector _tube0_selector(
        .in(digital_tube_content0),
        .out(digital_tube0)
    );
    Digital_Tube_Selector _tube1_selector(
        .in(digital_tube_content1),
        .out(digital_tube1)
    );
    always @(posedge clk)
    begin
        if(reset)
            begin
                data<=0;
                digital_tube_sel_state0<=4'h0;
                digital_tube_sel_state1<=4'h0;
                count<=0;
            end
        else 
            begin
                if(count==DURING)
                    begin
                        count<=0;
                        case (digital_tube_sel_state0)
                            4'b0001: digital_tube_sel_state0<=4'b0010;
                            4'b0010: digital_tube_sel_state0<=4'b0100;
                            4'b0100: digital_tube_sel_state0<=4'b1000;
                            default: digital_tube_sel_state0<=4'b0001;
                        endcase
                        case (digital_tube_sel_state1)
                            4'b0001: digital_tube_sel_state1<=4'b0010;
                            4'b0010: digital_tube_sel_state1<=4'b0100;
                            4'b0100: digital_tube_sel_state1<=4'b1000;
                            default: digital_tube_sel_state1<=4'b0001;
                        endcase
                    end
                else
                    count<=count+1;
                if(we)
                    data <= wd;
            end
    end

endmodule // LED

module Digital_Tube_Selector(
    input [3:0] in,
    output [7:0] out
);
    localparam ZERO  = 8'b10000001;
    localparam ONE   = 8'b11001111;
    localparam TWO   = 8'b10010010;
    localparam THREE = 8'b10000110;
    localparam FOUR  = 8'b11001100;
    localparam FIVE  = 8'b10100100;
    localparam SIX   = 8'b10100000;
    localparam SEVEN = 8'b10001111;
    localparam EIGHT = 8'b10000000;
    localparam NINE  = 8'b10000100;
    localparam A     = 8'b10001000;
    localparam B     = 8'b11100000;
    localparam C     = 8'b10110001;
    localparam D     = 8'b11000010;
    localparam E     = 8'b10110000;
    localparam F     = 8'b10111000;

    assign out = (in==4'h0)?ZERO:
                 (in==4'h1)?ONE:
                 (in==4'h2)?TWO:
                 (in==4'h3)?THREE:
                 (in==4'h4)?FOUR:
                 (in==4'h5)?FIVE:
                 (in==4'h6)?SIX:
                 (in==4'h7)?SEVEN:
                 (in==4'h8)?EIGHT:
                 (in==4'h9)?NINE:
                 (in==4'hA)?A:
                 (in==4'hB)?B:
                 (in==4'hC)?C:
                 (in==4'hD)?D:
                 (in==4'hE)?E:
                 (in==4'hF)?F:
                            ZERO;

endmodule // Digital_Tube_Selector
`endif