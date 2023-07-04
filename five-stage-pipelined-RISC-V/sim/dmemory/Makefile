run:
	iverilog -g2012 -o dmemory_tb.vvp ../../code/top.sv ../../code/alu.sv ../../code/imemory.sv ../../code/decoder.sv ../../code/immgen.sv ../../code/register_file.sv ../../code/branch_comparison.sv ../../code/dmemory.sv dmemory_tb.sv
	vvp dmemory_tb.vvp
clean:
	rm dmemory_tb.vvp waves.vcd