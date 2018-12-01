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
    input [3:0]type,
    input [`Word] addr_in,
    input [`Word] wd,
    input [`Word] PC,
    output [`Word] rd,
    output [2:0] rd_extend_type,
    output [1:0] byte_select,

    output ExcOccur,
    output [4:0]ExcCode
);
    localparam RAM_SIZE=2 ** (WIDTH-2);
    reg [31:0] ram[RAM_SIZE-1:0];

    wire [`Word] addr={addr_in[31:2],2'b0};
    assign byte_select = addr_in[1:0];
    
    integer i;
    initial
    begin
        for(i=0;i<RAM_SIZE-1;i=i+1)
            ram[i]<=0;
    end
    
    wire [`Half] ram_h1,ram_h0;
    wire [`Byte] ram_b3,ram_b2,ram_b1,ram_b0;

    assign {ram_h1,ram_h0}=ram[addr];
    assign {ram_b3,ram_b2,ram_b1,ram_b0}=ram[addr];

    // Exception
    assign ExcOccur = (
        (type==4'b0000 && byte_select!=2'b00)||
        ((type==4'b0010 || type==4'b0011)&&byte_select[0]!=1'b0)

    )?1:0;

    assign ExcCode = ExcOccur?(we?`EXC_ADES:`EXC_ADEL):5'b00000;

    // read
    
    wire wl_out=(byte_select==0)?{ram_b0,24'b0}:
                (byte_select==1)?{ram_h0,16'b0}:
                (byte_select==2)?{ram_b2,ram_h0,8'b0}:
                ram[addr];
    wire wr_out=(byte_select==0)?ram[addr]:
                (byte_select==1)?{8'b0,ram_h1,ram_b1}:
                (byte_select==2)?{16'b0,ram_h1}:
                {24'b0,ram_b3};
    assign rd = (type==4'b0110)?wl_out:
                (type==4'b0111)?wr_out:
                ram[addr];
    assign rd_extend_type=(type==4'b0010)?3'b001:(type==4'b0011)?3'b010:
                          (type==4'b0100)?3'b011:(type==4'b0101)?3'b100:
                          3'b000;

    // write
    always @(posedge clk)
        begin
            if(reset)
                begin
                    for(i=0;i<RAM_SIZE-1;i=i+1)
                    ram[i]<=0;
                end
            else if(we==1 && ExcOccur!=1)
            begin
                $display("%d@%h: *%h <= %h", $time, PC, addr_in,wd);
                case (type)
                    4'b0000 :   // Word
                        ram[addr]<=wd;
                    4'b0010 : // Half
                        case (byte_select)
                            2'b00: ram[addr]<={ram_h1,wd[`Half0]};
                            2'b10: ram[addr]<={wd[`Half0],ram_h0};
                        endcase
                    4'b0100 : // Byte
                        case (byte_select)
                            2'b00: ram[addr]<={ram_h1,ram_b1,wd[`Byte0]};
                            2'b01: ram[addr]<={ram_h1,wd[`Byte0],ram_b0};
                            2'b10: ram[addr]<={ram_b3,wd[`Byte0],ram_h0};
                            2'b11: ram[addr]<={wd[`Byte0],ram_b2,ram_h0};
                        endcase
                    4'b0110 : // WL
                        case (byte_select)
                            2'b00: ram[addr]<={ram_h1,ram_b1,wd[`Byte3]};
                            2'b01: ram[addr]<={ram_h1,wd[`Half1]};
                            2'b10: ram[addr]<={ram_b3,wd[`Half1],wd[`Byte1]};
                            2'b11: ram[addr]<=wd;
                        endcase
                    4'b0111 : // WR
                        case (byte_select)
                            2'b00: ram[addr]<=wd;
                            2'b01: ram[addr]<={wd[`Byte2],wd[`Half0],ram_b0};
                            2'b10: ram[addr]<={wd[`Half0],ram_h0};
                            2'b11: ram[addr]<={wd[`Byte0],ram_b2,ram_h0};
                        endcase
                endcase
            end
        end
endmodule // 
`endif