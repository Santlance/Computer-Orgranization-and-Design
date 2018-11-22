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
    input [`Word] addr,
    input [`Word] wd,
    input [`Word] PC,
    output [`Word] rd
);
    localparam RAM_SIZE=2 ** (WIDTH-2);
    reg [7:0] ram[RAM_SIZE*4-1:0];
    wire [1:0] byte_select = addr[1:0];
    
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

    //read
    Mux4 #(8) byte_mux(
        .a0(ram_b0),
        .a1(ram_b1),
        .a2(ram_b2),
        .a3(ram_b3),
        .select(addr[1:0]),
        .out(byte_out)
        );
    Mux2 #(16) half_mux(
        .a0(ram_h0),
        .a1(ram_h1),
        .select(addr[1]),
        .out(half_out)
        );
    dm_read_mux dmrm(
        .word_in(word_out),
        .half_in(half_out),
        .byte_in(byte_out),
        .select(type),
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
                $display("@%h: *%h <= %h",PC, addr,wd);
                case (type)
                    3'b000 :   // Word
                        begin
                            ram[addr+0]<=wd[`Byte0];
                            ram[addr+1]<=wd[`Byte1];
                            ram[addr+2]<=wd[`Byte2];
                            ram[addr+3]<=wd[`Byte3];
                        end
                    3'b010 : // Half
                        begin
                            case (addr[1])
                                0:
                                    begin
                                        ram[addr+1]<=wd[`Byte1];
                                        ram[addr+0]<=wd[`Byte0];
                                    end
                                1:
                                    begin
                                        ram[addr+3]<=wd[`Byte1];
                                        ram[addr+2]<=wd[`Byte0];
                                    end
                            endcase
                        end
                    3'b100 : // Byte
                        begin
                            case (addr[1:0])
                                0 : 
                                    begin
                                        ram[addr+0]<=wd[`Byte0];
                                    end
                                1 : 
                                    begin
                                        ram[addr+1]<=wd[`Byte0];
                                    end
                                2 : 
                                    begin
                                        ram[addr+2]<=wd[`Byte0];
                                    end
                                3 : 
                                    begin
                                        ram[addr+3]<=wd[`Byte0];
                                    end
                            endcase
                        end
                endcase
            end
        end
endmodule // 

module dm_read_mux(
    input [`Word]word_in,
    input [`Half]half_in,
    input [`Byte]byte_in,
    input [2:0]select,
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
               (select==3'b101)?byte_extend_signed:0;
endmodule
`endif