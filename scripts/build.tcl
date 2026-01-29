# Vivado Script to Generate Bitstream
# Usage: vivado -mode batch -source scripts/run_bitstream.tcl

# 1. Settings
set project_name "fpga-pong"
set output_dir "hw/vivado"
set project_file "$output_dir/$project_name.xpr"

# 2. Check if project exists, if not create it
if {![file exists $project_file]} {
    puts "Project not found at $project_file. creating it..."
    source scripts/create_project.tcl
} else {
    puts "Opening project $project_name..."
    open_project $project_file
}

# 3. Run Synthesis
puts "Running Synthesis..."
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
   puts "Synthesis failed!"
   exit 1
}

# 4. Run Implementation
puts "Running Implementation..."
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
   puts "Implementation/Bitstream Generation failed!"
   exit 1
}

puts "---------------------------------------------"
puts "Bitstream generated successfully!"
puts "Location: [get_property DIRECTORY [get_runs impl_1]]/Pong_Game.bit"
puts "---------------------------------------------"
