///Top Class
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
  
  apb_intf apbif();
  
  //Clock Generation
  initial begin
    apbif.PCLK=1'b0;
    forever #10 apbif.PCLK = ~ apbif.PCLK;
  end
  
  initial begin
    apbif.PRESET = 1'b0;
    #20 apbif.PRESET = 1'b1;
  end
  
  
  apb_slave_memory dut(.PCLK(apbif.PCLK),.PRESET(apbif.PRESET),.PWRITE(apbif.PWRITE),.PSEL(apbif.PSEL),.PENABLE(apbif.PENABLE),.PADDR(apbif.PADDR),.PWDATA(apbif.PWDATA),.PRDATA(apbif.PRDATA),.PREADY(apbif.PREADY),.PSLVERR(apbif.PSLVERR));
  
  initial begin
    uvm_config_db#(virtual apb_intf)::set(null,"*","apbif",apbif);
  end
  
  initial begin
    run_test("test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
