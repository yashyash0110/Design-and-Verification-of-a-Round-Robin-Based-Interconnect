
// INTERFACE
interface fifo_intf(input logic clk, input logic reset);
  
  logic push_in;
  logic [31:0] push_wdata_in;
  logic [31:0] push_addr_in;
  logic write;
  logic data_in_ack;
  logic full_o;
  logic pop_in;
  packet_out fifo_packet_out;
  logic arb_req;
  
endinterface
