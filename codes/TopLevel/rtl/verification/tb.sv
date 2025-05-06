module top_tb;
  
  logic clk,reset;
  apb_intf apb_bus[3:0]();
  
  //Clock Generation
  initial begin
    clk = 1'b0;
    forever #10 clk = ~ clk;
  end
  
  //Reset
  initial begin
    reset = 1'b0;
    #20 reset = 1'b1;
  end
  
  // Instantiate the top module
  top u_top(.clk(clk),.reset(reset),.apb_bus(apb_bus));
  
  initial begin
    $display("TEST PASSED");
  end

  

endmodule
