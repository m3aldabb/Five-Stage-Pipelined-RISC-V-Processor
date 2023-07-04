run:
	iverilog -g2012 -o alu_tb.vvp ../../code/top.sv ../../code/alu.sv ../../code/imemory.sv ../../code/decoder.sv ../../code/immgen.sv ../../code/register_file.sv ../../code/branch_comparison.sv ../../code/dmemory.sv alu_tb.sv
	vvp alu_tb.vvp
clean:
	rm alu_tb.vvp waves.vcd