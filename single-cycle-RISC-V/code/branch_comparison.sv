module branch_comparison (
    input [31:0] data_rs1,
    input [31:0] data_rs2,
    input        br_un,
    output       br_eq,
    output       br_lt
);

assign br_eq = ($signed(data_rs1) == $signed(data_rs2));
assign br_lt = br_un ? (data_rs1 < data_rs2) : ($signed(data_rs1) < $signed(data_rs2));

endmodule