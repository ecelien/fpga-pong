# Makefile for Hardware Only pong implementation

.PHONY: all project bitstream clean

all: project bitstream

# Program Device (Bitstream + ELF)
program:
	cd scripts && xsct program.tcl


# 1. Create Vivado Project
project:
	cd scripts && vivado -mode batch -notrace -nojournal -nolog -source recreate_project.tcl

# 2. Build Hardware (Synthesis -> Implementation -> Bitstream)
bitstream:
	cd scripts && vivado -mode batch -notrace -nojournal -nolog -source build_bitstream.tcl

# Clean build artifacts
clean:
	rm -rf hw/vivado
