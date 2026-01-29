# Vivado Script to Program FPGA
# Usage: vivado -mode batch -source scripts/program.tcl

# 1. Settings
set output_dir "hw/vivado"
set bitstream_file "$output_dir/fpga-pong.runs/impl_1/Pong_Game.bit"

# 2. Check for Bitstream
if {![file exists $bitstream_file]} {
    puts "Error: Bitstream file not found at $bitstream_file"
    puts "Please run the build script first."
    exit 1
}

# 3. Open Hardware Manager and Connect
puts "Opening Hardware Manager..."
open_hw_manager
connect_hw_server -url localhost:3121
current_hw_target [get_hw_targets */xilinx_tcf/*]
open_hw_target

# 4. Program Device
# Select the first device (usually the FPGA)
set device [lindex [get_hw_devices] 0]
current_hw_device $device
refresh_hw_device -update_hw_probes false $device

puts "Programming device $device with $bitstream_file..."
set_property PROGRAM.FILE $bitstream_file $device
program_hw_devices $device

puts "---------------------------------------------"
puts "Device programmed successfully!"
puts "---------------------------------------------"
close_hw_manager
