# Vivado Build Script for FPGA Pong
# Usage: vivado -mode batch -source scripts/build.tcl

# 1. Settings
set project_name "fpga-pong"
set part_name "xc7a35tcpg236-1"
# Output directory for the project files (gitignored)
set output_dir "hw/vivado"

# 2. Cleanup and Create
# Close any open project
if { [current_project -quiet] ne "" } {
    close_project
}

puts "Creating project $project_name in $output_dir..."
create_project -force $project_name $output_dir -part $part_name

# Set project properties
set_property target_language VHDL [current_project]
set_property default_lib work [current_project]

# 3. Add Sources
puts "Adding RTL sources..."
# We assume the script is run from the repo root, so we check content relative to that.
# If files aren't found, we might be in 'scripts/', so handle that

set rtl_files [glob -nocomplain hw/rtl/*.vhd hw/rtl/*.v]
if { [llength $rtl_files] == 0 } {
    puts "Error: No RTL files found in hw/rtl/"
    exit 1
}
add_files -fileset sources_1 $rtl_files

# 4. Add Constraints
puts "Adding Constraints..."
set constr_files [glob -nocomplain hw/constraints/*.xdc]
if { [llength $constr_files] == 0 } {
    puts "Warning: No constraint files found in hw/constraints/"
} else {
    add_files -fileset constrs_1 $constr_files
}

# 5. Configuration
# Set top module
set_property top Pong_Game [get_filesets sources_1]

# Update compile order
update_compile_order -fileset sources_1

puts "---------------------------------------------"
puts "Project $project_name created successfully!"
puts "To open: vivado $output_dir/$project_name.xpr"
puts "---------------------------------------------"
