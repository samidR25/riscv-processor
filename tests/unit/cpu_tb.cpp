#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcpu_top.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <iomanip>

class CPUTestbench {
private:
    Vcpu_top* cpu;
    VerilatedVcdC* trace;
    uint64_t time_counter;
    
public:
    CPUTestbench() : time_counter(0) {
        cpu = new Vcpu_top;
        
        Verilated::traceEverOn(true);
        trace = new VerilatedVcdC;
        cpu->trace(trace, 99);
        trace->open("cpu_trace.vcd");
        
        // Initialize
        cpu->clk = 0;
        cpu->rst_n = 0;
    }
    
    ~CPUTestbench() {
        trace->close();
        delete cpu;
        delete trace;
    }
    
    void tick() {
        cpu->clk = 0;
        cpu->eval();
        trace->dump(time_counter++);
        
        cpu->clk = 1;
        cpu->eval();
        trace->dump(time_counter++);
        
        trace->flush();
    }
    
    void reset() {
        std::cout << "Resetting CPU..." << std::endl;
        cpu->rst_n = 0;
        for (int i = 0; i < 5; i++) {
            tick();
        }
        cpu->rst_n = 1;
        std::cout << "Reset complete." << std::endl;
    }
    
    void run_cycles(int cycles) {
        std::cout << "Running " << cycles << " cycles..." << std::endl;
        for (int i = 0; i < cycles; i++) {
            tick();
            
            // Print some debug info every 10 cycles
            if (i % 10 == 0) {
                std::cout << "Cycle " << std::setw(3) << i 
                         << " - PC: 0x" << std::hex << std::setw(8) << std::setfill('0') 
                         << static_cast<unsigned int>(cpu->cpu_top__DOT__pc) << std::dec;
                std::cout << " - Instr: 0x" << std::hex << std::setw(8) << std::setfill('0')
                         << static_cast<unsigned int>(cpu->cpu_top__DOT__instruction) << std::dec << std::endl;
            }
        }
    }
    
    void print_status() {
        std::cout << "\n=== CPU Status ===" << std::endl;
        std::cout << "PC: 0x" << std::hex << std::setw(8) << std::setfill('0') 
                  << static_cast<unsigned int>(cpu->cpu_top__DOT__pc) << std::dec << std::endl;
        std::cout << "Instruction: 0x" << std::hex << std::setw(8) << std::setfill('0')
                  << static_cast<unsigned int>(cpu->cpu_top__DOT__instruction) << std::dec << std::endl;
        std::cout << "ALU Result: 0x" << std::hex << std::setw(8) << std::setfill('0')
                  << static_cast<unsigned int>(cpu->cpu_top__DOT__alu_result) << std::dec << std::endl;
        std::cout << "=================" << std::endl;
    }
    
    void run_test_program() {
        std::cout << "\n=== Running Test Program ===" << std::endl;
        std::cout << "Test program instructions:" << std::endl;
        std::cout << "1. ADDI x1, x0, 10    (Load 10 into x1)" << std::endl;
        std::cout << "2. ADDI x2, x0, 20    (Load 20 into x2)" << std::endl;
        std::cout << "3. ADD x3, x1, x2     (Add x1+x2 -> x3)" << std::endl;
        std::cout << "4. SW x3, 0(x0)       (Store x3 to memory)" << std::endl;
        std::cout << "5. LW x4, 0(x0)       (Load from memory to x4)" << std::endl;
        std::cout << "6. BEQ x3, x4, 4      (Branch if x3 == x4)" << std::endl;
        std::cout << "===============================" << std::endl;
        
        // Run enough cycles to execute the test program
        run_cycles(20);
        
        std::cout << "\nTest program execution complete!" << std::endl;
    }
    
    void load_program(const std::string& filename) {
        std::cout << "Program loading not implemented yet - using built-in test program" << std::endl;
    }
};

int main(int argc, char** argv) {
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);
    
    CPUTestbench tb;
    
    std::cout << "Starting RISC-V CPU Simulation..." << std::endl;
    std::cout << "=================================" << std::endl;
    
    // Reset the CPU
    tb.reset();
    
    // Print initial status
    tb.print_status();
    
    // Run the test program
    tb.run_test_program();
    
    // Print final status
    tb.print_status();
    
    std::cout << "\nSimulation completed successfully!" << std::endl;
    std::cout << "Check cpu_trace.vcd for detailed waveforms." << std::endl;
    std::cout << "Use 'make waves' to open GTKWave." << std::endl;
    
    return 0;
}