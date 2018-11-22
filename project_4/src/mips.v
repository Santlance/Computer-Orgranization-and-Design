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
`timescale 1ns / 1ps
module mips(
    input clk,
    input reset,
    output [`Word] ALURes
);
    wire [`Word] Inst;      // 当前指令
    wire [`Word] nPC;       // 下一个PC值
    wire [`Word] current_PC;// 当前PC
    wire [`Word] branch_imm;
    wire branch;
    wire [`Word] PC4;
    wire [`Word] ALUA;
    wire [`Word] ALUB;
    wire [`Inst_OP]Inst_op;
    wire [`Inst_RS]Inst_rs;
    wire [`Inst_RT]Inst_rt;
    wire [`Inst_RD]Inst_rd;
    wire [`Inst_Imm]Inst_imm;
    wire [`Inst_S]Inst_shamt;
    wire [`Inst_Funct]Inst_funct;
    wire [`Inst_J]Inst_J;
    wire MemtoReg;
    wire MemWrite;
    wire [3:0] ALUCtrl;
    wire ALUASrc;
    wire ALUSrc;
    wire RegDst;
    wire RegWrite;
    wire Inst_Branch;
    wire [3:0] BranchOp;
    wire Extend;
    wire Jump;
    wire Jump_R;
    wire Link;
    wire [2:0]DataType;
    wire [`Word]RD1;
    wire [`Word]RD2;
    wire [4:0]RegAddr;
    wire [`Word]RegData;
    wire [`Word]imm_extend;
    wire ALUZero;
    wire [`Word]MemRD;
    wire [`Word] ALURes;

    //IM及其输入输出开始（指令存储）
    IM _im(
        .addr(current_PC), // 当前PC值
        .Inst(Inst)     // 当前指令
    );
    // IM及其输入输出结束

    // PC及其输入输出开始
    PC _pc(
        .clk(clk),
        .reset(reset),  // 清零至0x0000_3000
        .nPC(nPC),
        .PC(current_PC) // 当前PC值
    );
    // PC及其输入输出结束

    // NPC及其输入输出开始
    wire [17:0] branch_imm_temp=Inst_imm<<2;
    sign_extend #(18,32) _branch_imm_extender
    (
        .in(branch_imm_temp),   
        .out(branch_imm)
    );
    NPC _nPC(
        .clk(clk),
        .branch(branch),
        .jump(Jump),
        .jump_r(Jump_R),
        .PC(current_PC),
        .imm(branch_imm),
        .J_Index(Inst_J),
        .RD(RD1),
        .PC4(PC4),
        .nPC(nPC)
    );
    // NPC及其输入输出结束
    // Branch及其输入输出开始
    Branch _branch(
        .SrcA(ALUA),
        .SrcB(ALUB),
        .Branch(Inst_Branch),
        .BranchOp(BranchOp),
        .pc_branch(branch)
    );
    // Branch及其输入输出结束
    // Inst及其输入输出开始（指令分选）
    Inst_Fitter _inst(
        .inst(Inst),
        .op(Inst_op),
        .rs(Inst_rs),
        .rt(Inst_rt),
        .rd(Inst_rd),
        .imm(Inst_imm),
        .shamt(Inst_shamt),
        .funct(Inst_funct),
        .j_index(Inst_J)
    );
    // Inst及其输入输出结束

    // ControllerUnit及其输入输出开始
    ControlUnit _controlunit(
        .inst(Inst),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .Branch(Inst_Branch),
        .BranchOp(BranchOp),
        .ALUCtrl(ALUCtrl),
        .ALUASrc(ALUASrc),
        .ALUSrc(ALUSrc),
        .RegDst(RegDst),
        .RegWrite(RegWrite),
        .Extend(Extend),
        .Jump(Jump),
        .Jump_R(Jump_R),
        .Link(Link),
        .DataType(DataType)
    );
    // ControllerUnit及其输入输出结束

    // GRF及其输入输出开始
    GRF _grf(
        .clk(clk),  // 时钟信号
        .reset(reset),  // 复位信号
        .we(RegWrite),  // 寄存器写使能
        .A1(Inst_rs),
        .A2(Inst_rt),
        .A3(RegAddr),
        .wd(RegData),
        .PC(current_PC),
        .r1(RD1),
        .r2(RD2)
    );
    // GRF及其输入输出结束

    // GRF写入地址选择开始
    wire [4:0] _RegAddr;
    Mux2 #(5) _RegDst_Selector(
        .a0(Inst_rt),
        .a1(Inst_rd),
        .select(RegDst),
        .out(_RegAddr)
    );

    wire Link_Select=Link&(~Jump_R);

    Mux2 #(5) _RegLink_Selector(
        .a0(_RegAddr),
        .a1(5'b11111),
        .select(Link_Select),
        .out(RegAddr)
    );
    // GRF写入地址选择结束

    // GRF与ALU连接开始
    wire [`Word] s_extend;
    zero_extend #(5,`Word_Size) _shamt_extender(
        .in(Inst_shamt),
        .out(s_extend)
    );
    Mux2 #(`Word_Size) _ALUSrcA_Selector(
        .a0(RD1),
        .a1(s_extend),
        .select(ALUASrc),
        .out(ALUA)
    );
    Mux2 #(`Word_Size) _ALUSrcB_Selector(
        .a0(RD2),
        .a1(imm_extend),
        .select(ALUSrc),
        .out(ALUB)
    );
    // GRF与ALU连接结束

    // 立即数扩展开始
    EXT #(`Half_Size,`Word_Size) _imm_ext
    (
        .in(Inst_imm),
        .out(imm_extend),
        .type(Extend)
    );
    // 立即数扩展结束

    // ALU及其输入输出开始
    ALU _alu(
        .SrcA(ALUA),
        .SrcB(ALUB),
        .ALUCtrl(ALUCtrl),
        .ALURes(ALURes),
        .Zero(ALUZero)
    );
    // ALU及其输入输出结束

    // DM及其输入输出开始
    DM _dm(
        .clk(clk),
        .reset(reset),
        .we(MemWrite),
        .type(DataType),
        .addr_in(ALURes),
        .wd(RD2),
        .PC(current_PC),
        .rd(MemRD)
    );
    // DM及其输入输出结束

    // GRF回写来源选择开始
    wire [`Word] _RegData;
    Mux2 #(`Word_Size) _MemtoReg_Selector(
        .a0(ALURes),
        .a1(MemRD),
        .select(MemtoReg),
        .out(_RegData)
    );
    Mux2 #(`Word_Size) _RegData_Link_Selector(
        .a0(_RegData),
        .a1(PC4),
        .select(Link),
        .out(RegData)
    );
    // GRF回写来源选择结束

    
endmodule // mips