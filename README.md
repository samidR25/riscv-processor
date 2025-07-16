# RISC-V Processor

A basic single-cycle RISC-V processor implementation with a verification and simulation framework for learning purposes.

## Overview

This implements a basic RV32I (RISC-V 32-bit Integer) processor core with the following features:

- **Single-cycle execution** - All instructions complete in one clock cycle
- **Complete RV32I instruction set** - Supports all base integer instructions
- **Harvard architecture** - Separate instruction and data memories
- **Comprehensive verification** - Includes testbench and simulation framework
- **Waveform generation** - Full VCD trace support for debugging

## Architecture

### Core Components

- **CPU Top Module** (`cpu_top.sv`) - Main processor integrating all components
- **Register File** (`register_file.sv`) - 32-register file with dual read ports
- **ALU** (`alu.sv`) - Arithmetic Logic Unit supporting all RV32I operations
- **Control Unit** (`control_unit.sv`) - Instruction decoder and control signal generator
- **Instruction Memory** (`instruction_memory.sv`) - Read-only program storage
- **Data Memory** (`data_memory.sv`) - Read/write data storage

### Instruction Support

| Instruction Type | Instructions Supported |
|------------------|----------------------|
| **Arithmetic** | ADD, ADDI, SUB, SLT, SLTI, SLTU, SLTIU |
| **Logical** | AND, ANDI, OR, ORI, XOR, XORI |
| **Shift** | SLL, SLLI, SRL, SRLI, SRA, SRAI |
| **Memory** | LW, LH, LB, LHU, LBU, SW, SH, SB |
| **Branch** | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| **Jump** | JAL, JALR |
| **Upper Immediate** | LUI, AUIPC |

## Project Structure

```
riscv-processor/
├── src/
│   ├── cpu/
│   │   ├── cpu_top.sv          # Main CPU module
│   │   ├── register_file.sv    # Register file implementation
│   │   ├── alu.sv             # Arithmetic Logic Unit
│   │   └── control_unit.sv    # Control unit and decoder
│   ├── memory/
│   │   ├── instruction_memory.sv  # Instruction memory
│   │   └── data_memory.sv         # Data memory
│   └── utils/
│       └── defines.sv             # Parameter definitions and types
├── tests/
│   └── unit/
│       └── cpu_tb.cpp            # C++ testbench
├── Makefile                      # Build automation
├── test_cpu.sh                   # Test script
├── cpu_trace.vcd               # Generated waveform file
└── README.md                     # This file
```

## Prerequisites

### Required Tools

- **Verilator** (>= 4.0) - Verilog simulation and compilation
- **GTKWave** (optional) - Waveform viewer
- **Make** - Build automation
- **C++ Compiler** (GCC/Clang) - For testbench compilation

### Installation

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install verilator gtkwave build-essential
```

#### macOS
```bash
brew install verilator gtkwave
```

#### CentOS/RHEL
```bash
sudo yum install verilator gtkwave gcc-c++
```

## Quick Start

### 1. Clone and Build
```bash
git clone <repository-url>
cd riscv-processor
make sim
```

### 2. Run Tests
```bash
./test_cpu.sh
```

### 3. View Waveforms
```bash
make waves
```

## Build System

The project uses a Makefile for build automation with the following targets:

| Target | Description |
|--------|-------------|
| `make sim` | Compile and run simulation |
| `make clean` | Clean build artifacts |
| `make waves` | Open GTKWave with generated waveforms |
| `make lint` | Lint Verilog code for syntax issues |
| `make setup` | Create necessary directories |
| `make help` | Show available targets |

## Test Program

The processor includes a built-in test program that demonstrates basic functionality:

```assembly
ADDI x1, x0, 10    # Load immediate 10 into register x1
ADDI x2, x0, 20    # Load immediate 20 into register x2  
ADD  x3, x1, x2    # Add x1 + x2, store result in x3 (30)
SW   x3, 0(x0)     # Store x3 to memory address 0
LW   x4, 0(x0)     # Load from memory address 0 to x4
BEQ  x3, x4, 4     # Branch forward if x3 equals x4
```

## Simulation and Verification

### Testbench Features

- **Clock generation** - Automated clock signal generation
- **Reset sequence** - Proper reset initialization
- **Instruction tracing** - PC and instruction monitoring
- **Register inspection** - Runtime register state viewing
- **VCD generation** - Complete waveform capture

### Running Simulations

```bash
# Basic simulation
make sim

# View detailed waveforms
make waves

# Clean and rebuild
make clean sim
```

### Verification Output

The simulation provides detailed execution traces:
```
Cycle   0 - PC: 0x00000000 - Instr: 0x00a00093
Cycle  10 - PC: 0x00000004 - Instr: 0x01400113
Cycle  20 - PC: 0x00000008 - Instr: 0x002081b3
```

## Memory Organization

### Instruction Memory
- **Size**: 1024 words (4KB)
- **Type**: Read-only, initialized with test program
- **Access**: Word-aligned (32-bit)

### Data Memory  
- **Size**: 1024 words (4KB)
- **Type**: Read/write with byte-level access
- **Supported operations**: LB, LH, LW, SB, SH, SW

### Register File
- **Registers**: x0-x31 (32 registers)
- **Width**: 32 bits each
- **Special**: x0 hardwired to zero

## Development

### Adding New Instructions

1. Update `defines.sv` with new opcodes/parameters
2. Modify `control_unit.sv` to decode new instructions
3. Extend `alu.sv` if new operations are needed
4. Update testbench to verify new functionality

### Debugging

1. **Compile errors**: Check `make lint` output
2. **Simulation issues**: Examine `cpu_trace.vcd` in GTKWave
3. **Logic errors**: Add debug prints to `cpu_tb.cpp`

### Performance Analysis

The current implementation achieves:
- **Maximum frequency**: Depends on longest combinational path
- **CPI**: 1 (single-cycle design)
- **Memory bandwidth**: 1 instruction + 1 data access per cycle

## Future Enhancements

### Planned Features
- [ ] 5-stage pipeline implementation
- [ ] Hazard detection and forwarding
- [ ] Branch prediction (2-bit, Gshare)
- [ ] L1 instruction and data caches
- [ ] Performance counters and analysis
- [ ] Extended instruction set (M, F extensions)

### Pipeline Stages (Future)
1. **IF** - Instruction Fetch
2. **ID** - Instruction Decode  
3. **EX** - Execute
4. **MEM** - Memory Access
5. **WB** - Write Back

## Acknowledgments

- RISC-V Foundation for the open instruction set architecture
- Verilator team for the simulation framework
- Educational resources that inspired this implementation

---

**Note**: This is an educational implementation focused on understanding RISC-V architecture. For production use, additional verification and optimization would be required.
