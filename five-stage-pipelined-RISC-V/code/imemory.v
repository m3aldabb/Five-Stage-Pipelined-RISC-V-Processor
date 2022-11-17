module imemory 
#(
  parameter ADDRWIDTH = 32,
  parameter DATAWIDTH = 32
)
(
    input clock,
    input  [ADDRWIDTH-1:0] address,
    input  read_write,
    input  [DATAWIDTH-1:0] data_in,
    output [DATAWIDTH-1:0] data_out
);

localparam START_ADDR = 32'h01000000;
reg [7:0]  mem  [`MEM_DEPTH-1:0];

integer i;
reg [31:0] temp [`LINE_COUNT-1:0];                    

initial begin
  $readmemh(`MEM_PATH, temp, 0, `LINE_COUNT-1);

  for (i=0; i<`LINE_COUNT; i=i+1) begin
    {
      mem[START_ADDR + (i*4)+3],
      mem[START_ADDR + (i*4)+2],
      mem[START_ADDR + (i*4)+1],
      mem[START_ADDR + (i*4)]
    } = temp[i];
  end
end

//COMBINATIONAL LOGIC FOR READ OPERATION
assign data_out = (!read_write) ? { mem[address+3], mem[address+2], mem[address+1], mem[address] } : 32'hx;

//SEQUENTIAL LOGIC FOR WRITE OPERATION
always @ (posedge clock) begin
    if (read_write) begin                                           
        {mem[address+3], mem[address+2], mem[address+1], mem[address]} <= data_in;
    end 

end

endmodule
