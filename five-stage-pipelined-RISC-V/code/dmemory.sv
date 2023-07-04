module dmemory(
    input         clk,
    input  [31:0] address,  
    input         read_write,
    input  [1:0]  access_size,
    input  [31:0] data_in,  
    output [31:0] data_out  
);

// localparam START_ADDR = 32'h01000000;
// localparam MEM_DEPTH  = 1048576;

localparam START_ADDR = 32'h0;
localparam MEM_DEPTH  = 32;
logic [7:0]  mem  [MEM_DEPTH-1:0];

initial begin
  // Setting 32-bit instruction: add t1, s0,s1 => 0x00940333 
  {mem[START_ADDR+3], mem[START_ADDR+2], mem[START_ADDR+1], mem[START_ADDR]} = {8'h00, 8'h94, 8'h03, 8'h33};
  // Setting 32-bit instruction: sub t2, s2, s3 => 0x413903b3
  {mem[START_ADDR+7], mem[START_ADDR+6], mem[START_ADDR+5], mem[START_ADDR+4]} = {8'h41, 8'h39, 8'h03, 8'hb3};
  // Setting 32-bit instruction: mul t0, s4, s5 => 0x035a02b3
  {mem[START_ADDR+11], mem[START_ADDR+10], mem[START_ADDR+9], mem[START_ADDR+8]} = {8'h03, 8'h5a, 8'h02, 8'hb3};
  // Setting 32-bit instruction: xor t3, s6, s7 => 0x017b4e33
  {mem[START_ADDR+15], mem[START_ADDR+14], mem[START_ADDR+13], mem[START_ADDR+12]} = {8'h01, 8'h7b, 8'h4e, 8'h33};
  // Setting 32-bit instruction: sll t4, s8, s9
  {mem[START_ADDR+19], mem[START_ADDR+18], mem[START_ADDR+17], mem[START_ADDR+16]} = {8'h01, 8'h9c, 8'h1e, 8'hb3};
  // Setting 32-bit instruction: srl t5, s10, s11
  {mem[START_ADDR+23], mem[START_ADDR+22], mem[START_ADDR+21], mem[START_ADDR+20]} = {8'h01, 8'hbd, 8'h5f, 8'h33};
  // Setting 32-bit instruction: and t6, a2, a3
  {mem[START_ADDR+27], mem[START_ADDR+26], mem[START_ADDR+25], mem[START_ADDR+24]} = {8'h00, 8'hd6, 8'h7f, 8'hb3};
  // Setting 32-bit instruction: or a7, a4, a5
  {mem[START_ADDR+31], mem[START_ADDR+30], mem[START_ADDR+29], mem[START_ADDR+28]} = {8'h00, 8'hf7, 8'h68, 8'hb3};
end

//SEQUENTIAL LOGIC FOR WRITE OPERATION (store)
always @ (posedge clk) begin
    if (read_write) begin
        case(access_size)
            2'd0:  mem[address]                                                     <= data_in[7:0];  //byte
            2'd1: {mem[address+1], mem[address]}                                    <= data_in[15:0]; //half
            2'd2: {mem[address+3], mem[address+2], mem[address+1], mem[address]}    <= data_in;       //word
            default: ;
        endcase
    end 
end

//COMBINATIONAL LOGIC FOR READ OPERATION (load)
assign data_out = (!read_write) ? {mem[address+3], mem[address+2], mem[address+1], mem[address]} : 32'hx;
//outputting full 32 bits of the line we want, sign extending in top.v


endmodule