`include "../utils/defines.sv"

module alu (
    input  logic [DATA_WIDTH-1:0] operand_a,
    input  logic [DATA_WIDTH-1:0] operand_b,
    input  alu_op_t alu_op,
    output logic [DATA_WIDTH-1:0] result,
    output logic zero,
    output logic less_than,
    output logic less_than_unsigned
);

    always_comb begin
        case (alu_op)
            ALU_ADD:  result = operand_a + operand_b;
            ALU_SUB:  result = operand_a - operand_b;
            ALU_SLL:  result = operand_a << operand_b[4:0];
            ALU_SLT:  result = ($signed(operand_a) < $signed(operand_b)) ? 32'b1 : 32'b0;
            ALU_SLTU: result = (operand_a < operand_b) ? 32'b1 : 32'b0;
            ALU_XOR:  result = operand_a ^ operand_b;
            ALU_SRL:  result = operand_a >> operand_b[4:0];
            ALU_SRA:  result = $signed(operand_a) >>> operand_b[4:0];
            ALU_OR:   result = operand_a | operand_b;
            ALU_AND:  result = operand_a & operand_b;
            default:  result = 32'b0;
        endcase
    end
    
    assign zero = (result == 32'b0);
    assign less_than = $signed(operand_a) < $signed(operand_b);
    assign less_than_unsigned = operand_a < operand_b;

endmodule