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
         LikelyD,
         IgnoreExcRID,
         ERETD,
         cpzWriteD,
         cpztoRegD;
    wire [3:0] ALUCtrlD;
    wire [3:0] JudgeOpD;
    wire [2:0] DataTypeD;

    wire [2:0] MulOpD;
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
    wire [`Word] PC4E;
    wire MemtoRegE,
         MemWriteE,
         ALUASrcE,
         ALUSrcE,
         RegWriteE,
         RegDstE,
         ExtendE,
         JumpE,
         Jump_RE,
         LinkE,
         IgnoreExcRIE,
         cpzWriteE,
         cpztoRegE;
    wire [3:0] ALUCtrlE;
    wire [2:0] DataTypeE;
    wire [`Word] RD1E,
                 RD2E;
    wire [4:0] RsE,
               RtE,
               RdE;
    wire [4:0] cpzAddrE = RdE;
    wire [`Word] Imm_ExtendE,
                 Shamt_ExtendE;
    
    wire [2:0] MulOpE;
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
    wire [`Word] PC4M;
    wire MemtoRegM,
         MemWriteM,
         RegWriteM,
         cpzWriteM;
    wire [4:0] RegAddrM;
    wire [4:0] cpzAddrM;
    wire [`Word] ALUResM;
    wire [`Word] WriteDataM;
    wire [2:0] DataTypeM;
    
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
    wire pc_Exc,pc_ERET;

    // Exception
    wire ExcBDF,ExcBDD,ExcBDE,ExcBDM;
    wire ExcOccurF,ExcOccurD,ExcOccurE,ExcOccurM;
    wire [4:0] ExcCodeF,ExcCodeD,ExcCodeE,ExcCodeM;
    
    wire _ExcOccurE,_ExcOccurM;
    wire ExcOccurCUD,ExcOccurALUE,ExcOccurDMM;
    wire [4:0] _ExcCodeE,_ExcCodeM;
    wire [4:0] ExcCodeCUD,ExcCodeALUE,ExcCodeDMM;
    wire _ExcOccurD=0;
    wire [4:0] _ExcCodeD=5'b0;

    // CPZ
    wire [`Word] EPC;
    wire [`Word] cpzRD;

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
        .ExcOccur(pc_Exc),
        .ERET(pc_ERET),
        .PC(current_PCF),
        .B_addr(B_addrD),
        .J_addr(J_addrD),
        .RD(RD1D),
        .EPC(EPC),
        .PC4(PC4F),
        .nPC(nPCF),
        .ExcBD(ExcBDF)
    );

    assign PCF=current_PCF;
    IF_ID _if_id(
        .clk(clk),
        .reset(reset),
        .clr(Flush_IF_ID),
        .en(Stall_IF_ID),
        .InstF(InstF),
        .PC4F(PC4F),
        .ExcBDF(ExcBDF),
        .InstD(InstD),
        .PC4D(PC4D),
        .ExcBDD(ExcBDD),
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
        .MFHILO(MFHILOD),
        .IgnoreExcRI(IgnoreExcRID),
        .cpzWrite(cpzWriteD),
        .cpztoReg(cpztoRegD),
        .ERET(ERETD),

        .ExcOccur(ExcOccurCUD),
        .ExcCode(ExcCodeCUD)
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
        .clk(clk),
        .reset(reset),
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

    // Exception trans

    Mux2 #(5) _exccodeD_selector(
        .a0(ExcCodeCUD),
        .a1(_ExcCodeD),
        .select(_ExcOccurD),
        .out(ExcCodeD)
    );
    assign ExcOccurD=_ExcOccurD|ExcOccurCUD;

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
        .IgnoreExcRID(IgnoreExcRID),
        .cpzWriteD(cpzWriteD),
        .cpztoRegD(cpztoRegD),

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
        .IgnoreExcRIE(IgnoreExcRIE),
        .cpzWriteE(cpzWriteE),
        .cpztoRegE(cpztoRegE),

        .ExcBDD(ExcBDD),
        .ExcBDE(ExcBDE),
        .ExcOccurD(ExcOccurD),
        .ExcOccurE(_ExcOccurE),
        .ExcCodeD(ExcCodeD),
        .ExcCodeE(_ExcCodeE),

        .PC4D(PC4D),
        .PC4E(PC4E),
        .PCD(PCD),
        .PCE(PCE)
    );

    wire [`Word] _RD1E,_ALUAE,__ALUAE;
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
        .out(__ALUAE)
    );
    Mux2 #(`Word_Size) _ALU_srcA_cpz_selector(
        .a0(__ALUAE),
        .a1(cpzRD),
        .select(cpztoRegE),
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

    ALU _aluD(
        .SrcA(ALUAE),
        .SrcB(ALUBE),
        .ALUCtrl(ALUCtrlE),
        .IgnoreExcRI(IgnoreExcRIE),
        .ALURes(_ALUResE),
        .ExcOccur(ExcOccurALUE),
        .ExcCode(ExcCodeALUE)
    );

    Mux4 #(32) _mfhilo_selectorE(
        .a0(_ALUResE),
        .a1(LOE),
        .a2(HIE),
        .a3(32'bx),
        .select(MFHILOE),
        .out(ALUResE)
    );

    // Exception trans
    Mux2 #(5) _exccodeE_selector(
        .a0(ExcCodeALUE),
        .a1(_ExcCodeE),
        .select(_ExcOccurE),
        .out(ExcCodeE)
    );
    assign ExcOccurE=_ExcOccurE|ExcOccurALUE;
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
        .cpzWriteE(cpzWriteE),
        .cpzAddrE(cpzAddrE),

        .RegAddrM(RegAddrM),
        .WriteDataM(WriteDataM),
        .ALUResM(ALUResM),
        .MemtoRegM(MemtoRegM),
        .MemWriteM(MemWriteM),
        .DataTypeM(DataTypeM),
        .RegWriteM(RegWriteM),
        .cpzWriteM(cpzWriteM),
        .cpzAddrM(cpzAddrM),

        .ExcBDE(ExcBDE),
        .ExcBDM(ExcBDM),
        .ExcOccurE(ExcOccurE),
        .ExcOccurM(_ExcOccurM),
        .ExcCodeE(ExcCodeE),
        .ExcCodeM(_ExcCodeM),

        .PC4E(PC4E),
        .PC4M(PC4M),
        .PCE(PCE),
        .PCM(PCM)
    );

    wire DMWE = ~ExcOccurM & MemWriteM;
    DM  _dm(
        .clk(clk_re),
        .reset(reset),
        .we(MemWriteM),
        .type(DataTypeM),
        .addr_in(ALUResM),
        .wd(DMWE),
        .rd(MemRDM),
        .PC(PCM),
        .rd_extend_type(MemRDSelM),
        .byte_select(ByteSelM),
        .ExcOccur(ExcOccurDMM),
        .ExcCode(ExcCodeDMM)
    );

    // Exception selector
    assign ExcOccurM=_ExcOccurM|ExcOccurDMM;
    Mux2 #(5) _exccodeM_selector(
        .a0(ExcCodeDMM),
        .a1(_ExcCodeM),
        .select(_ExcOccurM),
        .out(ExcCodeM)
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

    wire cpzWE = ~ExcOccurM & cpzWriteM;
    CPZ _cpz(
        .clk(clk),
        .reset(reset),
        .r_addr(cpzAddrE),
        .w_addr(cpzAddrM),
        .we(cpzWE),
        .wd(WriteDataM),
        .PC4D(PC4D),
        .PC4M(PC4M),
        .ExcOccur(ExcOccurM),
        .ExcBD(ExcBDM),
        .ExcCode(ExcCodeM),
        .ERET(ERETD),
        .EPC(EPC),
        .DataOut(cpzRD)
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
        .ExcOccurM(ExcOccurM),
        .ERET(ERETD),
        .pc_Exc(pc_Exc),
        .pc_ERET(pc_ERET),
        .Stall_PC(Stall_PC),
        .Stall_IF_ID(Stall_IF_ID),
        .Stall_ID_EX(Stall_ID_EX),
        .Stall_EX_MEM(Stall_EX_MEM),
        .Stall_MEM_WB(Stall_MEM_WB),
        .Flush_IF_ID(Flush_IF_ID),
        .Flush_ID_EX(Flush_ID_EX)
    );
endmodule // mips