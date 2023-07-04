run:
	iverilog -g2012 -o dut_tb.vvp ../../code/top.sv ../../code/alu.sv ../../code/imemory.sv ../../code/decoder.sv ../../code/immgen.sv ../../code/register_file.sv ../../code/branch_comparison.sv ../../code/dmemory.sv dut_tb.sv
	vvp dut_tb.vvp
clean:
	rm dut_tb.vvp waves.vcd