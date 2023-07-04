module decoder (
    input  [31:0]    insn,
    output [6:0]     opcode,
    output [4:0]     rd,
    output [2:0]     funct3,
    output [4:0]     rs1,
    output [4:0]     rs2,
    output [6:0]     funct7,
    output [4:0]     shamt,
    output [9:0]     optype
);

//OPTYPES
localparam R       = 0;
localparam I_loads = 1;
localparam I_arith = 2;
localparam I_ecall = 3;
localparam I_jalr  = 4;
localparam S       = 5;
localparam B       = 6;
localparam U_auipc = 7;
localparam U_lui   = 8;
localparam J_jal   = 9;

assign optype[R]        = (insn[6:2] == 5'b01100);
assign optype[I_loads]  = (insn[6:2] == 5'b00000);
assign optype[I_arith]  = (insn[6:2] == 5'b00100);
assign optype[I_ecall]  = (insn[6:2] == 5'b11100);
assign optype[I_jalr]   = (insn[6:2] == 5'b11001);
assign optype[S]        = (insn[6:4] == 3'b010);
assign optype[B]        = (insn[6:2] == 5'b11000);
assign optype[U_auipc]  = (insn[5:2] == 4'b0101);
assign optype[U_lui]    = (insn[5:2] == 4'b1101);
assign optype[J_jal]    = (insn[3:2] == 2'b11);  

assign opcode   = insn[6:0];
assign rd       = (optype[B] || optype[S]) ? 5'b0 : insn[11:7];
assign rs1      = (optype[U_auipc] || optype[U_lui] || optype[J_jal]) ? 5'b0 : insn[19:15];
assign rs2      = (optype[B] || optype[S] || optype[R]) ? insn[24:20] : 5'b0;
assign funct3   = insn[14:12];
assign funct7   = insn[31:25];
assign shamt    = insn[24:20];

endmodule