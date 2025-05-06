`timescale 1ns/1ps

module apb_slave_fifo_tb;

  // Testbench Signals
  logic clk;
  logic reset;
  logic push_in;
  logic pop_in;
  logic write;
  logic [31:0] push_wdata_in;
  logic [31:0] push_addr_in;
  logic [31:0] pop_wdata_out;
  logic [31:0] pop_addr_out;
  logic data_in_ack;
  logic full_o;
  logic empty_o;
  logic arb_write;

  // Instantiate the DUT (Device Under Test)
  apb_slave_fifo dut (
    .clk(clk),
    .reset(reset),
    .push_in(push_in),
    .pop_in(pop_in),
    .push_wdata_in(push_wdata_in),
    .push_addr_in(push_addr_in),
    .pop_wdata_out(pop_wdata_out),
    .pop_addr_out(pop_addr_out),
    .data_in_ack(data_in_ack),
    .full_o(full_o),
    .empty_o(empty_o),
    .write(write)
  );

  // Clock Generation (10ns period)
  always #5 clk = ~clk;

  // Reset Sequence
  initial begin
    clk = 0;
    reset = 1;
    #10 reset = 0;
    #10 reset = 1;
  end

  // Stimulus: Push and Pop Operations
  initial begin
    // Initialize inputs
    push_in = 0;
    pop_in = 0;
    write = 0;
    push_wdata_in = 0;
    push_addr_in = 0;
    
    #20;
    
    // PUSH 8 values into FIFO
    for (int i = 0; i < 8; i++) begin
      @(posedge clk);
      push_in = 1;
      write = 1;
      push_wdata_in = i * 10;
      push_addr_in = i * 4;
    end
    @(posedge clk);
    push_in = 0;
    write = 0;

    // Try pushing when FIFO is full
    @(posedge clk);
    push_in = 1;
    write = 1;
    push_wdata_in = 999;
    push_addr_in = 999;
    @(posedge clk);
    push_in = 0;
    write = 0;

    // POP all values from FIFO
    for (int i = 0; i < 8; i++) begin
      @(posedge clk);
      pop_in = 1;
    end
    @(posedge clk);
    pop_in = 0;

    #20 $finish;
  end

  // Monitoring signals
  initial begin
    $monitor("Time=%0t | push_in=%b | pop_in=%b | write=%b | push_wdata_in=%h | push_addr_in=%h | pop_wdata_out=%h | pop_addr_out=%h | full_o=%b | empty_o=%b", 
              $time/1000, push_in, pop_in, write, push_wdata_in, push_addr_in, pop_wdata_out, pop_addr_out, full_o, empty_o);
  end

  // Dump Waveform for Analysis
  initial begin
    $dumpfile("apb_slave_fifo_tb.vcd");
    $dumpvars(0, apb_slave_fifo_tb);
  end

endmodule
