
# Define project name and paths
set project_name "rtl-only-fpga-pong"
set origin_dir "."
set output_dir "../hw/vivado"

# Open the existing project
set_param board.repoPaths [file normalize "$origin_dir/../hw/board_files"]
open_project "$output_dir/$project_name.xpr"

set_property board_part_repo_paths [file normalize "$origin_dir/../hw/board_files"] [current_project]
update_ip_catalog

# Run Synthesis
launch_runs synth_1 -jobs 8
wait_on_run synth_1

# Run Implementation 
launch_runs impl_1 -jobs 8
wait_on_run impl_1

# Generate Bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

puts "Bitstream generated and XSA exported successfully."
