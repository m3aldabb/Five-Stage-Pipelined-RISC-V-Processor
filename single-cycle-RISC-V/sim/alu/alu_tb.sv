`timescale 1ps / 1ps

module alu_tb;
reg      [31:0] data_A;
reg      [31:0] data_B;
reg      [3:0]  alu_sel;
reg             B_sel;
wire     [31:0] alu_out;

reg  [31:0]    inst;
wire [6:0]     opcode;
wire [4:0]     rd;
wire [2:0]     funct3;
wire [4:0]     rs1;
wire [4:0]     rs2;
wire [6:0]     funct7;
wire [4:0]     shamt;

wire [31:0]    imm;

localparam R_TYPE   = 7'b0110011;
localparam I_TYPE_1 = 7'b0000011;
localparam I_TYPE_2 = 7'b0010011;
localparam I_TYPE_3 = 7'b1110011; //ECALL
localparam I_TYPE_4 = 7'b1100111; //JALR
localparam S_TYPE   = 7'b0100011;
localparam B_TYPE   = 7'b1100011;
localparam U_TYPE_1 = 7'b0010111; //AUIPC
localparam U_TYPE_2 = 7'b0110111; //LUI
localparam J_TYPE   = 7'b1101111; //JAL

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

decoder decoder_0 (
    .insn(inst),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7),
    .shamt(shamt)
);

immgen immgen_0 (
    .insn(inst),
    .imm(imm),
    .optype(optype)
);

alu dut (
    .data_A(data_A),
    .data_B(data_B),
    .shamt(shamt),
    .alu_sel(alu_sel),
    .B_sel(B_sel),
    .alu_out(alu_out)
);

always @(*) begin
    B_sel = (opcode == R_TYPE) ? 0:1; //0:Reg, 1:Imm
    alu_sel =    (opcode == U_TYPE_1) ? 4'd0 :  //auipc
                    (opcode == U_TYPE_2) ? 4'd10 : //lui
                    (opcode == R_TYPE  ) ? (
                        (funct3 == 3'b000) ? (funct7 == 7'b0) ? 4'd0:4'd1 : //add:sub
                        (funct3 == 3'b100) ? 4'd2 :                         //xor
                        (funct3 == 3'b110) ? 4'd3 :                         //or
                        (funct3 == 3'b111) ? 4'd4 :                         //and
                        (funct3 == 3'b001) ? 4'd5 :                         //sll
                        (funct3 == 3'b101) ? (funct7 == 7'b0) ? 4'd6:4'd7 : //srl:sra
                        (funct3 == 3'b010) ? 4'd8 :                         //slt
                        (funct3 == 3'b011) ? 4'd9 :                         //sltu
                        4'bzzzz) :
                    (opcode == I_TYPE_2) ? (
                        (funct3 == 3'h0) ? 4'd0 :                         //addi
                        (funct3 == 3'h4) ? 4'd2 :                         //xori
                        (funct3 == 3'h6) ? 4'd3 :                         //ori
                        (funct3 == 3'h7) ? 4'd4 :                         //andi
                        (funct3 == 3'h1) ? 4'd5 :                         //slli
                        (funct3 == 3'h5) ? (funct7 == 7'h0) ? 4'd6:4'd7 : //srli:srai
                        (funct3 == 3'h2) ? 4'd8 :                         //slti
                        (funct3 == 3'h3) ? 4'd9 :                         //sltiu
                        4'bzzzz) :                        
                    4'd0;
end
initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, alu_tb);
    

    inst = 32'h51f18193; data_A = 32'h33333333; data_B = 32'd1311; #10;
    $display("A=%h      B=%h        result=%h", data_A, data_B, alu_out);

    inst = 32'h40c4d913; data_A = 32'h99999999; data_B = 32'hc; #10;
    $display("A=%h      B=%h        result=%h       alu_sel=%d      B_sel = %b      imm=%b", data_A, data_B, alu_out, alu_sel, B_sel, imm);

    inst = 32'h00921933; data_A = 32'h44444444; data_B = 32'h99999999; #10;
    $display("A=%h      B=%h        result=%h       alu_sel=%d      B_sel = %b      imm=%b", data_A, data_B, alu_out, alu_sel, B_sel, imm);

    inst = 32'h00915633; data_A = 32'h22222222; data_B = 32'h99999999; #10;
    $display("A=%h      B=%h        result=%h", data_A, data_B, alu_out);

    inst = 32'h4091d733; data_A = 32'h33333333; data_B = 32'h99999999; #10;
    $display("A=%h      B=%h        result=%h", data_A, data_B, alu_out);

end
endmodule