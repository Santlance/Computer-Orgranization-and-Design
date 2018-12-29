/*
 * name: DM
 * author: btapple
 * description: data menagement.
 */

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

    output [15:0] PrAddr,
    output [`Word] PrWD,
    output PrWE,
    output [3:0] PrBE,
    output [6:0] PrHIT,

    input Before_ExcOccur,
    output ExcOccur,
    output [4:0]ExcCode

    // input [`Word] PC,
    // output [`Word] PrPC
);
    
    wire [`Word] addr = {addr_in[31:2],2'b0};
    wire [`Word] PreWrite;

    assign PrAddr = addr[15:0];
    assign PrWD=PreWrite;
    assign rd=PrRD;
    assign rd_extend_type = type;

    assign byte_select = addr_in[1:0];
    wire DeviceHIT = ~(|(PrAddr[15:8] ^ 8'h7F));
    wire MEMHIT = ~(|PrAddr[15:13]);
    wire Dev0HIT = DeviceHIT & (PrAddr[7:0]>=`DEV0ADDR_BEGIN_LAST) & (PrAddr[7:0]<=`DEV0ADDR_END_LAST);
    wire Dev1HIT = DeviceHIT & (PrAddr[7:0]>=`DEV1ADDR_BEGIN_LAST) & (PrAddr[7:0]<=`DEV1ADDR_END_LAST);
    wire Dev2HIT = DeviceHIT & (PrAddr[7:0]>=`DEV2ADDR_BEGIN_LAST) & (PrAddr[7:0]<=`DEV2ADDR_END_LAST);
    wire Dev3HIT = DeviceHIT & (PrAddr[7:0]>=`DEV3ADDR_BEGIN_LAST) & (PrAddr[7:0]<=`DEV3ADDR_END_LAST);
    wire Dev4HIT = DeviceHIT & (PrAddr[7:0]>=`DEV4ADDR_BEGIN_LAST) & (PrAddr[7:0]<=`DEV4ADDR_END_LAST);
    wire Dev5HIT = DeviceHIT & (PrAddr[7:0]>=`DEV5ADDR_BEGIN_LAST) & (PrAddr[7:0]<=`DEV5ADDR_END_LAST);

    assign PrHIT = {Dev5HIT,Dev4HIT,Dev3HIT,Dev2HIT,Dev1HIT,Dev0HIT,MEMHIT};

    // Exception
    assign ExcOccur = ( 
        (type!=4'b1111 && ((|addr[31:16]) || ~(MEMHIT  |                     // Out of range
                                               Dev0HIT |
                                               Dev1HIT |
                                               Dev2HIT |
                                               Dev3HIT |
                                               Dev4HIT |
                                               Dev5HIT))) ||
        (type==4'b0000 && byte_select!=2'b00) ||                                                        // LW or SW not aligned
        ((type==4'b0010 || type==4'b0011) && byte_select[0]!=1'b0) ||                                   // LH, LHU or SH not aligned
        ((type!=4'b0000 && type!=4'b1111) && (Dev0HIT |   // Not SW or LW but access to device
                                              Dev1HIT |
                                              Dev2HIT |
                                              Dev3HIT |
                                              Dev4HIT |
                                              Dev5HIT)) ||
        (we && ((PrAddr==`DEV0ADDR_BEGIN + `TC_COUNT_OFFSET) ||
                (PrAddr==`DEV2ADDR_BEGIN)))  // Try to write count register of TC or switch
    )?1'b1:1'b0;

    assign ExcCode = ExcOccur?(we?`EXC_ADES:
                                  `EXC_ADEL):
                              5'b00000;

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
                //   (type==4'b0110)?                       // SWL
                //    ((byte_select==2'b00)?4'b0001:
                //     (byte_select==2'b01)?4'b0011:
                //     (byte_select==2'b10)?4'b0111:
                //                          4'b1111):
                //   (type==4'b0111)?                       // SWR
                //    ((byte_select==2'b00)?4'b1111:
                //     (byte_select==2'b01)?4'b1110:
                //     (byte_select==2'b10)?4'b1100:
                //                          4'b1000):
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
                    //   (type==4'b110)?
                    //    ((byte_select==2'b00)?{24'b0,wd[`Byte3]}:
                    //     (byte_select==2'b01)?{16'b0,wd[`Half1]}:
                    //     (byte_select==2'b10)?{8'b0,wd[`Half1],wd[`Byte1]}:
                    //                          wd):
                    //   (type==4'b0111)?
                    //    ((byte_select==2'b00)?wd:
                    //     (byte_select==2'b01)?{wd[`Byte2],wd[`Half0],8'b0}:
                    //     (byte_select==2'b10)?{wd[`Half0],16'b0}:
                    //                          {wd[`Byte0],24'b0}):
                      32'b0;


    // assign PrPC=PC;

endmodule // 
`endif