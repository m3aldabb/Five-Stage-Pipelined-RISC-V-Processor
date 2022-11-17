module dmemory(
    input         clock,
    input  [31:0] address,  
    input         read_write,
    input  [1:0]  access_size,
    input  [31:0] data_in,  
    output [31:0] data_out  
);

localparam START_ADDR = 32'h01000000;
reg [7:0]  mem  [`MEM_DEPTH-1:0];

//INITIALIZING DMEM TO .x
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

//SEQUENTIAL LOGIC FOR WRITE OPERATION (store)
always @ (posedge clock) begin
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
//outputting full 32 bits of the line we want, sign extending in pd.v


endmodule