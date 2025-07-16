`include "../utils/defines.sv"

module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output control_signals_t control
);

    always_comb begin
        // Default values
        control.reg_write = 1'b0;
        control.reg_write_src = 2'b00;
        control.alu_src = 1'b0;
        control.alu_op = ALU_ADD;
        control.mem_read = 1'b0;
        control.mem_write = 1'b0;
        control.branch = 1'b0;
        control.jump = 1'b0;
        control.mem_size = 3'b010; // Default to word size
        
        case (opcode)
            OP_LUI: begin
                control.reg_write = 1'b1;
                control.reg_write_src = 2'b11; // Immediate
                control.alu_op = ALU_ADD;
            end
            
            OP_AUIPC: begin
                control.reg_write = 1'b1;
                control.reg_write_src = 2'b00; // ALU result
                control.alu_src = 1'b1; // Immediate
                control.alu_op = ALU_ADD;
            end
            
            OP_JAL: begin
                control.reg_write = 1'b1;
                control.reg_write_src = 2'b10; // PC+4
                control.jump = 1'b1;
            end
            
            OP_JALR: begin
                control.reg_write = 1'b1;
                control.reg_write_src = 2'b10; // PC+4
                control.jump = 1'b1;
                control.alu_src = 1'b1; // Immediate
            end
            
            OP_BRANCH: begin
                control.branch = 1'b1;
                control.alu_op = ALU_SUB;
            end
            
            OP_LOAD: begin
                control.reg_write = 1'b1;
                control.reg_write_src = 2'b01; // Memory
                control.mem_read = 1'b1;
                control.alu_src = 1'b1; // Immediate
                control.alu_op = ALU_ADD;
                control.mem_size = funct3;
            end
            
            OP_STORE: begin
                control.mem_write = 1'b1;
                control.alu_src = 1'b1; // Immediate
                control.alu_op = ALU_ADD;
                control.mem_size = funct3;
            end
            
            OP_IMM: begin
                control.reg_write = 1'b1;
                control.reg_write_src = 2'b00; // ALU result
                control.alu_src = 1'b1; // Immediate
                
                case (funct3)
                    3'b000: control.alu_op = ALU_ADD;  // ADDI
                    3'b010: control.alu_op = ALU_SLT;  // SLTI
                    3'b011: control.alu_op = ALU_SLTU; // SLTIU
                    3'b100: control.alu_op = ALU_XOR;  // XORI
                    3'b110: control.alu_op = ALU_OR;   // ORI
                    3'b111: control.alu_op = ALU_AND;  // ANDI
                    3'b001: control.alu_op = ALU_SLL;  // SLLI
                    3'b101: control.alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL; // SRAI/SRLI
                    default: control.alu_op = ALU_ADD;
                endcase
            end
            
            OP_REG: begin
                control.reg_write = 1'b1;
                control.reg_write_src = 2'b00; // ALU result
                
                case (funct3)
                    3'b000: control.alu_op = (funct7[5]) ? ALU_SUB : ALU_ADD; // SUB/ADD
                    3'b001: control.alu_op = ALU_SLL;  // SLL
                    3'b010: control.alu_op = ALU_SLT;  // SLT
                    3'b011: control.alu_op = ALU_SLTU; // SLTU
                    3'b100: control.alu_op = ALU_XOR;  // XOR
                    3'b101: control.alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL; // SRA/SRL
                    3'b110: control.alu_op = ALU_OR;   // OR
                    3'b111: control.alu_op = ALU_AND;  // AND
                    default: control.alu_op = ALU_ADD;
                endcase
            end
            
            default: begin
                // All signals already set to default values
            end
        endcase
    end

endmodule