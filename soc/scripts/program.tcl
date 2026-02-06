set project_name "soc_fpga_pong"
set design_name "soc_pong"

# Connect to HW Server
connect
puts "Connected to HW Server"

# Define paths
set bitstream "../hw/vivado/${project_name}.runs/impl_1/${design_name}_wrapper.bit"
# Note: Vitis 2025.2 Unified often outputs the linked ELF to the build directory root or a subdirectory.
# Adjust this path if the build configuration (e.g., Hardware) differs.
set elf "../sw/vitis/app_component/build/app_component.elf"

puts "Programming Bitstream: $bitstream"
if { [catch {targets -set -filter {name =~ "*xc7a35t*" || name =~ "*7A35T*"}} err] } {
    puts "Error: Could not find Artix-7 device (xc7a35t). Validating JTAG connection..."
    puts "Available targets:"
    puts [targets]
    exit 1
}

# Program FPGA
fpga $bitstream

puts "Programming ELF: $elf"
if { [catch {targets -set -filter {name =~ "*MicroBlaze*#0*"}} err] } {
    puts "Error: Could not find MicroBlaze. Ensure the bitstream instantiated it correctly."
    exit 1
}

# Reset, Download, Run
rst -processor
dow $elf
con

puts "Programmed and Running!"
exit
