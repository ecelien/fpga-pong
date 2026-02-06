
# Define project name and paths
set project_name "soc_fpga_pong"
set origin_dir "."
set output_dir "../hw/vivado"

# Set board repo path
set_param board.repoPaths [file normalize "$origin_dir/../hw/board_files"]

# Open the existing project
open_project "$output_dir/$project_name.xpr"

# Synthesis
launch_runs synth_1 -jobs 8
wait_on_run synth_1

# Implementation 
launch_runs impl_1 -jobs 8
wait_on_run impl_1

# Generate Bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# Export the XSA including the bitstream
write_hw_platform -fixed -include_bit -force -file "$origin_dir/../hw/export/system_wrapper.xsa"

puts "Bitstream generated and XSA exported successfully."
