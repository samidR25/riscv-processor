`include "../utils/defines.sv"

module data_memory #(
    parameter MEM_SIZE = 1024 // Number of 32-bit words
)(
    input  logic clk,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] write_data,
    input  logic mem_read,
    input  logic mem_write,
    input  logic [2:0] mem_size,
    output logic [DATA_WIDTH-1:0] read_data
);

    logic [7:0] memory [MEM_SIZE*4-1:0]; // Byte-addressable
    
    // Initialize memory to zeros
    initial begin
        for (int i = 0; i < MEM_SIZE*4; i++) begin
            memory[i] = 8'h00;
        end
    end
    
    // Read operation
    always_comb begin
        if (mem_read) begin
            case (mem_size)
                3'b000: read_data = {{24{memory[addr][7]}}, memory[addr]}; // LB
                3'b001: read_data = {{16{memory[addr+1][7]}}, memory[addr+1], memory[addr]}; // LH
                3'b010: read_data = {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]}; // LW
                3'b100: read_data = {24'b0, memory[addr]}; // LBU
                3'b101: read_data = {16'b0, memory[addr+1], memory[addr]}; // LHU
                default: read_data = 32'b0; // Handle all other cases
            endcase
        end else begin
            read_data = 32'b0;
        end
    end
    
    // Write operation
    always_ff @(posedge clk) begin
        if (mem_write) begin
            case (mem_size)
                3'b000: memory[addr] <= write_data[7:0]; // SB
                3'b001: begin // SH
                    memory[addr] <= write_data[7:0];
                    memory[addr+1] <= write_data[15:8];
                end
                3'b010: begin // SW
                    memory[addr] <= write_data[7:0];
                    memory[addr+1] <= write_data[15:8];
                    memory[addr+2] <= write_data[23:16];
                    memory[addr+3] <= write_data[31:24];
                end
                default: begin
                    // Do nothing for unsupported sizes
                end
            endcase
        end
    end

endmodule