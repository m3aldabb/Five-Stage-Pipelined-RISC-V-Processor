`timescale 1ns/1ns
module dut_tb();

logic clk, rst;
always #5 clk = ~clk;

riscv_top dut (
    .clk(clk),
    .rst(rst)
);

initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, dut_tb);
    clk = 1'b0;
    rst = 1'b0;

    @(posedge clk);
    rst = 1'b1;
    @(posedge clk);
    rst = 1'b0;

    #100000;
    $finish();
end

endmodule