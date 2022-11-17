module register_file (
    input         clock,
    input         write_enable,
    input  [4:0]  addr_rs1,
    input  [4:0]  addr_rs2,
    input  [4:0]  addr_rd,
    input  [31:0] data_rd,
    output [31:0] data_rs1,
    output [31:0] data_rs2
);
reg [31:0] mem [31:0];

initial begin
    mem[0] = 32'b0;
    mem[2] = `MEM_DEPTH + 32'h01000000;
end

always @(posedge clock) begin
    if(write_enable && (addr_rd != 5'b0)) begin
        mem[addr_rd] <= data_rd;
    end 
end

assign data_rs1 = mem[addr_rs1];
assign data_rs2 = mem[addr_rs2];
endmodule