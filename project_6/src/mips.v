`include "./macro.vh"
`include "./controller.v"
`include "./alu.v"
`include "./branch.v"
`include "./dm.v"
`include "./ext.v"
`include "./judge.v"
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
`include "./bypass.v"
`include "./multiplier.v"
`timescale 1ns / 1ps

module mips(
    input clk,
    input reset
);
    // EX/MEM/WB
    wire clk_re=~clk;

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
    wire [`Inst_RD]     _RdD;
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
         LinkD,
         JudgeMoveD,
         LikelyD;
    wire [3:0] ALUCtrlD;
    wire [3:0] JudgeOpD;
    wire [3:0] DataTypeD;

    wire [3:0] MulOpD;
    wire [1:0] MFHILOD;
    wire [1:0] MTHILOD;

    wire [`Word] RD1D,
                 RD2D,
                 JudgeAD;

    wire [`Word] Imm_ExtendD,
                 Shamt_ExtendD,
                 J_addrD,
                 B_addrD,
                 PC8D;
    wire JudgeResD,
         branchD;

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
    wire [3:0] DataTypeE;
    wire [`Word] RD1E,
                 RD2E;
    wire [4:0] RsE,
               RtE,
               RdE;
    wire [`Word] Imm_ExtendE,
                 Shamt_ExtendE;
    
    wire [3:0] MulOpE;
    wire [1:0] MFHILOE;
    wire [1:0] MTHILOE;
    wire Mul_BusyE;

    wire [`Word] ALUAE,
                 ALUBE,
                 ALUResE,
                 PC8E,
                 HIE,
                 LOE,
                 _ALUResE;
    wire [4:0] RegAddrE;

    // MEM
    wire MemtoRegM,
         MemWriteM,
         RegWriteM;
    wire [4:0] RegAddrM;
    wire [`Word] ALUResM;
    wire [`Word] WriteDataM;
    wire [3:0] DataTypeM;

    wire [`Word] MemRDM;
    wire [2:0] MemRDSelM;
    wire [1:0] ByteSelM;
    // WB
    wire MemtoRegW,
         RegWriteW;
    wire [`Word] ALUResW,
                 MemRDW,
                 RegDataW,
                 MemRD_ExtendW;
    wire [4:0] RegAddrW;
    wire [2:0] MemRDSelW;
    wire [1:0] ByteSelW;
    // Bypass
    wire [1:0] Forward_A_D,
               Forward_B_D,
               Forward_A_E,
               Forward_B_E;
    wire Stall_PC,
         Stall_IF_ID;
    wire Stall_ID_EX=0,
         Stall_EX_MEM=0,
         Stall_MEM_WB=0;
    wire Flush_EX_MEM=0,
         Flush_MEM_WB=0;
    wire Flush_IF_ID,
         Flush_ID_EX;

    // test
    wire [`Word] PCF,PCD,PCE,PCM,PCW;

    PC _pcF(
        .clk(clk),
        .reset(reset),
        .we(Stall_PC),
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

    assign PCF=current_PCF;
    IF_ID _if_id(
        .clk(clk),
        .reset(reset),
        .clr(Flush_IF_ID),
        .en(Stall_IF_ID),
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
        .rd(_RdD),
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
        .JudgeOp(JudgeOpD),
        .ALUCtrl(ALUCtrlD),
        .ALUASrc(ALUASrcD),
        .ALUSrc(ALUSrcD),
        .RegDst(RegDstD),
        .RegWrite(RegWriteD),
        .Extend(ExtendD),
        .Jump(JumpD),
        .Jump_R(Jump_RD),
        .Link(LinkD),
        .DataType(DataTypeD),
        .JudgeMove(JudgeMoveD),
        .Likely(LikelyD),
        .MulOp(MulOpD),
        .MTHILO(MTHILOD),
        .MFHILO(MFHILOD)
    );

    wire [`Word] _RD1D,_RD2D;
    GRF _grfD(
        .clk(clk),
        .reset(reset),
        .we(RegWriteW),
        .A1(RsD),
        .A2(RtD),
        .A3(RegAddrW),
        .wd(RegDataW),
        .r1(_RD1D),
        .r2(_RD2D),
        .PC(PCW)
    );

    Mux4 #(32) _RD1D_forward_selector(
        .a0(_RD1D),
        .a1(ALUResM),
        .a2(RegDataW),
        .a3(32'bx),
        .select(Forward_A_D),
        .out(RD1D)
    );
    Mux4 #(32) _RD2D_forward_selector(
        .a0(_RD2D),
        .a1(ALUResM),
        .a2(RegDataW),
        .a3(32'bx),
        .select(Forward_B_D),
        .out(RD2D)
    );

    Mux2 #(32) _judge_srcB_selector(
        .a0(RD1D),
        .a1(32'b0),
        .select(JudgeMoveD),
        .out(JudgeAD)
    );
    Judge _judge(
        .SrcA(JudgeAD),
        .SrcB(RD2D),
        .JudgeOp(JudgeOpD),
        .JudgeRes(JudgeResD)
    );
    wire JudgeMoveSelD = JudgeMoveD & (~JudgeResD);
    Mux2 #(5) _judge_rd_selector(
        .a0(_RdD),
        .a1(5'b0),
        .select(JudgeMoveSelD),
        .out(RdD)
    );

    Branch _branchD(
        .Branch(BranchD),
        .JudgeRes(JudgeResD),
        .J_Index(J_IndexD),
        .PC4(PC4D),
        .Imm(ImmD),
        .pc_branch(branchD),
        .B_addr(B_addrD),
        .J_addr(J_addrD),
        .PC8(PC8D)
    );

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
        .clr(Flush_ID_EX),
        .en(Stall_ID_EX),
        .MemtoRegD(MemtoRegD),
        .MemWriteD(MemWriteD),
        .ALUCtrlD(ALUCtrlD),
        .ALUASrcD(ALUASrcD),
        .ALUSrcD(ALUSrcD),
        .RegDstD(RegDstD),
        .RegWriteD(RegWriteD),
        .ExtendD(ExtendD),
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
        .PC8D(PC8D),
        .MulOpD(MulOpD),
        .MTHILOD(MTHILOD),
        .MFHILOD(MFHILOD),

        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .ALUCtrlE(ALUCtrlE),
        .ALUASrcE(ALUASrcE),
        .ALUSrcE(ALUSrcE),
        .RegWriteE(RegWriteE),
        .RegDstE(RegDstE),
        .ExtendE(ExtendE),
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
        .PC8E(PC8E),
        .MulOpE(MulOpE),
        .MTHILOE(MTHILOE),
        .MFHILOE(MFHILOE),

        .PCD(PCD),
        .PCE(PCE)
    );

    wire [`Word] _RD1E,_ALUAE;
    Mux4 #(`Word_Size) _ALUAE_forward_selector(
        .a0(RD1E),
        .a1(ALUResM),
        .a2(RegDataW),
        .a3(32'bx),
        .select(Forward_A_E),
        .out(_RD1E)
    );
    Mux2 #(`Word_Size) _ALU_srcA_shamt_selector(
        .a0(_RD1E),
        .a1(Shamt_ExtendE),
        .select(ALUASrcE),
        .out(_ALUAE)
    );
    Mux2 #(`Word_Size) _ALU_srcA_link_selector(
        .a0(_ALUAE),
        .a1(PC8E),
        .select(LinkE),
        .out(ALUAE)
    );

    wire [`Word] _RD2E;
    Mux4 #(`Word_Size) _ALUBE_forward_selector(
        .a0(RD2E),
        .a1(ALUResM),
        .a2(RegDataW),
        .a3(32'bx),
        .select(Forward_B_E),
        .out(_RD2E)
    );
    Mux2 #(`Word_Size) _ALU_srcB_selector(
        .a0(_RD2E),
        .a1(Imm_ExtendE),
        .select(ALUSrcE),
        .out(ALUBE)
    ); 

    wire [4:0] _RegAddrE;
    Mux2 #(5) _regdst_selector(
        .a0(RtE),
        .a1(RdE),
        .select(RegDstE),
        .out(_RegAddrE)
    );

    wire Link_SelectE=LinkE&(~Jump_RE);
    Mux2 #(5) _reglink_selector(
        .a0(_RegAddrE),
        .a1(5'b11111),
        .select(Link_SelectE),
        .out(RegAddrE)
    );
    
    Multiplier _multiplier(
        .clk(clk_re),
        .reset(reset),
        .MTHILO(MTHILOE),
        .SrcA(ALUAE),
        .SrcB(ALUBE),
        .MulOp(MulOpE),
        .HI(HIE),
        .LO(LOE),
        .busy(Mul_BusyE)
    );

    ALU _aluE(
        .SrcA(ALUAE),
        .SrcB(ALUBE),
        .ALUCtrl(ALUCtrlE),
        .ALURes(_ALUResE)
    );

    Mux4 #(32) _mfhilo_selectorE(
        .a0(_ALUResE),
        .a1(LOE),
        .a2(HIE),
        .a3(32'bx),
        .select(MFHILOE),
        .out(ALUResE)
    );

    EX_MEM _ex_mem(
        .clk(clk_re),
        .reset(reset),
        .clr(Flush_EX_MEM),
        .en(Stall_EX_MEM),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .RegWriteE(RegWriteE),
        .RegAddrE(RegAddrE),
        .WriteDataE(_RD2E),
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
        .clk(clk_re),
        .reset(reset),
        .we(MemWriteM),
        .type(DataTypeM),
        .addr_in(ALUResM),
        .wd(WriteDataM),
        .rd(MemRDM),
        .PC(PCM),
        .rd_extend_type(MemRDSelM),
        .byte_select(ByteSelM)
    );

    MEM_WB _mem_wb(
        .clk(clk_re),
        .reset(reset),
        .clr(Flush_MEM_WB),
        .en(Stall_MEM_WB),
        .MemtoRegM(MemtoRegM),
        .RegWriteM(RegWriteM),
        .MemRDM(MemRDM),
        .MemRDSelM(MemRDSelM),
        .ByteSelM(ByteSelM),
        .ALUResM(ALUResM),
        .RegAddrM(RegAddrM),

        .MemtoRegW(MemtoRegW),
        .RegWriteW(RegWriteW),
        .MemRDW(MemRDW),
        .MemRDSelW(MemRDSelW),
        .ByteSelW(ByteSelW),
        .ALUResW(ALUResW),
        .RegAddrW(RegAddrW),

        .PCM(PCM),
        .PCW(PCW)
    );
    
    MEMRD_EXT _memrd_ext(
        .in(MemRDW),
        .type(MemRDSelW),
        .byte_select(ByteSelW),
        .out(MemRD_ExtendW)
    );

    Mux2 #(32) _memtoreg_selector(
        .a0(ALUResW),
        .a1(MemRD_ExtendW),
        .select(MemtoRegW),
        .out(RegDataW)
    );

    // Hazard Bypass
    BYPASS _bypass(
        .RsD(RsD),
        .RtD(RtD),
        .RsE(RsE),
        .RtE(RtE),
        .RegAddrW(RegAddrW),
        .RegAddrM(RegAddrM),
        .RegAddrE(RegAddrE),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .Forward_A_D(Forward_A_D),
        .Forward_B_D(Forward_B_D),
        .Forward_A_E(Forward_A_E),
        .Forward_B_E(Forward_B_E),
        .MemtoRegE(MemtoRegE),
        .branchD(branchD),
        .LikelyD(LikelyD),
        .MulOpD(MulOpD),
        .Mul_BusyE(Mul_BusyE),
        .MTHILOD(MTHILOD),
        .MFHILOD(MFHILOD),
        .Stall_PC(Stall_PC),
        .Stall_IF_ID(Stall_IF_ID),
        .Stall_ID_EX(Stall_ID_EX),
        .Stall_EX_MEM(Stall_EX_MEM),
        .Stall_MEM_WB(Stall_MEM_WB),
        .Flush_IF_ID(Flush_IF_ID),
        .Flush_ID_EX(Flush_ID_EX)
    );
endmodule // mips