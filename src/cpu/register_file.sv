`include "../utils/defines.sv"

module register_file (
    input  logic clk,
    input  logic rst_n,
    
    // Read ports
    input  logic [REG_ADDR_WIDTH-1:0] rs1_addr,
    input  logic [REG_ADDR_WIDTH-1:0] rs2_addr,
    output logic [DATA_WIDTH-1:0] rs1_data,
    output logic [DATA_WIDTH-1:0] rs2_data,
    
    // Write port
    input  logic [REG_ADDR_WIDTH-1:0] rd_addr,
    input  logic [DATA_WIDTH-1:0] rd_data,
    input  logic reg_write
);

    // Register array (x0 to x31)
    logic [DATA_WIDTH-1:0] registers [31:0];
    
    // Asynchronous read
    assign rs1_data = (rs1_addr == 0) ? 32'b0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 0) ? 32'b0 : registers[rs2_addr];
    
    // Synchronous write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end else if (reg_write && rd_addr != 0) begin
            registers[rd_addr] <= rd_data;
        end
    end

endmodule
