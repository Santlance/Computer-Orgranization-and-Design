/*
 * name: core
 * author: btapple
 */

`ifndef __CORE_V__
`define __CORE_V__
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
`include "./mdu.v"
`include "./cpz.v"
`timescale 1ns / 1ps

module Core(
    input clk,
    input clk2,
    input reset,

    input [`Word] PrRD,
    input [5:0] HWInt,
    output [15:0] PrAddr,
    output [`Word] PrWD,
    output PrWE,
    output [3:0] PrBE,
    output [6:0] PrHIT
    // output [`Word] PrPC
);
    // EX/MEM/WB
    // wire clk_re=~clk;

    // IF
    wire [`Word] nPCF;
    wire [`Word] current_PCF;
    wire [`Word] OriginalInstF;
    wire [`Word] InstF;
    wire [`Word] PC4F;
    wire [15:0] PC3K;
    // ID
    wire [`Word]        InstD;
    wire [`Word]        PC4D;
    // wire [`Inst_OP]     OpD;
    wire [`Inst_RS]     RsD;
    wire [`Inst_RT]     RtD;
    wire [`Inst_RD]     RdD;
    wire [`Inst_RD]     Rd_OriginalD;
    wire [`Inst_Imm]    ImmD;
    wire [`Inst_S]      ShamtD;
    // wire [`Inst_Funct]  FunctD;
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
        //  MDU_ResultD,
         IgnoreExcRID,
         ERETD,
         cpzWriteD,
         cpztoRegD;
    wire [4:0] RegAddrD;
    wire [3:0] ALUCtrlD;
    wire [3:0] JudgeOpD;
    wire [3:0] DataTypeD;

    // wire [3:0] MDUOpD;
    // wire [1:0] MFHILOD;
    // wire [1:0] MTHILOD;

    wire [`Word] RD1D,
                 RD2D,
                 JudgeAD;

    wire [`Word] Imm_ExtendD,
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
        //  ExtendE,
         Jump_RE,
         LinkE,
         IgnoreExcRIE,
         cpzWriteE,
         cpztoRegE,
         ERETE;
    wire [4:0] ShamtE;
    wire [4:0] cpzAddrE = RdE;
    wire [3:0] ALUCtrlE;
    wire [3:0] DataTypeE;
    wire [`Word] RD1E,
                 RD2E;
    wire [4:0] RsE,
               RtE,
               RdE;
    
    wire [`Word] Imm_ExtendE;
    
    // wire MDUCLR;
    // wire [3:0] MDUOpE;
    // wire [1:0] MFHILOE;
    // wire [1:0] MTHILOE;
    // wire [1:0] MDU_Result_StallE;
    // wire MDUBusyE,MDU_ResultE;
    wire [`Word] ALUAE,
                 ALUBE,
                 ALUResE,
                 PC8E,
                 HIE,
                 LOE,
                 ALURes_OriginalE;
    wire [4:0] RegAddrE;

    // MEM
    wire [`Word] PC4M;
    wire MemtoRegM,
         MemWriteM,
         RegWriteM,
         cpztoRegM,
         cpzWriteM;
    // wire [3:0] MDUOpM;
    wire [4:0] RegAddrM;
    wire [4:0] cpzAddrM;
    wire [`Word] ALUResM;
    wire [`Word] RegDataM;
    wire [`Word] WriteDataM;
    wire [3:0] DataTypeM;
    
    wire [`Word] MemRDM;
    wire [3:0] MemRDSelM;
    wire [1:0] ByteSelM;

    wire ERETM;

    // WB
    wire MemtoRegW,
         RegWriteW;
    wire [`Word] MemRDW,
                 RegDataW,
                 MemRD_ExtendW,
                 RegWriteDataW;
    wire [4:0] RegAddrW;
    wire [3:0] MemRDSelW;
    wire [1:0] ByteSelW;

    // Bypass
    wire [1:0] Forward_A_D,
               Forward_B_D,
               Forward_A_E,
               Forward_B_E;
    wire Forward_EPC;
    wire Stall_PC,
         Stall_IF_ID,
         Stall_ID_EX,
         Stall_EX_MEM,
         Stall_MEM_WB;
    wire Flush_EX_MEM,
         Flush_MEM_WB;
    wire Flush_IF_ID,
         Flush_ID_EX;
    wire pc_Exc,pc_ERET;

    // Exception
    wire ExcHandle;

    wire ExcBDF,ExcBDD,ExcBDE,ExcBDM;
    wire ExcOccurF,ExcOccurD,ExcOccurE,ExcOccurM;
    wire [4:0] ExcCodeF,ExcCodeD,ExcCodeE,ExcCodeM;
    
    wire Before_ExcOccurD,Before_ExcOccurE,Before_ExcOccurM;
    wire ExcOccurCUD,ExcOccurALUE,ExcOccurDMM;
    wire [4:0] ExcCodeCUD,ExcCodeDMM;
    wire [4:0] Before_ExcCodeD,Before_ExcCodeE,Before_ExcCodeM;

    // CPZ
    
    wire [`Word] cpzWriteDataM = WriteDataM;
    wire [`Word] EPC,
                 EPC_Forward;
    wire [`Word] cpzRD;

    // test
    // wire [`Word] PCF,PCD,PCE,PCM;

    PC _pcF(
        .clk(clk),
        .reset(reset),
        .stall(Stall_PC),
        .ERET(pc_ERET),
        .ExcHandle(pc_Exc),
        .nPC(nPCF),
        .EPC(EPC_Forward),
        .current_PC(current_PCF),
        .PC3K(PC3K),
        .ExcOccur(ExcOccurF),
        .ExcCode(ExcCodeF)
    );
    
    IM _imF(
        .clk(clk2),
        .addr_in(PC3K),
        .Inst(OriginalInstF)
    );
    assign InstF = (ExcOccurF)?32'b0:
                               OriginalInstF;

    NPC _npcF(
        .Branch(branchD),
        .Jump(JumpD),
        .Jump_r(Jump_RD),
        .ExcHandle(ExcHandle),
        .PC(current_PCF),
        .B_addr(B_addrD),
        .J_addr(J_addrD),
        .RD(RD1D),
        .PC4(PC4F),
        .nPC(nPCF),
        .ExcBD(ExcBDF)
    );

    // assign PCF = current_PCF;

    IF_ID _if_id(
        .clk(clk),
        .reset(reset),
        .clr(Flush_IF_ID),
        .stall(Stall_IF_ID),
        .InstF(InstF),
        .PC4F(PC4F),
        .ExcBDF(ExcBDF),
        .ExcOccurF(ExcOccurF),
        .ExcCodeF(ExcCodeF),

        .InstD(InstD),
        .PC4D(PC4D),
        .ExcBDD(ExcBDD),
        .ExcOccurD(Before_ExcOccurD),
        .ExcCodeD(Before_ExcCodeD)
        // .PCF(PCF),
        // .PCD(PCD)
    );

    Inst_Filter _inst_filterD(
        .inst(InstD),
        // .op(OpD),
        .rs(RsD),
        .rt(RtD),
        .rd(Rd_OriginalD),
        .imm(ImmD),
        .shamt(ShamtD),
        // .funct(FunctD),
        .j_index(J_IndexD)
    );

    ControlUnit _controlunitD(
        .inst_in(InstD),

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
        // .MDUOp(MDUOpD),
        // .MTHILO(MTHILOD),
        // .MFHILO(MFHILOD),
        // .MDU_Result(MDU_ResultD),
        .IgnoreExcRI(IgnoreExcRID),
        .cpzWrite(cpzWriteD),
        .cpztoReg(cpztoRegD),
        .ERET(ERETD),

        .ExcOccur(ExcOccurCUD),
        .ExcCode(ExcCodeCUD)
    );

    wire [`Word] RD1_OriginalD,RD2_OriginalD;
    GRF _grfD(
        .clk(clk),
        .reset(reset),
        .we(RegWriteW),
        .A1(RsD),
        .A2(RtD),
        .A3(RegAddrW),
        .wd(RegWriteDataW),
        .r1(RD1_OriginalD),
        .r2(RD2_OriginalD)
    );

    Mux3 #(32) _RD1D_forward_selector(
        .a0(RD1_OriginalD),
        .a1(ALUResM),
        .a2(RegWriteDataW),
        .select(Forward_A_D),
        .out(RD1D)
    );
    Mux3 #(32) _RD2D_forward_selector(
        .a0(RD2_OriginalD),
        .a1(ALUResM),
        .a2(RegWriteDataW),
        .select(Forward_B_D),
        .out(RD2D)
    );

    // Mux2 #(32) _judge_srcB_selector(
    //     .a0(RD1D),
    //     .a1(32'b0),
    //     .select(JudgeMoveD),
    //     .out(JudgeAD)
    // );

    Judge _judge(
        .SrcA(RD1D),
        .SrcB(RD2D),
        .JudgeOp(JudgeOpD),
        .JudgeRes(JudgeResD)
    );

    wire JudgeMoveSelD = JudgeMoveD & (~JudgeResD);
    Mux2 #(5) _judge_rd_selector(
        .a0(Rd_OriginalD),
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

    wire [4:0] RegAddr_RegdstD;
    Mux2 #(5) _regdst_selector(
        .a0(RtD),
        .a1(RdD),
        .select(RegDstD),
        .out(RegAddr_RegdstD)
    );

    wire Link_SelectD=LinkD&(~Jump_RD);
    Mux2 #(5) _reglink_selector(
        .a0(RegAddr_RegdstD),
        .a1(5'b11111),
        .select(Link_SelectD),
        .out(RegAddrD)
    );

    EXT #(16,32) _imm_extenderD(
        .in(ImmD),
        .type(ExtendD),
        .out(Imm_ExtendD)
    );

    // Exception trans

    Mux2 #(5) _exccodeD_selector(
        .a0(ExcCodeCUD),
        .a1(Before_ExcCodeD),
        .select(Before_ExcOccurD),
        .out(ExcCodeD)
    );

    assign ExcOccurD = Before_ExcOccurD | ExcOccurCUD;

    ID_EX _id_ex(
        .clk(clk),
        .reset(reset),
        .clr(Flush_ID_EX),
        .stall(Stall_ID_EX),
        .MemtoRegD(MemtoRegD),
        .MemWriteD(MemWriteD),
        .ALUCtrlD(ALUCtrlD),
        .ALUASrcD(ALUASrcD),
        .ALUSrcD(ALUSrcD),
        .RegWriteD(RegWriteD),
        // .ExtendD(ExtendD),
        .LinkD(LinkD),
        .DataTypeD(DataTypeD),
        .RD1D(RD1D),
        .RD2D(RD2D),
        .RsD(RsD),
        .RtD(RtD),
        .RdD(RdD),
        .RegAddrD(RegAddrD),
        .Imm_ExtendD(Imm_ExtendD),
        .ShamtD(ShamtD),
        .PC8D(PC8D),
        // .MDUOpD(MDUOpD),
        // .MTHILOD(MTHILOD),
        // .MFHILOD(MFHILOD),
        // .MDU_ResultD(MDU_ResultD),
        .IgnoreExcRID(IgnoreExcRID),
        .cpzWriteD(cpzWriteD),
        .cpztoRegD(cpztoRegD),

        .ERETD(ERETD),

        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .ALUCtrlE(ALUCtrlE),
        .ALUASrcE(ALUASrcE),
        .ALUSrcE(ALUSrcE),
        .RegWriteE(RegWriteE),
        // .ExtendE(ExtendE),
        .LinkE(LinkE),
        .DataTypeE(DataTypeE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .RsE(RsE),
        .RtE(RtE),
        .RdE(RdE),
        .RegAddrE(RegAddrE),
        .Imm_ExtendE(Imm_ExtendE),
        .ShamtE(ShamtE),
        .PC8E(PC8E),
        // .MDUOpE(MDUOpE),
        // .MTHILOE(MTHILOE),
        // .MFHILOE(MFHILOE),
        // .MDU_ResultE(MDU_ResultE),
        .IgnoreExcRIE(IgnoreExcRIE),
        .cpzWriteE(cpzWriteE),
        .cpztoRegE(cpztoRegE),
        .ERETE(ERETE),

        .ExcBDD(ExcBDD),
        .ExcBDE(ExcBDE),
        .ExcOccurD(ExcOccurD),
        .ExcOccurE(Before_ExcOccurE),
        .ExcCodeD(ExcCodeD),
        .ExcCodeE(Before_ExcCodeE),

        .PC4D(PC4D),
        .PC4E(PC4E)
        // .PCD(PCD),
        // .PCE(PCE)
    );

    // wire [`Word] RD1_ForwardE,
    //              ALUA_ShamtE;
    wire [`Word] Shamt_Link = (ALUASrcE) ? {27'b0,ShamtE}:
                                         PC8E;
    wire [1:0] ALUAE_select = ~(ALUASrcE | LinkE) ? Forward_A_E:
                                                    2'b11 ;
    Mux4 #(`Word_Size) _ALUAE_forward_selector(
        .a0(RD1E),
        .a1(RegDataM),
        .a2(RegWriteDataW),
        .a3(Shamt_Link),
        .select(ALUAE_select),
        .out(ALUAE)
    );

    // Mux2 #(`Word_Size) _ALU_srcA_shamt_selector(
    //     .a0(RD1_ForwardE),
    //     .a1({27'b0,ShamtE}),
    //     .select(ALUASrcE),
    //     .out(ALUA_ShamtE)
    // );
    // Mux2 #(`Word_Size) _ALU_srcA_link_selector(
    //     .a0(ALUA_ShamtE),
    //     .a1(PC8E),
    //     .select(LinkE),
    //     .out(ALUAE)
    // );

    wire [`Word] RD2_ForwardE;
    Mux3 #(`Word_Size) _ALUBE_forward_selector(
        .a0(RD2E),
        .a1(RegDataM),
        .a2(RegWriteDataW),
        .select(Forward_B_E),
        .out(RD2_ForwardE)
    );
    Mux2 #(`Word_Size) _ALU_srcB_selector(
        .a0(RD2_ForwardE),
        .a1(Imm_ExtendE),
        .select(ALUSrcE),
        .out(ALUBE)
    ); 

    /*
    MDU _mdu(
        .clk(clk_re),
        .reset(reset),
        .MDUCLR(MDUCLR),
        .ExcHandle(ExcHandle),
        .MTHILO(MTHILOE),
        .SrcA(ALUAE),
        .SrcB(ALUBE),
        .MDUOp(MDUOpE),
        // .MDU_Result(MDU_ResultE),
        .HI(HIE),
        .LO(LOE),
        .busy(MDUBusyE)
        // .MDU_Result_Stall(MDU_Result_StallE)
    );
    */
    ALU _aluE(
        .SrcA(ALUAE),
        .SrcB(ALUBE),
        .ALUCtrl(ALUCtrlE),
        .IgnoreExcRI(IgnoreExcRIE),
        .ALURes(ALUResE),
        .ExcOccur(ExcOccurALUE)
    );

    // assign ALUResE = ALURes_OriginalE;

    // Mux4 #(32) _mfhilo_selectorE(
    //     .a0(ALURes_OriginalE),
    //     .a1(LOE),
    //     .a2(HIE),
    //     .a3(32'b0),
    //     .select(MFHILOE),
    //     .out(ALUResE)
    // );

    // Exception trans
    wire [4:0] _ExcCodeE_Maybe_Rv;
    assign _ExcCodeE_Maybe_Rv = ExcOccurALUE?
                                (MemtoRegE?`EXC_ADEL:
                                 MemWriteE?`EXC_ADES:
                                 `EXC_OV):
                                 5'b00000;

    Mux2 #(5) _exccodeE_selector(
        .a0(_ExcCodeE_Maybe_Rv),
        .a1(Before_ExcCodeE),
        .select(Before_ExcOccurE),
        .out(ExcCodeE)
    );
    assign ExcOccurE = Before_ExcOccurE | ExcOccurALUE;

    EX_MEM _ex_mem(
        .clk(clk),
        .reset(reset),
        .clr(Flush_EX_MEM),
        .stall(Stall_EX_MEM),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .RegWriteE(RegWriteE),
        .RegAddrE(RegAddrE),
        .WriteDataE(RD2_ForwardE),
        .DataTypeE(DataTypeE),
        .ALUResE(ALUResE),
        // .MDUOpE(MDUOpE),
        .cpzWriteE(cpzWriteE),
        .cpztoRegE(cpztoRegE),
        .cpzAddrE(cpzAddrE),

        .RegAddrM(RegAddrM),
        .WriteDataM(WriteDataM),
        .ALUResM(ALUResM),
        .MemtoRegM(MemtoRegM),
        .MemWriteM(MemWriteM),
        .DataTypeM(DataTypeM),
        .RegWriteM(RegWriteM),
        // .MDUOpM(MDUOpM),
        .cpzWriteM(cpzWriteM),
        .cpztoRegM(cpztoRegM),
        .cpzAddrM(cpzAddrM),

        .ExcBDE(ExcBDE),
        .ExcBDM(ExcBDM),
        .ExcOccurE(ExcOccurE),
        .ExcOccurM(Before_ExcOccurM),
        .ExcCodeE(ExcCodeE),
        .ExcCodeM(Before_ExcCodeM),
        .ERETE(ERETE),
        .ERETM(ERETM),

        .PC4E(PC4E),
        .PC4M(PC4M)
        // .PCE(PCE),
        // .PCM(PCM)
    );

    Mux2 #(32) _regDataM_cpz_selector(
        .a0(ALUResM),
        .a1(cpzRD),
        .select(cpztoRegM),
        .out(RegDataM)
    );

    DM  _dm(
        .we(MemWriteM),
        .type(DataTypeM),
        .addr_in(ALUResM),
        .wd(WriteDataM),
        .PrRD(PrRD),
        .rd(MemRDM),
        // .PC(PCM),
        .rd_extend_type(MemRDSelM),
        .byte_select(ByteSelM),
        .PrAddr(PrAddr),
        .PrWD(PrWD),
        .PrWE(PrWE),
        .PrBE(PrBE),
        .PrHIT(PrHIT),
        .Before_ExcOccur(Before_ExcOccurM),
        .ExcOccur(ExcOccurDMM),
        .ExcCode(ExcCodeDMM)
        // .PrPC(PrPC)
    );

    // Exception selector
    assign ExcOccurM = Before_ExcOccurM | ExcOccurDMM;
    Mux2 #(5) _exccodeM_selector(
        .a0(ExcCodeDMM),
        .a1(Before_ExcCodeM),
        .select(Before_ExcOccurM),
        .out(ExcCodeM)
    );

    MEM_WB _mem_wb(
        .clk(clk),
        .reset(reset),
        .clr(Flush_MEM_WB),
        .stall(Stall_MEM_WB),
        .MemtoRegM(MemtoRegM),
        .RegWriteM(RegWriteM),
        .MemRDM(MemRDM),
        .MemRDSelM(MemRDSelM),
        .ByteSelM(ByteSelM),
        .RegDataM(RegDataM),
        .RegAddrM(RegAddrM),

        .MemtoRegW(MemtoRegW),
        .RegWriteW(RegWriteW),
        .MemRDW(MemRDW),
        .MemRDSelW(MemRDSelW),
        .ByteSelW(ByteSelW),
        .RegDataW(RegDataW),
        .RegAddrW(RegAddrW)
    );
    
    MEMRD_EXT _memrd_ext_selector(
        .MemIn(MemRDW),
        .RegIn(RegDataW),
        .type(MemRDSelW),
        .byte_select(ByteSelW),
        .MemtoReg(MemtoRegW),
        .out(RegWriteDataW)
    );

    // Mux2 #(32) _memtoreg_selector(
    //     .a0(RegDataW),
    //     .a1(MemRD_ExtendW),
    //     .select(MemtoRegW),
    //     .out(RegWriteDataW)
    // );

    wire cpzWE = cpzWriteM & ~ExcHandle;

    CPZ _cpz(
        .clk(clk),
        .reset(reset),
        .addr(cpzAddrM),
        .we(cpzWriteM),
        .wd(cpzWriteDataM),
        .PC4M(PC4M),
        .ExcOccur(ExcOccurM),
        .ExcBD(ExcBDM),
        .ExcCodeM(ExcCodeM),
        .HWInt(HWInt),
        .ERET(ERETM),
        .ExcHandle(ExcHandle),
        .EPC_out(EPC),
        .DataOut(cpzRD)
    );

    Mux2 #(`Word_Size) _EPC_forward_selector(
        .a0(EPC),
        .a1(ALUBE),
        .select(Forward_EPC),
        .out(EPC_Forward)
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
        .RegWriteE(RegWriteE),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .Forward_A_D(Forward_A_D),
        .Forward_B_D(Forward_B_D),
        .Forward_A_E(Forward_A_E),
        .Forward_B_E(Forward_B_E),
        .Forward_EPC(Forward_EPC),
        .MemtoRegM(MemtoRegM),
        .MemtoRegE(MemtoRegE),
        .JudgeOpD(JudgeOpD),
        .Jump_R(Jump_RD),
        .cpztoRegE(cpztoRegE),
        .cpztoRegM(cpztoRegM),
        // .branchD(branchD),
        // .LikelyD(LikelyD),
        // .MDUOpD(MDUOpD),
        // .MDUBusyE(MDUBusyE),
        // .MTHILOD(MTHILOD),
        // .MFHILOD(MFHILOD),
        // .MDUOpM(MDUOpM),
        .cpzWriteE(cpzWriteE),
        // .MDU_ResultE(MDU_ResultE),
        // .MDU_Result_Stall(MDU_Result_StallE),
        .ExcHandle(ExcHandle),
        .ERETD(ERETD),
        .pc_Exc(pc_Exc),
        .pc_ERET(pc_ERET),
        // .MDUCLR(MDUCLR),
        .Stall_PC(Stall_PC),
        .Stall_IF_ID(Stall_IF_ID),
        .Stall_ID_EX(Stall_ID_EX),
        .Stall_EX_MEM(Stall_EX_MEM),
        .Stall_MEM_WB(Stall_MEM_WB),
        .Flush_IF_ID(Flush_IF_ID),
        .Flush_ID_EX(Flush_ID_EX),
        .Flush_EX_MEM(Flush_EX_MEM),
        .Flush_MEM_WB(Flush_MEM_WB)
    );
endmodule // core
`endif