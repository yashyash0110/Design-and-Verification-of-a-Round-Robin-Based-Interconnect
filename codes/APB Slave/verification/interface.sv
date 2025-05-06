interface apb_intf;
  
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
endinterface
