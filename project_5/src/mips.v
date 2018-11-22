`include "./macro.vh"
`include "./controller.v"
`include "./alu.v"
`include "./branch.v"
`include "./dm.v"
`include "./ext.v"
`include "./grf.v"
`include "./im.v"
`include "./mux.v"
`include "./npc.v"
`include "./pc.v"
`include "./inst.v"
`include "./IF_ID.v"
`include "./ID_EX.v"
`include "./EX_MEM.v"
`include "./MEM_WB.v"
`timescale 1ns / 1ps
// TODO:: 修改Branch
module mips(
    input clk,
    input reset
);
    // 流水线寄存器控制信号
    reg clr_if_id,
        clr_id_ex,
        clr_ex_mem,
        clr_mem_wb;
    reg en_if_id,
        en_id_ex,
        en_ex_mem,
        en_mem_wb;

    // IF
    wire [`Word] nPCF;
    wire [`Word] current_PCF;
    wire [`Word] InstF;
    wire [`Word] PC4F;

    // ID
    wire [`Word]        InstD;
    wire [`Word]        PC4D;
    wire [`Inst_OP]     OpD;
    wire [`Inst_RS]     RsD;
    wire [`Inst_RT]     RtD;
    wire [`Inst_RD]     RdD;
    wire [`Inst_Imm]    ImmD;
    wire [`Inst_S]      ShamtD;
    wire [`Inst_Funct]  FunctD;
    wire [`Inst_J]      J_IndexD;

    wire MemtoRegD,
         MemWriteD,
         BranchD,
         ALUASrcD,
         ALUSrcD,
         RegDstD,
         RegWriteD,
         ExtendD,
         JumpD,
         Jump_RD,
         LinkD;
    wire [3:0] ALUCtrlD;
    wire [3:0] BranchOpD;
    wire [2:0] DataTypeD;

    wire [`Word] RD1D,
                 RD2D;

    wire [`Word] Imm_ExtendD,
                 Shamt_ExtendD,
                 J_addrD,
                 B_addrD;
    wire branchD;

    // EXE
    wire MemtoRegE,
         MemWriteE,
         ALUASrcE,
         ALUSrcE,
         RegWriteE,
         RegDstE,
         ExtendE,
         JumpE,
         Jump_RE,
         LinkE;
    wire [3:0] ALUCtrlE;
    wire [2:0] DataTypeE;
    wire [`Word] RD1E,
                 RD2E;
    wire [4:0] RsE,
               RtE,
               RdE;
    wire [`Word] Imm_ExtendE,
                 Shamt_ExtendE;
    
    wire [`Word] ALUAE,
                 ALUBE,
                 ALUResE;
    wire [4:0] RegAddrE;

    // MEM
    wire MemtoRegM,
         MemWriteM,
         RegWriteM;
    wire [4:0] RegAddrM;
    wire [`Word] ALUResM;
    wire [`Word] WriteDataM;
    wire [2:0] DataTypeM;

    wire [`Word] MemRDM;

    // WB
    wire MemtoRegW,
         RegWriteW;
    wire [`Word] ALUResW,
                 MemRDW,
                 RegDataW;
    wire [4:0] RegAddrW;

    // test
    wire [`Word] PCF,PCD,PCE,PCM;
    PC _pcF(
        .clk(clk),
        .reset(reset),
        .nPC(nPCF),
        .PC(current_PCF)
    );

    IM _imF(
        .addr(current_PCF),
        .Inst(InstF)
    );

    NPC _npcF(
        .clk(clk),
        .Branch(branchD),
        .Jump(JumpD),
        .Jump_r(Jump_RD),
        .PC(current_PCF),
        .B_addr(B_addrD),
        .J_addr(J_addrD),
        .RD(RD1D),
        .PC4(PC4F),
        .nPC(nPCF)
    );

    IF_ID _if_id(
        .clk(clk),
        .reset(reset),
        .clr(clr_if_id),
        .en(en_if_id),
        .InstF(InstF),
        .PC4F(PC4F),
        .InstD(InstD),
        .PC4D(PC4D),
        .PCF(PCF),
        .PCD(PCD)
    );

    Inst_Filter _inst_filterD(
        .inst(InstD),
        .op(OpD),
        .rs(RsD),
        .rt(RtD),
        .rd(RdD),
        .imm(ImmD),
        .shamt(ShamtD),
        .funct(FunctD),
        .j_index(J_IndexD)
    );

    ControlUnit _controlunitD(
        .inst(InstD),
        .MemtoReg(MemtoRegD),
        .MemWrite(MemWriteD),
        .Branch(BranchD),
        .BranchOp(BranchOpD),
        .ALUCtrl(ALUCtrlD),
        .ALUASrc(ALUASrcD),
        .ALUSrc(ALUSrcD),
        .RegDst(RegDstD),
        .RegWrite(RegWriteD),
        .Extend(ExtendD),
        .Jump(JumpD),
        .Jump_R(Jump_RD),
        .Link(LinkD),
        .DataType(DataTypeD)
    );

    GRF _grfD(
        .clk(clk),
        .reset(reset),
        .we(RegWriteW),
        .A1(RsD),
        .A2(RtD),
        .A3(RegAddrW),
        .wd(RegDataW),
        .r1(RD1D),
        .r2(RD2D),
        .PC(PCD)
    );

    Branch _branchD(
        .SrcA(RD1D),
        .SrcB(RD2D),
        .Branch(BranchD),
        .BranchOp(BranchOpD),
        .PC4(PC4D),
        .Imm(ImmD),
        .pc_branch(branchD),
        .B_addr(B_addrD)
    );

    assign J_addrD={PC4D[31:28],J_IndexD,2'b00};

    EXT #(16,32) _imm_extenderD(
        .in(ImmD),
        .type(ExtendD),
        .out(Imm_ExtendD)
    );

    zero_extend #(5,32) _shamt_extenderD(
        .in(ShamtD),
        .out(Shamt_ExtendD)
    );

    ID_EX _id_ex(
        .clk(clk),
        .reset(reset),
        .clr(clr_id_ex),
        .en(en_if_id),
        .MemtoRegD(MemtoRegD),
        .MemWriteD(MemWriteD),
        .BranchD(BranchD),
        .BranchOpD(BranchOpD),
        .ALUCtrlD(ALUCtrlD),
        .ALUASrcD(ALUASrcD),
        .ALUSrcD(ALUSrcD),
        .RegDstD(RegDstD),
        .RegWriteD(RegWriteD),
        .ExtendD(ExtendD),
        .JumpD(JumpD),
        .Jump_RD(Jump_RD),
        .LinkD(LinkD),
        .DataTypeD(DataTypeD),
        .RD1D(RD1D),
        .RD2D(RD2D),
        .RsD(RsD),
        .RtD(RtD),
        .RdD(RdD),
        .Imm_ExtendD(Imm_ExtendD),
        .Shamt_ExtendD(Shamt_ExtendD),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .ALUCtrlE(ALUCtrlE),
        .ALUASrcE(ALUASrcE),
        .ALUSrcE(ALUSrcE),
        .RegWriteE(RegWriteE),
        .RegDstE(RegDstE),
        .ExtendE(ExtendE),
        .JumpE(JumpE),
        .Jump_RE(Jump_RE),
        .LinkE(LinkE),
        .DataTypeE(DataTypeE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .RsE(RsE),
        .RtE(RtE),
        .RdE(RdE),
        .Imm_ExtendE(Imm_ExtendE),
        .Shamt_ExtendE(Shamt_ExtendE),
        .PCD(PCD),
        .PCE(PCE)
    );

    Mux2 #(`Word_Size) _ALU_srcA_selector(
        .a0(RD1E),
        .a1(Shamt_ExtendE),
        .select(ALUASrcE),
        .out(ALUAE)
    );

    Mux2 #(`Word_Size) _ALU_srcB_selector(
        .a0(RD2E),
        .a1(Imm_ExtendE),
        .select(ALUSrcE),
        .out(ALUBE)
    );

    Mux2 #(5) _regaddr_selector(
        .a0(RtE),
        .a1(RdE),
        .select(RegDstE),
        .out(RegAddrE)
    );

    ALU _aluD(
        .SrcA(ALUAE),
        .SrcB(ALUBE),
        .ALUCtrl(ALUCtrlE),
        .ALURes(ALUResE)
    );

    EX_MEM _ex_mem(
        .clk(clk),
        .reset(reset),
        .clr(clr_ex_mem),
        .en(en_ex_mem),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .RegWriteE(RegWriteE),
        .RegAddrE(RegAddrE),
        .WriteDataE(ALUBE),
        .DataTypeE(DataTypeE),
        .ALUResE(ALUResE),
        .RegAddrM(RegAddrM),
        .WriteDataM(WriteDataM),
        .ALUResM(ALUResM),
        .MemtoRegM(MemtoRegM),
        .MemWriteM(MemWriteM),
        .DataTypeM(DataTypeM),
        .RegWriteM(RegWriteM),
        .PCE(PCE),
        .PCM(PCM)
    );

    DM  _dm(
        .clk(clk),
        .reset(reset),
        .we(MemWriteM),
        .type(DataTypeM),
        .addr(ALUResM),
        .wd(WriteDataM),
        .rd(MemRDM),
        .PC(PCM)
    );
    MEM_WB _mem_wb(
        .clk(clk),
        .reset(reset),
        .clr(clr_mem_wb),
        .en(en_mem_wb),
        .MemtoRegM(MemtoRegM),
        .RegWriteM(RegWriteM),
        .MemRDM(MemRDM),
        .ALUResM(ALUResM),
        .RegAddrM(RegAddrM),
        .MemtoRegW(MemtoRegW),
        .RegWriteW(RegWriteW),
        .MemRDW(MemRDW),
        .ALUResW(ALUResW),
        .RegAddrW(RegAddrW)
    );
    Mux2 #(32) _memtoreg_selector(
        .a0(ALUResW),
        .a1(MemRDW),
        .select(MemtoRegW),
        .out(RegDataW)
    );
endmodule // mips