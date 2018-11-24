`ifndef __DM_V__
`define __DM_V__
`include "./macro.vh"
`include "./mux.v"
`include "./ext.v"
`timescale 1ns / 1ps
module DM #(parameter WIDTH = 12)
(
    input clk,
    input reset,
    input we,
    input [2:0]type,
    input [`Word] addr_in,
    input [`Word] wd,
    input [`Word] PC,
    output [`Word] rd
);
    localparam RAM_SIZE=2 ** (WIDTH-2);
    reg [7:0] ram[RAM_SIZE*4-1:0];

    wire [`Word] addr={addr_in[31:2],2'b0};
    wire [1:0] byte_select = addr_in[1:0];
    
    integer i;

    initial
        begin
            for(i=0;i<RAM_SIZE*4-1;i=i+1)
                ram[i]<=0;
        end
    wire [`Word] ram_word={
        ram[addr+3],
        ram[addr+2],
        ram[addr+1],
        ram[addr+0]
        };
    wire [`Half] ram_h1={
        ram[addr+3],
        ram[addr+2]
        };
    wire [`Half] ram_h0={
        ram[addr+1],
        ram[addr+0]
        };
    wire[`Byte] ram_b3=ram[addr+3];
    wire[`Byte] ram_b2=ram[addr+2];
    wire[`Byte] ram_b1=ram[addr+1];
    wire[`Byte] ram_b0=ram[addr+0];

    // read
    wire [`Word] word_out=ram_word;
    wire [`Half] half_out;
    wire [`Byte] byte_out;
    wire [`Word] wl_out;
    wire [`Word] wr_out;
    assign byte_out=(byte_select==0)?ram_b0:
                    (byte_select==1)?ram_b1:
                    (byte_select==2)?ram_b2:
                    ram_b3;
    assign half_out=(byte_select==0)?ram_h0:ram_h1;
    assign wl_out=(byte_select==0)?{ram_b0,24'b0}:
                  (byte_select==1)?{ram_h0,16'b0}:
                  (byte_select==2)?{ram_b2,ram_h0,8'b0}:
                  ram_word;
    assign wr_out=(byte_select==0)?ram_word:
                  (byte_select==1)?{8'b0,ram_h1,ram_b1}:
                  (byte_select==2)?{16'b0,ram_h1}:
                  {24'b0,ram_b3};
    dm_read_mux dmrm(
        .word_in(word_out),
        .half_in(half_out),
        .byte_in(byte_out),
        .wl_in(wl_out),
        .wr_in(wr_out),
        .select(type),
        .addr(addr[1:0]),
        .out(rd)
        );

    // write
    always @(posedge clk) 
        begin
            if(reset)
                begin
                    for(i=0;i<RAM_SIZE-1;i=i+1)
                    ram[i]<=0;
                end
            else if(we==1)
            begin
                $display("%d@%h: *%h <= %h", $time, PC, addr_in,wd);
                case (type)
                    3'b000 :   // Word
                        {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr]}<=wd;
                    3'b010 : // Half
                        {ram[addr_in+1],ram[addr_in+0]}<=wd[`Half0];
                    3'b100 : // Byte
                        ram[addr_in]<=wd[`Byte0];
                    3'b110 : // WL
                        case (byte_select)
                            0 :
                                ram[addr+0]<=wd[`Byte3];
                            1 :
                                {ram[addr+1],ram[addr+0]}<=wd[`Half1];
                            2 :
                                {ram[addr+2],ram[addr+1],ram[addr+0]}<={wd[`Half1],wd[`Byte1]};
                            3 :
                                {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr+0]}<=wd;
                        endcase
                    3'b111 : // WR
                        case (byte_select)
                            0 :
                                {ram[addr+3],ram[addr+2],ram[addr+1],ram[addr+0]}<=wd;
                            1 :
                                {ram[addr+3],ram[addr+2],ram[addr+1]}<={wd[`Byte2],wd[`Half0]};
                            2 :
                                {ram[addr+3],ram[addr+2]}<=wd[`Half0];
                            3 :
                                ram[addr+3]<=wd[`Byte0];
                        endcase
                endcase
            end
        end
endmodule // 

module dm_read_mux(
    input [`Word]word_in,
    input [`Half]half_in,
    input [`Byte]byte_in,
    input [`Word]wl_in,
    input [`Word]wr_in,
    input [2:0]select,
    input [1:0]addr,
    output [31:0]out
);
    wire [`Word] half_extend_signed;
    wire [`Word] byte_extend_signed;
    wire [`Word] half_extend_unsigned;
    wire [`Word] byte_extend_unsigned;
    sign_extend #(`Half_Size,`Word_Size) half_out_signed
    (
        .in(half_in),
        .out(half_extend_signed)
    );
    sign_extend #(`Byte_Size,`Word_Size) byte_out_signed
    (
        .in(byte_in),
        .out(byte_extend_signed)
    );
    zero_extend #(`Half_Size,`Word_Size) half_out_unsigned
    (
        .in(half_in),
        .out(half_extend_unsigned)
    );
    zero_extend #(`Byte_Size,`Word_Size) byte_out_unsigned
    (
        .in(byte_in),
        .out(byte_extend_unsigned)
    );
    assign out=(select==3'b000)?word_in:
               (select==3'b010)?half_extend_unsigned:
               (select==3'b011)?half_extend_signed:
               (select==3'b100)?byte_extend_unsigned:
               (select==3'b101)?byte_extend_signed:
               (select==3'b110)?wl_in:
               (select==3'b111)?wr_in:0;
endmodule
`endif