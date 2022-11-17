`timescale 1ps / 1ps
`include "../code/dmemory.v"

module dmemory_tb();
localparam START_ADDR = 32'h01000000;
    reg         clock;
    reg  [31:0] address;  
    reg         read_write;
    reg  [1:0]  access_size;
    reg         load_un;
    reg  [31:0] data_in;  
    wire [31:0] data_out;

    dmemory uut(
        .clock(clock),
        .address(address),
        .read_write(read_write),
        .access_size(access_size),
        .load_un(load_un),
        .data_in(data_in),
        .data_out(data_out)
    );

always #5 clock = ~clock;
    initial begin
            $dumpfile("dmemory_tb.vcd");
            $dumpvars(0, dmemory_tb);
        clock = 1'b0;
        #10;

        address = START_ADDR; read_write = 1; access_size = 2'd2; load_un = 0; data_in = 32'd21972; #10;
        $display("in=%h out=%h  read_write=%b   access_size=%b",data_in, data_out, read_write, access_size);
        address = START_ADDR; read_write = 0; access_size = 2'd0; load_un = 0; data_in = 32'd21972; #50;
        $display("in=%h out=%h  read_write=%b   access_size=%b",data_in, data_out, read_write, access_size);

        $finish;
    end  

endmodule