module testbench();
  reg clk;
  reg rst;
  reg [3:0]REQ;
  wire [3:0]GNT;
  
  //Instantiation of DUT
  round_robin_arbiter dut(.clk(clk),.reset(rst),.REQ(REQ),.GNT(GNT));
  
  initial begin
    clk=0;
    forever #5 clk=~clk;
  end
  
  initial begin
    rst=0;
    REQ=4'b0000;
    #5 rst=1;
    while($time<=50)
      @(negedge clk) REQ=$random;
    #10 rst=0; 
    $finish;
  end
  
  initial begin
    $monitor("%d Clk:%b Reset:%b REQ:%b GNT:%b",$time,clk,rst,REQ,GNT);
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
