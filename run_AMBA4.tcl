vlib work
vlog +define+AMBA4 {VERIFICATION/pkgs/shared_pkg.sv}

vlog +define+AMBA4 {VERIFICATION/interface/interface.sv}
vlog +define+AMBA4 {VERIFICATION/top.sv}
vlog +define+AMBA4+ASSERTION_COVERAGE {VERIFICATION/RTL/APB_Master.sv}

vlog +define+AMBA4 {VERIFICATION/pkgs/Transaction_pkg.sv}
vlog +define+AMBA4 {VERIFICATION/pkgs/Coverage_pkg.sv}

vlog +define+AMBA4 {VERIFICATION/testbench/testbench.sv}

vsim -voptargs=+acc work.top

add wave -position insertpoint -r -color gold sim:/top/dut/NextState
add wave -position insertpoint -r -color gold sim:/top/dut/CurrentState

add wave -position insertpoint -r -color Khaki   sim:/top/P_if/PRESETn
add wave -color white sim:/top/PCLK

add wave -position insertpoint -r -color cyan    sim:/top/P_if/PSI_ADDR
add wave -position insertpoint -r -color magenta sim:/top/P_if/PADDR

add wave -position insertpoint -r -color cyan    sim:/top/P_if/PSI_WRITE
add wave -position insertpoint -r -color magenta sim:/top/P_if/PWRITE

add wave -position insertpoint -r -color cyan    sim:/top/P_if/PSI_WDATA
add wave -position insertpoint -r -color magenta sim:/top/P_if/PWDATA

add wave -position insertpoint -r -color cyan    sim:/top/P_if/PRDATA
add wave -position insertpoint -r -color magenta sim:/top/P_if/PSO_RDATA

add wave -position insertpoint -r -color gold    sim:/top/P_if/PREADY
add wave -position insertpoint -r -color gold    sim:/top/P_if/PENABLE

add wave -position insertpoint -r -color cyan    sim:/top/P_if/PSI_STRB
add wave -position insertpoint -r -color magenta sim:/top/P_if/PSTRB

add wave -position insertpoint -r -color cyan    sim:/top/P_if/PSI_PROT
add wave -position insertpoint -r -color magenta sim:/top/P_if/PPROT

add wave -position insertpoint -r                sim:/top/P_if/Transfer
add wave -position insertpoint -r                sim:/top/P_if/PSLVERR
add wave -position insertpoint -r                sim:/top/P_if/PSO_SLVERR
add wave -position insertpoint -r                sim:/top/P_if/PSELx

add wave -position insertpoint -r -radix unsigned sim:/top/tb/WaitPeriod

run -all
# quit -sim