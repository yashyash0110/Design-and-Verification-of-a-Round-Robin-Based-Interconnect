interface arb_intf(input logic clk, input logic reset);

  logic [3:0] REQ;
  logic [3:0] GNT;

  Packet  master_in_data [4];   // Inputs from masters
  Packet master_out_data;      // Output to memory

  logic [31:0] rdata;              // From memory
  logic        rdata_ack;          // From memory

  logic [31:0] slave_rdata;        // To interconnect/APB slave
  logic        slave_rdata_ack;  // To interconnect/APB slave

endinterface
