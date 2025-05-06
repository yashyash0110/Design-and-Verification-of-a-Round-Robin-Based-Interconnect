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
  
  //Interface Instance
  fifo_intf fif(.clk(clk),.reset(reset));
  
  //DUT Instantiation
  apb_slave_fifo dut (
    .clk(clk),
    .reset(reset),
    .push_in(fif.push_in),
    .push_wdata_in(fif.push_wdata_in),
    .push_addr_in(fif.push_addr_in),
    .write(fif.write),
    .data_in_ack(fif.data_in_ack),
    .full_o(fif.full_o),
    .pop_in(fif.pop_in),
    .fifo_packet_out(fif.fifo_packet_out),
    .arb_req(fif.arb_req)
  );
  
  //Set config db
  initial begin
    uvm_config_db#(virtual fifo_intf)::set(null,"*","fif",fif);
    $display("INTERFACE IS SET.........");
  end
  
  initial begin
    run_test("fifo_test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
