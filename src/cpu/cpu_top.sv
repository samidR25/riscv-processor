`include "../utils/defines.sv"

module cpu_top (
    input  logic clk,
    input  logic rst_n
);

    // Program Counter
    logic [ADDR_WIDTH-1:0] pc, next_pc;
    
    // Instruction fetch
    logic [DATA_WIDTH-1:0] instruction;
    
    // Instruction decode
    logic [REG_ADDR_WIDTH-1:0] rs1_addr, rs2_addr, rd_addr;
    logic [DATA_WIDTH-1:0] rs1_data, rs2_data;
    logic [DATA_WIDTH-1:0] immediate;
    
    // Control signals
    control_signals_t control;
    
    // ALU
    logic [DATA_WIDTH-1:0] alu_operand_a, alu_operand_b;
    logic [DATA_WIDTH-1:0] alu_result;
    logic alu_zero, alu_less_than, alu_less_than_unsigned;
    
    // Memory
    logic [DATA_WIDTH-1:0] mem_read_data;
    
    // Write back
    logic [DATA_WIDTH-1:0] reg_write_data;
    
    // Branch/Jump logic
    logic branch_taken;
    // Removed unused branch_target signal
    
    // Program Counter logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h00000000;
        end else begin
            pc <= next_pc;
        end
    end
    
    // Next PC calculation
    always_comb begin
        if (control.jump) begin
            if (instruction[6:0] == OP_JAL) begin
                next_pc = pc + immediate;
            end else begin // JALR
                next_pc = (rs1_data + immediate) & ~32'h1;
            end
        end else if (control.branch && branch_taken) begin
            next_pc = pc + immediate;
        end else begin
            next_pc = pc + 4;
        end
    end
    
    // Branch taken logic
    always_comb begin
        case (instruction[14:12]) // funct3
            3'b000: branch_taken = alu_zero;           // BEQ
            3'b001: branch_taken = !alu_zero;          // BNE
            3'b100: branch_taken = alu_less_than;      // BLT
            3'b101: branch_taken = !alu_less_than;     // BGE
            3'b110: branch_taken = alu_less_than_unsigned; // BLTU
            3'b111: branch_taken = !alu_less_than_unsigned; // BGEU
            default: branch_taken = 1'b0;
        endcase
    end
    
    // Instruction decode
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign rd_addr = instruction[11:7];
    
    // Immediate generation
    always_comb begin
        case (instruction[6:0])
            OP_IMM, OP_LOAD, OP_JALR: begin // I-type
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            OP_STORE: begin // S-type
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            OP_BRANCH: begin // B-type
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], 
                            instruction[30:25], instruction[11:8], 1'b0};
            end
            OP_LUI, OP_AUIPC: begin // U-type
                immediate = {instruction[31:12], 12'b0};
            end
            OP_JAL: begin // J-type
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], 
                            instruction[20], instruction[30:21], 1'b0};
            end
            default: immediate = 32'b0;
        endcase
    end
    
    // ALU operands
    assign alu_operand_a = (instruction[6:0] == OP_AUIPC) ? pc : rs1_data;
    assign alu_operand_b = control.alu_src ? immediate : rs2_data;
    
    // Write back data selection
    always_comb begin
        case (control.reg_write_src)
            2'b00: reg_write_data = alu_result;     // ALU result
            2'b01: reg_write_data = mem_read_data;  // Memory
            2'b10: reg_write_data = pc + 4;         // PC+4
            2'b11: reg_write_data = immediate;      // Immediate (LUI)
            default: reg_write_data = 32'b0;
        endcase
    end
    
    // Module instantiations
    instruction_memory imem (
        .addr(pc),
        .instruction(instruction)
    );
    
    register_file regfile (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_addr(rd_addr),
        .rd_data(reg_write_data),
        .reg_write(control.reg_write)
    );
    
    control_unit ctrl (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .control(control)
    );
    
    alu alu_inst (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_op(control.alu_op),
        .result(alu_result),
        .zero(alu_zero),
        .less_than(alu_less_than),
        .less_than_unsigned(alu_less_than_unsigned)
    );
    
    data_memory dmem (
        .clk(clk),
        .addr(alu_result),
        .write_data(rs2_data),
        .mem_read(control.mem_read),
        .mem_write(control.mem_write),
        .mem_size(control.mem_size),
        .read_data(mem_read_data)
    );

endmodule