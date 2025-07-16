`include "../utils/defines.sv"

module instruction_memory #(
    parameter MEM_SIZE = 1024 // Number of 32-bit words
)(
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] instruction
);

    logic [7:0] memory [MEM_SIZE*4-1:0]; // Byte-addressable
    
    // Initialize with some test instructions
    initial begin
        // Simple test program
        // ADDI x1, x0, 10    (Load immediate 10 into x1)
        {memory[3], memory[2], memory[1], memory[0]} = 32'h00a00093;
        
        // ADDI x2, x0, 20    (Load immediate 20 into x2)
        {memory[7], memory[6], memory[5], memory[4]} = 32'h01400113;
        
        // ADD x3, x1, x2     (Add x1 and x2, store in x3)
        {memory[11], memory[10], memory[9], memory[8]} = 32'h002081b3;
        
        // SW x3, 0(x0)       (Store x3 to memory address 0)
        {memory[15], memory[14], memory[13], memory[12]} = 32'h00302023;
        
        // LW x4, 0(x0)       (Load from memory address 0 to x4)
        {memory[19], memory[18], memory[17], memory[16]} = 32'h00002203;
        
        // BEQ x3, x4, 4      (Branch if x3 equals x4)
        {memory[23], memory[22], memory[21], memory[20]} = 32'h00418263;
        
        // Initialize rest of memory to NOPs
        for (int i = 24; i < MEM_SIZE*4; i += 4) begin
            {memory[i+3], memory[i+2], memory[i+1], memory[i]} = 32'h00000013; // NOP (ADDI x0, x0, 0)
        end
    end
    
    // Read operation - always enabled for instruction fetch
    always_comb begin
        instruction = {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]};
    end

endmodule