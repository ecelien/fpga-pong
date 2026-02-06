set project_name "rtl-only-fpga-pong"
set top_level "Pong_Game"
# Connect to HW Server
connect
puts "Connected to HW Server"

# Define paths
set bitstream "../hw/vivado/$project_name.runs/impl_1/$top_level.bit"

puts "Programming Bitstream: $bitstream"
if { [catch {targets -set -filter {name =~ "*xc7a35t*" || name =~ "*7A35T*"}} err] } {
    puts "Error: Could not find Artix-7 device (xc7a35t). Validating JTAG connection..."
    puts "Available targets:"
    puts [targets]
    exit 1
}

# Program FPGA
fpga $bitstream

puts "Programmed and Running!"
exit
