module register_file (
    input         clk,
    input         write_enable,
    input  [4:0]  addr_rs1,
    input  [4:0]  addr_rs2,
    input  [4:0]  addr_rd,
    input  [31:0] data_rd,
    output [31:0] data_rs1,
    output [31:0] data_rs2
);
logic [31:0] mem [31:0];

localparam START_ADDR = 32'h0;
localparam MEM_DEPTH  = 32;

initial begin
    mem[0] = 32'h0;
    mem[2] = MEM_DEPTH + START_ADDR;
end

always @(posedge clk) begin
    if(write_enable && (addr_rd != 5'b0)) begin
        mem[addr_rd] <= data_rd;
    end 
end

assign data_rs1 = mem[addr_rs1];
assign data_rs2 = mem[addr_rs2];
endmodule