`timescale 1ns/1ps

module apb_slave_tb;

  // APB Interface Signals
  logic PCLK, PRESET, PWRITE, PSEL, PENABLE;
  logic [31:0] PADDR, PWDATA;
  logic [31:0] PRDATA;
  logic PREADY, PSLVERR;
  
  // FIFO Interface Signals
  logic fifo_clk, fifo_reset;
  logic push_in;
  logic [31:0] push_wdata_in, push_addr_in;
  logic fifo_write;
  logic fifo_data_in_ack;
  logic full_o, empty_o;
  
  // Arbiter Interface Signals
  logic arb_rdata_ack;
  logic [31:0] arb_rdata;

  // Instantiate the APB Slave Interconnect
  apb_slave_interconnect uut (
    .PCLK(PCLK), .PRESET(PRESET), .PWRITE(PWRITE), .PSEL(PSEL), .PENABLE(PENABLE),
    .PADDR(PADDR), .PWDATA(PWDATA), .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR),
    .fifo_clk(fifo_clk), .fifo_reset(fifo_reset), .push_in(push_in),
    .push_data_in(push_wdata_in), .full_o(full_o), .empty_o(empty_o),
    .arb_rdata_ack(arb_rdata_ack), .arb_rdata(arb_rdata)
  );

  // Clock Generation
  always #5 PCLK = ~PCLK;
  
  // Test Sequence
  initial begin
    // Initialize signals
    PCLK = 0;
    PRESET = 0;
    PSEL = 0;
    PENABLE = 0;
    PWRITE = 0;
    PADDR = 0;
    PWDATA = 0;
    fifo_data_in_ack = 0;
    full_o = 0;
    empty_o = 1;
    arb_rdata_ack = 0;
    arb_rdata = 32'hDEADBEEF;
    
    // Reset Pulse
    #10 PRESET = 1;
    
    // Write Transaction
    #10 PSEL = 1; PWRITE = 1; PADDR = 32'h00000010; PWDATA = 32'hA5A5A5A5;
    #10 PENABLE = 1;
    #10 PENABLE = 0; fifo_data_in_ack = 1;
    #10 fifo_data_in_ack = 0;
    
    // Read Transaction
    #10 PSEL = 1; PWRITE = 0; PADDR = 32'h00000010;
    #10 PENABLE = 1;
    #10 PENABLE = 0; arb_rdata_ack = 1;
    #10 arb_rdata_ack = 0;
    
    // Finish Simulation
    #50 $finish;
  end

endmodule
