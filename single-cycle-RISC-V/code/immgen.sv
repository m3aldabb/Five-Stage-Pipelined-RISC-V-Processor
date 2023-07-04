module immgen (
    input  [31:0]    insn,
    input  [9:0]     optype,
    output [31:0]    imm  
);

logic S, B, U, J;

assign S = optype[5];
assign B = optype[6];
assign U = (optype[7] || optype[8]);
assign J = optype[9];

assign imm[31]    = insn[31];
assign imm[30:20] = U ? insn[30:20] : {11{insn[31]}};
assign imm[19:12] = (U || J) ? insn[19:12] : {8{insn[31]}};
assign imm[11]    = B ? insn[7] : (U ? 1'b0 : (J ? insn[20] : insn[31]));
assign imm[10:5]  = U ? 6'b0 : insn[30:25];
assign imm[4:1]   = (S || B) ? insn[11:8] : (U ? 4'b0 : insn[24:21]);
assign imm[0]     = (B || U || J) ? 1'b0 : (S ? insn[7] : insn[20]);

endmodule
