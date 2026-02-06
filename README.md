# FPGA Pong

This repository contains the VHDL/Verilog source code for a Pong game implementation on FPGA (Basys 3 default). This was a group project for EEL 5934 - System-on-Chip Design at the University of Florida alongside group members Nikodem Gazda and Lucas Mueller. It has been modified to be reproducible using Vivado Tcl scripts and makefiles.

The project is divided into two distinct implementations:

1.  **`rtl-only`**: A pure hardware implementation focusing on signal generation and IO interfaces.
2.  **`soc`**: A System-on-Chip implementation utilizing a MicroBlaze soft processor for game logic and hardware peripherals.

## Directory Structure

-   `rtl-only/`: Source code and build scripts for the pure hardware version.
-   `soc/`: Source code (HW/SW) and build scripts for the SoC version.

## Prerequisites

-   Xilinx Vivado 2025.2
-   Xilinx Vitis 2025.2 (for SoC build)

## 1. RTL-Only Implementation

Located in the `rtl-only` directory.

### Building
To generate the Vivado project and bitstream:

1.  Navigate to the directory:
    ```bash
    cd rtl-only
    ```
2.  Generate the project:
    ```bash
    make project
    ```
3.  Build the bitstream:
    ```bash
    make bitstream
    ```

### Programming
To program the board:
```bash
make program
```

## 2. SoC Implementation

Located in the `soc` directory. This version requires both hardware (Vivado) and software (Vitis) builds.

### Building
To generate the full system:

1.  Navigate to the directory:
    ```bash
    cd soc
    ```
2.  Generate the Vivado project:
    ```bash
    make project
    ```
3.  Build the hardware (Bitstream & XSA):
    ```bash
    make bitstream
    ```
4.  Build the software (ELF):
    ```bash
    make sw
    ```

### Programming
To program the FPGA with the bitstream and load the software ELF:
```bash
make program
```

## Clean
To clean build artifacts in either directory, run:
```bash
make clean
```
