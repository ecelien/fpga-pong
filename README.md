# FPGA Pong

This repository contains the VHDL/Verilog source code for a Pong game implementation on FPGA (Basys 3 default). This was a group project for EEL 5934 - System-on-Chip Design at the University of Florida alongside group members Nikodem Gazda and Lucas Mueller. This version is a purely hardware implementation of the game, focusing on signal generation and IO interfaces.

## Directory Structure
- `hw/rtl`: Source code (VHDL/Verilog)
- `hw/constraints`: XDC constraint files
- `hw/vivado`: Generated Vivado project files (ignored by git)
- `scripts`: Build scripts

## Building the Project

To generate the Vivado project and bitstream:

1. Open a terminal at the repository root.
2. Run the build script:

```bash
vivado -mode batch -source scripts/build.tcl
```

## Programming the FPGA

To program the board:

1. Connect your FPGA board.
2. Run the program script:

```bash
vivado -mode batch -source scripts/program.tcl
```
