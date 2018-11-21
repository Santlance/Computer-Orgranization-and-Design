`ifndef __CONTROLLER_V__
`define __CONTROLLER_V__
`include "./macro.vh"
`timescale 1ns / 1ps
module ControlUnit(
    input clk,
    input reset,
    input [`Word] inst,
    output reg MemtoReg,
    output reg MemWrite,
    output reg Branch,
    output reg [3:0] BranchOp,
    output reg [3:0] ALUCtrl,
    output reg ALUASrc,
    output reg ALUSrc,
    output reg RegDst,
    output reg RegWrite,
    output reg Extend,
    output reg Jump,
    output reg Jump_R,
    output reg Link,
    output reg [2:0] DataType,   // 000:Word 010:Half 100:Byte
    output reg PCWrite
);
    wire [5:0] Op=inst[`Inst_OP];
    wire [4:0] Rt=inst[`Inst_RT];
    wire [5:0] Funct=inst[`Inst_Funct];

    reg [3:0]state,next_state;

    parameter S0  = 4'b0000;
    parameter S1  = 4'b0001;
    parameter S2  = 4'b0010;
    parameter S3  = 4'b0011;
    parameter S4  = 4'b0100;
    parameter S5  = 4'b0101;
    parameter S6  = 4'b0110;
    parameter S7  = 4'b0111;
    parameter S8  = 4'b1000;
    parameter S9  = 4'b1001;
    parameter S10 = 4'b1010;
    parameter S11 = 4'b1011;
    parameter S12 = 4'b1100;
    parameter S13 = 4'b1101;
    parameter S14 = 4'b1110;
    parameter S15 = 4'b1111;

    initial
    begin
        state=S0;
        next_state=S0;
    end

    always @(posedge clk)
    begin
        state=next_state;
        if(reset)
            begin
                MemtoReg=0;
                MemWrite=0;
                Branch=0;
                BranchOp=0;
                ALUCtrl=0;
                ALUASrc=0;
                ALUSrc=0;
                RegDst=0;
                RegWrite=0;
                Extend=0;
                Jump=0;
                Jump_R=0;
                Link=0;
                DataType=0;
                PCWrite=1;
                
                state=S0;
                next_state=S0;
            end
        else
        case (state)
            S0:         // Instruction Fetch 
            begin
                MemtoReg=0;
                MemWrite=0;
                Branch=0;
                BranchOp=0;
                ALUCtrl=0;
                ALUASrc=0;
                ALUSrc=0;
                RegDst=0;
                RegWrite=0;
                Extend=0;
                Jump=0;
                Jump_R=0;
                Link=0;
                DataType=0;
                
                next_state=S1;
                PCWrite=0;
            end
            S1:         // Decode
            begin
                PCWrite=0;       
                case (Op)
                `R_Type:    // R-Type
                begin
                    case (Funct)
                        `JR:
                            next_state=S10;
                        `JALR:
                            next_state=S11; 
                        default: 
                            next_state=S2;
                    endcase
                end
                `LW,`SW,`LH,`LHU,`SH,`LB,`LBU,`SB:  // Load/Save
                    next_state=S4;
                `ORI,`LUI:                          // I-Type
                    next_state=S7;
                `BEQ,`BNE,`BGTZ,`BLEZ,`BGEZ_OP:     // Branch
                    next_state=S9;
                `J:
                    next_state=S10;
                `JAL:
                    next_state=S11;
                default: 
                    next_state=S0;
                endcase
            end
            S2:
            begin
                ALUSrc=0;
                next_state=S3;
                case (Funct)
                    `ADDU:
                        begin
                            ALUCtrl=`ALU_ADD;
                        end
                    `SUBU:
                        begin
                            ALUCtrl=`ALU_SUB;
                        end
                endcase
            end
            S3:
            begin
                RegDst=1;
                RegWrite=1;
                PCWrite=1;
                next_state=S0;
            end
            S4:
            begin
                ALUSrc=1;
                ALUCtrl=`ALU_ADD;
                case (Op)
                    `LW,`SW:
                        DataType=3'b000;
                    `LHU,`SH:
                        DataType=3'b010;
                    `LH:
                        DataType=3'b011;
                    `LBU,`SB:
                        DataType=3'b100;
                    `LB:
                        DataType=3'b101;
                endcase
                case (Op)
                    `LW,`LHU,`LH,`LBU,`LB:
                        next_state=S5;
                    default:
                        next_state=S6;
                endcase
            end
            S5:             // Load
            begin
                RegDst=0;
                MemtoReg=1;
                RegWrite=1;
                PCWrite=1;
                next_state=S0;
            end
            S6:             // Save
            begin
                MemWrite=1;
                PCWrite=1;
                next_state=S0;
            end
            S7:             // I-Type
            begin
                ALUSrc=1;
                next_state=S8;
                case (Op)
                    `ORI:
                        begin
                            ALUCtrl=`ALU_OR;
                            Extend=0;
                        end 
                    `LUI:
                        begin
                            ALUCtrl=`ALU_LUI;
                            Extend=0;
                        end
                endcase
            end
            S8:
            begin
                RegDst=0;
                RegWrite=1;
                PCWrite=1;
                next_state=S0;
            end
            S9:
            begin
                Branch=1;
                PCWrite=1;
                next_state=S0;
                case (Op)
                    `BEQ:
                        BranchOp=`B_EQ;
                    `BNE:
                        BranchOp=`BNE;
                    `BGTZ:
                        BranchOp=`B_GTZ;
                    `BLEZ:
                        BranchOp=`B_LEZ;
                    default: 
                        if(Op==`BGEZ_OP && Rt==`BGEZ_RT)
                            BranchOp=`B_GEZ;
                        else 
                            BranchOp=`B_LTZ;
                endcase
            end
            S10:
            begin
                PCWrite=1;
                next_state=S0;
                case (Op)
                    `J:
                        Jump=1;
                    default:
                        Jump_R=1;
                endcase
            end
            S11:
            begin
                next_state=S12;
                case (Op)
                    `JAL: 
                        begin
                            Jump=1;
                            Link=1;
                        end
                    default: 
                        begin
                            RegDst=1;
                            Jump_R=1;
                            Link=1;
                        end
                endcase
            end
            S12:
            begin
                PCWrite=1;
                RegWrite=1;
                next_state=S0;
            end
        endcase
    end
endmodule // ControlUnit
`endif