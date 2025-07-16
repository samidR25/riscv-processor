# Makefile for RISC-V Processor Simulation

# Directories
SRC_DIR = src
CPU_DIR = $(SRC_DIR)/cpu
MEM_DIR = $(SRC_DIR)/memory
UTILS_DIR = $(SRC_DIR)/utils
TEST_DIR = tests/unit
SIM_DIR = sim

# Verilator settings
VERILATOR = verilator
VERILATOR_FLAGS = --cc --exe --build --trace -Wall -Wno-WIDTH -Wno-UNOPTFLAT -Wno-UNUSED -Wno-CASEINCOMPLETE
TOP_MODULE = cpu_top
TESTBENCH = cpu_tb

# Source files
VERILOG_SOURCES = \
	$(CPU_DIR)/cpu_top.sv \
	$(CPU_DIR)/register_file.sv \
	$(CPU_DIR)/alu.sv \
	$(CPU_DIR)/control_unit.sv \
	$(MEM_DIR)/instruction_memory.sv \
	$(MEM_DIR)/data_memory.sv \
	$(UTILS_DIR)/defines.sv

CPP_SOURCES = $(TEST_DIR)/$(TESTBENCH).cpp

# Build directory
BUILD_DIR = obj_dir

# Default target
all: sim

# Compile and run simulation
sim: $(BUILD_DIR)/V$(TOP_MODULE)
	@echo "Running simulation..."
	@cd $(BUILD_DIR) && ./V$(TOP_MODULE)
	@echo "Simulation complete. Check cpu_trace.vcd for waveforms."

# Verilator compilation
$(BUILD_DIR)/V$(TOP_MODULE): $(VERILOG_SOURCES) $(CPP_SOURCES)
	@echo "Compiling with Verilator..."
	$(VERILATOR) $(VERILATOR_FLAGS) -I$(UTILS_DIR) -I$(CPU_DIR) -I$(MEM_DIR) \
		--top-module $(TOP_MODULE) $(VERILOG_SOURCES) $(CPP_SOURCES)

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	rm -f cpu_trace.vcd

# View waveforms
waves:
	@if [ -f obj_dir/cpu_trace.vcd ]; then \
		echo "Opening GTKWave with obj_dir/cpu_trace.vcd..."; \
		gtkwave obj_dir/cpu_trace.vcd & \
	elif [ -f cpu_trace.vcd ]; then \
		echo "Opening GTKWave with cpu_trace.vcd..."; \
		gtkwave cpu_trace.vcd & \
	else \
		echo "No waveform file found. Run 'make sim' first."; \
	fi

# Create directories if they don't exist
setup:
	@echo "Setting up directories..."
	mkdir -p $(SIM_DIR)
	mkdir -p $(TEST_DIR)

# Lint the Verilog code
lint:
	@echo "Linting Verilog code..."
	$(VERILATOR) --lint-only -I$(UTILS_DIR) -I$(CPU_DIR) -I$(MEM_DIR) \
		--top-module $(TOP_MODULE) $(VERILOG_SOURCES)

# Show help
help:
	@echo "Available targets:"
	@echo "  sim     - Compile and run simulation"
	@echo "  clean   - Clean build artifacts"
	@echo "  waves   - Open GTKWave to view waveforms"
	@echo "  lint    - Lint Verilog code"
	@echo "  setup   - Create necessary directories"
	@echo "  help    - Show this help message"

.PHONY: all sim clean waves setup lint help