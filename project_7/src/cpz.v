`ifndef __CPZ_V__
`define __CPZ_V__
`include "./macro.vh"
`include "./mux.v"
`timescale 1ns / 1ps
module CPZ(
    input clk,
    input reset,

    input [4:0] addr,
    input we,
    input [`Word] wd,
    input [`Word] PC4M,
    input ExcOccur,
    input ExcBD,
    input [4:0] ExcCodeM,
    input ERET,
    input [5:0] HWInt,

    output ExcHandle,
    output reg [`Word] EPC,
    output [`Word] DataOut
);
    
    reg [`Word] SR,                         // 12
                Cause,                      // 13
                //EPC,                      // 14
                PRId;                       // 15

    // SR begin
    localparam SR_INIT=32'h0000ff11;

    wire StatusIE = SR[0];                  // Interrupt Enable. 1: permit, 2: prohibit
    wire StatusEXL = SR[1];                 // Exception Level. 1: prohibit, 2: permit
    wire [5:0] StatusIM = SR[15:10];
    wire [7:0] StatusIM_ALL = SR[15:8];     // Interrupt Mask, [1:0] internal written by software, [7:2] external. 1: permit, 2: prohibit
    // SR end

    // Cause begin
    wire CauseBD = Cause [31];              // Branch Delay
    wire [5:0] CauseIP = Cause[15:10];
    wire [7:0] CauseIP_ALL = Cause[15:8];   // Interrupt Pending
    wire [4:0] CauseExcCode = Cause[6:2];   // Exception Code
    // Cause end

    // EPC begin
    wire [`Word] PC4M_Align = {PC4M[31:2],2'b0};
    // EPC end
    wire [4:0] ExcCode = (|(Cause[15:10] & StatusIM))?5'b0:ExcCodeM;

    assign ExcHandle = ~StatusEXL && ( ( |ExcCodeM) || (StatusIE & ( |(CauseIP & StatusIM))));

    assign DataOut = (addr==12)?SR:
                     (addr==13)?Cause:
                     (addr==14)?EPC:
                     (addr==15)?PRId:
                     0;
    initial
    begin
        SR<=SR_INIT;
        Cause<=0;
        EPC<=0;
        PRId<=114514;
    end

    always @(posedge clk)
    begin
        if(reset)
            begin
                SR<=SR_INIT;
                Cause<=0;
                EPC<=0;
                PRId<=114514;
            end
        else 
        begin
            Cause[15:10]<=HWInt;
            if(ExcHandle)
            begin
                if(ExcBD==1'b1)
                    EPC<=PC4M_Align - 8;
                else EPC<=PC4M_Align - 4;
                SR[1]<=1;
                Cause[6:2]<=ExcCode;
                Cause[31]<=ExcBD;
                // Cause[15:10]<=HWInt;
            end
            else if(ERET==1'b1)
                SR[1]<=0;
            else if(we)
                case (addr)
                    12: SR<=wd;
                    14: EPC<=wd;
                endcase
        end
    end
endmodule // CPZ
`endif
