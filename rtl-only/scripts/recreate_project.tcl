
# Define project name and paths
set project_name "rtl-only-fpga-pong"
set origin_dir "."
set output_dir "../hw/vivado"
set part_name "xc7a35tcpg236-1"
set design_name "design_1"

# Set board repo path GLOBAL parameter to ensure it is picked up before project creation
set_param board.repoPaths [file normalize "$origin_dir/../hw/board_files"]

# Create the project
create_project $project_name $output_dir -part $part_name -force

# Add board files if you have them in the repo
set_property board_part_repo_paths [file normalize "$origin_dir/../hw/board_files"] [current_project]

# Refresh catalog to ensure the board_part_repo_paths is picked up
update_ip_catalog 
set_property board_part digilentinc.com:basys3:part0:1.2 [current_project]

set_property target_language VHDL [current_project]
set_property default_lib work [current_project]


# Add RTL files
set rtl_files [glob -nocomplain $origin_dir/../hw/src/rtl/*.vhd $origin_dir/../hw/src/rtl/*.v]
if { [llength $rtl_files] == 0 } {
    puts "Error: No RTL files found in hw/src/rtl/"
    exit 1
}
add_files -fileset sources_1 $rtl_files

# Add constraints
set constr_files [glob -nocomplain $origin_dir/../hw/src/constrs/*.xdc]
if { [llength $constr_files] == 0 } {
    puts "Warning: No constraint files found in hw/constraints/"
} else {
    add_files -fileset constrs_1 $constr_files
}

# Update top_level
set_property top Pong_Game [get_filesets sources_1]
update_compile_order -fileset sources_1

puts "Project created successfully."
