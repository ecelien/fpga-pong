# Makefile for Phase 4

.PHONY: all project bitstream sw clean

all: project bitstream sw

# Program Device (Bitstream + ELF)
program:
	cd scripts && xsct program.tcl


# Create Vivado Project
project:
	cd scripts && vivado -mode batch -notrace -nojournal -nolog -source recreate_project.tcl

# Build Hardware (Synthesis -> Implementation -> Bitstream -> XSA)
bitstream:
	cd scripts && vivado -mode batch -notrace -nojournal -nolog -source build_bitstream.tcl

# Build Software (Vitis Workspace -> Compile ELF)
sw:
	cd scripts && vitis -s recreate_vitis.py

# Clean build artifacts
clean:
	rm -rf hw/vivado
	rm -rf sw/vitis
	rm -f hw/export/*.xsa
