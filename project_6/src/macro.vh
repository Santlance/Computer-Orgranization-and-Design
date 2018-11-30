/*
 * Instructions and ALU operations
 * author: btapple
 */

// Instructions

`define Inst_OP     31:26
`define Inst_RS     25:21
`define Inst_RT     20:16
`define Inst_RD     15:11
`define Inst_S      10:6
`define Inst_Funct   5:0
`define Inst_J      25:0
`define Inst_Imm    15:0

`define Low5         4:0

`define Word        31:0
`define Half        15:0
`define Byte         7:0

`define Byte0        7:0
`define Byte1       15:8
`define Byte2       23:16
`define Byte3       31:24

`define Half0       15:0
`define Half1       31:16

`define Word_Size   32
`define Half_Size   16
`define Byte_Size   8

// R_Type
`define R_Type  6'b000000   // OpCode
`define ADD     6'b100000   // Funct
`define ADDU    6'b100001   // Funct
`define AND     6'b100100   // Funct
`define NOR     6'b100111   // Funct
`define OR      6'b100101   // Funct
`define SLL     6'b000000   // Funct
`define SLLV    6'b000100   // Funct
`define SLT     6'b101010   // Funct
`define SLTU    6'b101011   // Funct
`define SRA     6'b000011   // Funct
`define SRAV    6'b000111   // Funct
`define SRL     6'b000010   // Funct
`define SRLV    6'b000110   // Funct
`define SUB     6'b100010   // Funct
`define SUBU    6'b100011   // Funct
`define XOR     6'b100110   // Funct
`define MOVZ    6'b001010   // Funct
`define MOVN    6'b001011   // Funct
`define MULT    6'b011000   // Funct
`define MULTU   6'b011001   // Funct
`define DIV     6'b011010   // Funct
`define DIVU    6'b011011   // Funct
`define MFHI    6'b010000   // FUnct
`define MFLO    6'b010010   // Funct
`define MTHI    6'b010001   // Funct
`define MTLO    6'b010011   // Funct

// Load
`define LB      6'b100000   // OpCode
`define LBU     6'b100100   // OpCode
`define LH      6'b100001   // OpCode
`define LHU     6'b100101   // OpCode
`define LW      6'b100011   // OpCode
`define LWL     6'b100010   // OpCode
`define LWR     6'b100110   // OpCode

// Save
`define SB      6'b101000   // OpCode
`define SH      6'b101001   // OpCode
`define SW      6'b101011   // OpCode
`define SWL     6'b101010   // OpCode
`define SWR     6'b101110   // OpCode

// Branch
`define BEQ     6'b000100   // OpCode
`define BNE     6'b000101   // OpCode
`define BGTZ    6'b000111   // OpCode
`define BLEZ    6'b000110   // OpCode
`define BEQL    6'b010100   // OpCode
`define BNEL    6'b010101   // OpCode

// Special-Branch
`define BGEZ_OP 6'b000001   // OpCode
`define BGEZ_RT 5'b00001    // BGEZ
`define BLTZ_OP 6'b000001   // OpCode
`define BLTZ_RT 5'b00000    // BLTZ

// J_Type
`define J       6'b000010   // OpCode
`define JAL     6'b000011   // OpCode
`define JALR    6'b001001   // Funct
`define JR      6'b001000   // Funct

// I_Type
`define ADDI    6'b001000   // OpCode
`define ADDIU   6'b001001   // OpCode
`define ANDI    6'b001100   // OpCode
`define LUI     6'b001111   // OpCode
`define ORI     6'b001101   // OpCode
`define SLTI    6'b001010   // OpCode
`define SLTIU   6'b001011   // OpCode
`define XORI    6'b001110   // OpCode

// ALU operations

`define ALU_ADD 4'b0000     // ADD
`define ALU_SUB 4'b0001     // SUB
`define ALU_AND 4'b0010     // AND
`define ALU_OR  4'b0011     // OR
`define ALU_XOR 4'b0100     // XOR
`define ALU_NOR 4'b0101     // NOR
`define ALU_SLL 4'b0110     // SLL
`define ALU_SRA 4'b0111     // SRA
`define ALU_SRL 4'b1000     // SRL
`define ALU_LUI 4'b1001     // LUI
`define ALU_LT  4'b1010     // Less than, signed
`define ALU_LTU 4'b1011     // Less than, unsigned, (0||SrcA)<(0||SrcB)

// Judge operations

`define EQ    4'b0000     // EQ
`define NE    4'b0001     // NE
`define GTZ   4'b0010     // GTZ
`define LEZ   4'b0011     // LEZ
`define GEZ   4'b0100     // GEZ
`define LTZ   4'b0101     // LTZ

// Forward

`define FW_NONED 2'b00       // No forward
`define FW_MD    2'b01       // MEM to ID
`define FW_WD    2'b10       // WB to ID


`define FW_NONEE 2'b00
`define FW_ME    2'b01       // MEM to EXE
`define FW_WE    2'b10       // WB to EXE
