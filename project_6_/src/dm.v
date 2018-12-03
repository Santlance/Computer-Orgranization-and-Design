`ifndef __DM_V__
`define __DM_V__
`include "./macro.vh"
`include "./mux.v"
`include "./ext.v"
`timescale 1ns / 1ps
module DM #(parameter WIDTH = 12)
(
    input we,
    input [3:0]type,
    input [`Word] addr_in,
    input [`Word] wd,
    
    input [`Word] PrRD,

    output [`Word] rd,
    output [3:0] rd_extend_type,
    output [1:0] byte_select,

    output [`Word] PrAddr,
    output [`Word] PrWD,
    output PrWE,
    output [3:0] PrBE,

    input Before_ExcOccur,
    output ExcOccur,
    output [4:0]ExcCode,

    input [`Word] PC,
    output [`Word] PrPC
);
    
    wire [`Word] addr = {addr_in[31:2],2'b0};
    wire [`Word] PreWrite;

    assign byte_select = addr_in[1:0];

    // Exception
    assign ExcOccur = (
        (type==4'b0000 && byte_select!=2'b00)||
        ((type==4'b0010 || type==4'b0011)&&byte_select[0]!=1'b0)||
        (type!=4'b1111 && ~((addr_in>=`DATAADDR_BEGIN && addr_in<=`DATAADDR_END)||
                            (addr_in>=`DEV0ADDR_BEGIN && addr_in<=`DEV0ADDR_END)||
                            (addr_in>=`DEV1ADDR_BEGIN && addr_in<=`DEV1ADDR_END)))||
        (we && (addr-`DEV0ADDR_BEGIN=='h8 || addr-`DEV1ADDR_BEGIN=='h8))
    )?1:0;

    assign ExcCode = ExcOccur?(we?`EXC_ADES:`EXC_ADEL):5'b00000;

    assign PrWE = we & ~ExcOccur & ~Before_ExcOccur;

    assign PrBE = (type==4'b0000)?4'b1111:               // SW
                  (type==4'b0010)?                       // SH
                    ((byte_select==2'b00)?4'b0011:
                                          4'b1100):
                  (type==4'b0100)?                       // SB
                    ((byte_select==2'b00)?4'b0001:
                     (byte_select==2'b01)?4'b0010:
                     (byte_select==2'b10)?4'b0100:
                                          4'b1000):
                  (type==4'b0110)?                       // SWL
                   ((byte_select==2'b00)?4'b0001:
                    (byte_select==2'b01)?4'b0011:
                    (byte_select==2'b10)?4'b0111:
                                         4'b1111):
                  (type==4'b0111)?                       // SWR
                   ((byte_select==2'b00)?4'b1111:
                    (byte_select==2'b01)?4'b1110:
                    (byte_select==2'b10)?4'b1100:
                                         4'b1000):
                  4'b0000;

    assign PreWrite = (type==4'b0000)?wd:
                      (type==4'b0010)?
                       ((byte_select==2'b00)?{16'b0,wd[`Half0]}:
                                             {wd[`Half0],16'h0}):
                      (type==4'b0100)?
                       ((byte_select==2'b00)?{24'b0,wd[`Byte0]}:
                        (byte_select==2'b01)?{16'b0,wd[`Byte0],8'b0}:
                        (byte_select==2'b10)?{8'b0,wd[`Byte0],16'b0}:
                                             {wd[`Byte0],24'b0}):
                      (type==4'b110)?
                       ((byte_select==2'b00)?{24'b0,wd[`Byte3]}:
                        (byte_select==2'b01)?{16'b0,wd[`Half1]}:
                        (byte_select==2'b10)?{8'b0,wd[`Half1],wd[`Byte1]}:
                                             wd):
                      (type==4'b0111)?
                       ((byte_select==2'b00)?wd:
                        (byte_select==2'b01)?{wd[`Byte2],wd[`Half0],8'b0}:
                        (byte_select==2'b10)?{wd[`Half0],16'b0}:
                                             {wd[`Byte0],24'b0}):
                      32'b0;

    assign PrAddr=addr;

    assign PrWD=PreWrite;
    
    assign rd=PrRD;

    assign rd_extend_type=type;

    assign PrPC=PC;
endmodule // 
`endif