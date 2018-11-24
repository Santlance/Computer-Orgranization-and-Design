`ifndef __EXT_V__
`define __EXT_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module zero_extend #(parameter IN_WIDTH=16,OUT_WIDTH=32)
(
    input [IN_WIDTH-1:0]in,
    output [OUT_WIDTH-1:0]out
);
    assign out={ {OUT_WIDTH-IN_WIDTH{1'b0}},in };
endmodule // zero_extend

module sign_extend #(parameter IN_WIDTH=16,OUT_WIDTH=32)
(
    input [IN_WIDTH-1:0]in,
    output [OUT_WIDTH-1:0]out
);
    assign out={ { OUT_WIDTH-IN_WIDTH{ in[IN_WIDTH-1] } },in};
endmodule // sign_extend

module EXT #(parameter IN_WIDTH=16,OUT_WIDTH=32)
(
    input [IN_WIDTH-1:0] in,
    input type,
    output [OUT_WIDTH-1:0] out
);
    assign out=(type==0)?{ {OUT_WIDTH-IN_WIDTH{1'b0}},in }
                        :{ { OUT_WIDTH-IN_WIDTH{ in[IN_WIDTH-1] } },in};
endmodule // EXT

module MEMRD_EXT(
    input [`Word] in,
    input [2:0] type,
    input [1:0] byte_select,
    output [`Word] out
);
    wire [`Byte] b3,b2,b1,b0,byte;
    wire [`Half] half;
    assign {b3,b2,b1,b0} = in;
    assign half = (byte_select==2'b00)?{b1,b0}:{b3,b2};
    assign byte = (byte_select==2'b00)?b0:
                  (byte_select==2'b01)?b1:
                  (byte_select==2'b10)?b2:
                  b3;
    assign out  = (type==3'b001)?{{`Word_Size-`Half_Size{1'b0}},half[`Half0]}:               // unsigned half
                  (type==3'b010)?{{`Word_Size-`Half_Size{half[`Half_Size-1]}},half[`Half0]}: // signed half
                  (type==3'b011)?{{`Word_Size-`Byte_Size{1'b0}},byte[`Byte0]}:               // unsigned byte
                  (type==3'b100)?{{`Word_Size-`Byte_Size{byte[`Byte_Size-1]}},byte[`Byte0]}: // signed byte
                  in;
endmodule
`endif