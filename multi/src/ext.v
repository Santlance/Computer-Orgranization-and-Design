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
`endif