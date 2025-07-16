`ifndef DEFINES_SV
`define DEFINES_SV

// Data width parameters
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 32;
parameter REG_ADDR_WIDTH = 5;
parameter OPCODE_WIDTH = 7;
parameter FUNCT3_WIDTH = 3;
parameter FUNCT7_WIDTH = 7;

// Instruction formats
typedef struct packed {
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;
} r_type_t;

typedef struct packed {
    logic [11:0] imm;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;
} i_type_t;

typedef struct packed {
    logic [6:0] imm_11_5;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] imm_4_0;
    logic [6:0] opcode;
} s_type_t;

typedef struct packed {
    logic imm_12;
    logic [5:0] imm_10_5;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [3:0] imm_4_1;
    logic imm_11;
    logic [6:0] opcode;
} b_type_t;

typedef struct packed {
    logic [19:0] imm;
    logic [4:0] rd;
    logic [6:0] opcode;
} u_type_t;

typedef struct packed {
    logic imm_20;
    logic [9:0] imm_10_1;
    logic imm_11;
    logic [7:0] imm_19_12;
    logic [4:0] rd;
    logic [6:0] opcode;
} j_type_t;

// Opcodes
parameter [6:0] OP_LUI    = 7'b0110111;
parameter [6:0] OP_AUIPC  = 7'b0010111;
parameter [6:0] OP_JAL    = 7'b1101111;
parameter [6:0] OP_JALR   = 7'b1100111;
parameter [6:0] OP_BRANCH = 7'b1100011;
parameter [6:0] OP_LOAD   = 7'b0000011;
parameter [6:0] OP_STORE  = 7'b0100011;
parameter [6:0] OP_IMM    = 7'b0010011;
parameter [6:0] OP_REG    = 7'b0110011;

// ALU operations
typedef enum logic [3:0] {
    ALU_ADD  = 4'b0000,
    ALU_SUB  = 4'b0001,
    ALU_SLL  = 4'b0010,
    ALU_SLT  = 4'b0011,
    ALU_SLTU = 4'b0100,
    ALU_XOR  = 4'b0101,
    ALU_SRL  = 4'b0110,
    ALU_SRA  = 4'b0111,
    ALU_OR   = 4'b1000,
    ALU_AND  = 4'b1001
} alu_op_t;

// Control signals
typedef struct packed {
    logic reg_write;
    logic [1:0] reg_write_src;
    logic alu_src;
    alu_op_t alu_op;  // Changed from logic [3:0] to alu_op_t
    logic mem_read;
    logic mem_write;
    logic branch;
    logic jump;
    logic [2:0] mem_size;
} control_signals_t;

`endif