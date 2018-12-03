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
    input [3:0] type,
    input [1:0] byte_select,
    output [`Word] out
);
    wire [`Byte] b3,b2,b1,b0,byte;
    wire [`Half] half;
    wire [`Word] wl,wr;
    assign {b3,b2,b1,b0} = in;

    assign half = (byte_select==2'b00)?{b1,b0}:{b3,b2};
    assign byte = (byte_select==2'b00)?b0:
                  (byte_select==2'b01)?b1:
                  (byte_select==2'b10)?b2:
                                       b3;
    assign wl   = (byte_select==2'b00)?{b0,24'b0}:
                  (byte_select==2'b01)?{b1,b0,16'b0}:
                  (byte_select==2'b10)?{b2,b1,b0,8'b0}:
                                       in;
    assign wr   = (byte_select==2'b00)?in:
                  (byte_select==2'b01)?{8'b0,b3,b2,b1}:
                  (byte_select==2'b10)?{16'b0,b3,b2}:
                                       {24'b0,b3};
    
    assign out  = (type==4'b0010)?{{`Word_Size-`Half_Size{1'b0}},half[`Half0]}:               // unsigned half
                  (type==4'b0011)?{{`Word_Size-`Half_Size{half[`Half_Size-1]}},half[`Half0]}: // signed half
                  (type==4'b0100)?{{`Word_Size-`Byte_Size{1'b0}},byte[`Byte0]}:               // unsigned byte
                  (type==4'b0101)?{{`Word_Size-`Byte_Size{byte[`Byte_Size-1]}},byte[`Byte0]}: // signed byte
                  (type==4'b0110)?wl:                                                         // LWL
                  (type==4'b0111)?wr:                                                         // LWR
                  in;
endmodule
`endif