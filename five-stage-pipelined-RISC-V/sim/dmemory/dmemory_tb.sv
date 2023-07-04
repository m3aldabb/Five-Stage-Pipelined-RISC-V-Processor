`timescale 1ps / 1ps

module dmemory_tb();
localparam START_ADDR = 32'h01000000;
    reg         clk;
    reg  [31:0] address;  
    reg         read_write;
    reg  [1:0]  access_size;
    reg  [31:0] data_in;  
    wire [31:0] data_out;

    dmemory dut(
        .clk(clk),
        .address(address),
        .read_write(read_write),
        .access_size(access_size),
        .data_in(data_in),
        .data_out(data_out)
    );

always #5 clk = ~clk;
    initial begin
            $dumpfile("waves.vcd");
            $dumpvars(0, dmemory_tb);
        clk = 1'b0;
        #10;

        address = START_ADDR; read_write = 1; access_size = 2'd2; data_in = 32'd21972; #10;
        $display("in=%h out=%h  read_write=%b   access_size=%b",data_in, data_out, read_write, access_size);
        address = START_ADDR; read_write = 0; access_size = 2'd0; data_in = 32'd21972; #50;
        $display("in=%h out=%h  read_write=%b   access_size=%b",data_in, data_out, read_write, access_size);

        $finish;
    end  

endmodule