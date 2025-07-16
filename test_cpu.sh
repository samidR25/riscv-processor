#!/bin/bash

# Test script for RISC-V CPU

echo "RISC-V CPU Test Script"
echo "======================"

# Check if Verilator is installed
if ! command -v verilator &> /dev/null; then
    echo "Error: Verilator not found. Please install it first."
    echo "Ubuntu/Debian: sudo apt-get install verilator"
    echo "macOS: brew install verilator"
    exit 1
fi

# Check if GTKWave is installed
if ! command -v gtkwave &> /dev/null; then
    echo "Warning: GTKWave not found. Install it to view waveforms."
    echo "Ubuntu/Debian: sudo apt-get install gtkwave"
    echo "macOS: brew install gtkwave"
fi

echo "Verilator version: $(verilator --version | head -1)"

# Clean previous build
echo "Cleaning previous build..."
make clean

# Build and run simulation
echo "Building and running simulation..."
make sim

# Check if simulation was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "Simulation completed successfully!"
    echo "Generated files:"
    ls -la cpu_trace.vcd obj_dir/ 2>/dev/null || echo "No files generated"
    echo ""
    echo "To view waveforms, run: make waves"
else
    echo "Simulation failed!"
    exit 1
fi
