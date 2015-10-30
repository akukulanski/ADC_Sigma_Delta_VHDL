onbreak resume
onerror resume
vsim -novopt work.filter_tb
add wave sim:/filter_tb/u_filterM/clk
add wave sim:/filter_tb/u_filterM/clk_enable
add wave sim:/filter_tb/u_filterM/reset
add wave sim:/filter_tb/u_filterM/filter_in
add wave sim:/filter_tb/u_filterM/filter_out
add wave sim:/filter_tb/filter_out_ref
add wave sim:/filter_tb/u_filterM/ce_out
run -all
