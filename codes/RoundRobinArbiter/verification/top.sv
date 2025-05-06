//Top Class
`include "uvm_macros.svh" 
import uvm_pkg::*; 

`include "packet.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "env.sv"
`include "test.sv"

`include "interface.sv"

module top;
  
  logic clk,reset;
  
  //Interface Instance
  arb_intf arbif(.clk(clk),.reset(reset));
  
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
  
  //Set config db
  initial begin
    uvm_config_db#(virtual arb_intf)::set(null,"*","arbif",arbif);
  end
  
  initial begin
    run_test("test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
