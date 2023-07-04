# Five-Stage-RISC-V-Processor
Fully functioning five stage pipelined RISC-V processor with full bypassing/forwarding written from scratch using Verilog. Functionality was verified in simulation as well as in hardware through deployment on a Xilinx PYNQ FPGA board. Design was first implemented as a single cycle processor and then modified to incorporate pipelining, forwarding, and stalling.

## RISC-V Instruction Set Architecture (ISA)
The <a href="https://riscv.org/technical/specifications/"> RISC-V </a> ISA is an open standard instruction set architecture that is designed to be simple, extensible, and royalty-free. It was developed by the University of California, Berkeley and is now maintained by the RISC-V International community.

### Instruction Formats
RISC-V provides several instruction formats, including:
- **R-type**: Used for arithmetic and logical operations between registers.
- **I-type**: Used for immediate values and register-based operations.
- **S-type**: Used for storing values from registers to memory.
- **B-type**: Used for conditional branches.
- **U-type**: Used for unconditional jumps and large immediate values.
- **J-type**: Used for jumps and function calls.

## About This Project
In this project I buit a 5-stage pipelined processor using synthesizable SystemVerilog code. The processor implements the RISC-V ISA.
### Simulation Waveforms

### Tools
* <a href="https://github.com/steveicarus/iverilog"> iVerilog </a> is a free and powerful Verilog simulator that I always use to test my RTL designs.
* <a href="https://gtkwave.sourceforge.net"> GTKWave </a> is a free and simple waveform viewer with a lot of functionality. 
### Compiling and Simulating the Design
The design was compilied using Icarus Verilog(iVerilog) and simulation waveforms were viewed using GTKWave. Each unit in my design has its own directory under the ```sim``` directory. Each design unit can be tested by entering its directory and running ```make run``` to compile. 
* Compiling the top level processor design: 
  ```sh
  cd sim/top_dut
  make run
  ```
  This compiles the design and outputs to the console. It also produces a dumpfile ```waves.vcd``` to view simulation waveforms.
  
* Viewing Waveform Files using GTKWave
  ```sh
  gtkwave waves.vcd
  ```

