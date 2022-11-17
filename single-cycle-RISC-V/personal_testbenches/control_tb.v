`timescale 1ps / 1ps
`include "../code/control.v"
`include "../code/immgen.v"
`include "../code/decoder.v"

module control_tb();

    reg  [31:0]    insn;
    wire [6:0]     opcode;
    wire [4:0]     rd;
    wire [2:0]     funct3;
    wire [4:0]     rs1;
    wire [4:0]     rs2;
    wire [6:0]     funct7;
    wire [4:0]     shamt;   

    wire [31:0]    imm;  

    reg               br_eq;
    reg               br_lt;
    wire     [3:0]    alu_sel;
    wire     [1:0]    wb_sel;
    wire              A_sel;
    wire              B_sel;
    wire              reg_write_enable;
    wire              br_un;
    wire              mem_rw;
    wire              pc_sel;
    wire     [1:0]    access_size;
    wire              load_un;

decoder decoder_0 (
    .insn(insn),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7),
    .shamt(shamt)
);

wire [9:0] optype;
assign optype[0] = (opcode[6:2] == 5'b01100); //R
assign optype[1] = (opcode[6:2] == 5'b00000); //I1
assign optype[2] = (opcode[6:2] == 5'b00100); //I2
assign optype[3] = (opcode[6:2] == 5'b11100); //I3 ECALL
assign optype[4] = (opcode[6:2] == 5'b11001); //I4 JALR
assign optype[5] = (opcode[6:4] == 3'b010);   //S
assign optype[6] = ({opcode[6], opcode[4], opcode[2]} == 3'b100); //B
assign optype[7] = (opcode[5:2] == 4'b0101); //U1 AUIPC
assign optype[8] = (opcode[5:2] == 4'b1101); //U2 LUI
assign optype[9] = (opcode[3:2] == 2'b11);   //J JAL

immgen immgen_0 (
    .insn(insn),
    .imm(imm),
    .optype(optype)
);

control control_0 (
  .optype(optype),
  .funct3(funct3),
  .funct7(funct7),
  .br_eq(br_eq),
  .br_lt(br_lt),
  .alu_sel(alu_sel),
  .wb_sel(wb_sel),
  .A_sel(A_sel),
  .B_sel(B_sel),
  .reg_write_enable(write_enable),
  .br_un(br_un),
  .pc_sel(pc_sel),
  .mem_rw(mem_rw),
  .access_size(access_size),
  .load_un(load_un)
);

initial begin
    insn = 32'b00010001010000010010000010000011;

    #10;
            $dumpfile("control_tb.vcd");
            $dumpvars(0, control_tb);
    $display("load_un=%b    access_size=%b", load_un, access_size);
    $finish;
end

endmodule