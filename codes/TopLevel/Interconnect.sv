`include "apb_slave_interconnect.sv"
`include "apb_slave_fifo.sv"
`include "round_robin_arbiter.sv"
`include "apb_master_intf.sv"

interface apb_intf();
  logic PCLK;  
  logic PRESET;
  logic [31:0] PADDR;
  logic [31:0] PWDATA;
  logic [31:0] PRDATA;
  logic PWRITE;
  logic PSEL;
  logic PENABLE;
  logic PREADY;
  logic PSLVERR;

  modport slave (
    input  PCLK,PRESET,PADDR, PWDATA, PWRITE, PSEL, PENABLE,
    output PREADY, PSLVERR, PRDATA
  );
  
  modport master(
    output  PCLK,PRESET,PADDR, PWDATA, PWRITE, PSEL, PENABLE,
    input PREADY, PSLVERR, PRDATA
  );
endinterface

module interconnect_(input logic clk,
                     input logic reset,
                     apb_intf.slave apb_bus[3:0],
                     apb_intf.master apb_mem_bus
                    );

  //FIFO & Slave internal connections
  logic [3:0]           push_in;
  logic [31:0]          push_wdata_in [3:0];
  logic [31:0]          push_addr_in  [3:0];
  logic [3:0]           fifo_write;
  logic [3:0]           fifo_data_in_ack;
  logic [3:0]           full_o;

  //Slave & Arbiter connections
  logic [31:0]          arb_rdata [3:0];
  logic [3:0]           arb_rdata_ack;
  
  //Arbiter & FIFO connections
  logic [3:0] REQ;
  logic [3:0] GNT;
  packet master_in_data [3:0];
  
  packet master_data_out;
  logic [31:0] rdata;  
  logic rdata_ack; 
  
  logic [3:0] pop_in;
  
  //Arbiter & Slave connections
  logic [31:0] slave_rdata; 
  logic        slave_rdata_ack;
  
  packet fifo_packet_out [3:0];
  logic [3:0] arb_req;

  // --- Generate block ---
  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : INTERCONNECT_SUB

      //APB Slave
      apb_slave_interconnect u_slave (
        .PCLK      (apb_bus[i].PCLK),
        .PRESET    (apb_bus[i].PRESET),
        .PWRITE    (apb_bus[i].PWRITE),
        .PSEL      (apb_bus[i].PSEL),
        .PENABLE   (apb_bus[i].PENABLE),
        .PADDR     (apb_bus[i].PADDR),
        .PWDATA    (apb_bus[i].PWDATA),
        .PRDATA    (apb_bus[i].PRDATA),
        .PREADY    (apb_bus[i].PREADY),
        .PSLVERR   (apb_bus[i].PSLVERR),

        // FIFO <-> Interconnect connections
        .push_in          (push_in[i]),
        .push_wdata_in    (push_wdata_in[i]),
        .push_addr_in     (push_addr_in[i]),
        .fifo_write       (fifo_write[i]),
        .fifo_data_in_ack (fifo_data_in_ack[i]),
        .full_o           (full_o[i]),

        // Arbiter Interface
        .arb_rdata_ack    (arb_rdata_ack[i]),
        .arb_rdata        (arb_rdata[i])
      );
      
      //APB FIFO 
      apb_slave_fifo u_fifo (
        .clk(clk),
        .reset(reset),
        .push_in(push_in[i]),
        .push_wdata_in(push_wdata_in[i]),
        .push_addr_in(push_addr_in[i]),
        .write(fifo_write[i]),
        .data_in_ack(fifo_data_in_ack[i]),
        .full_o(full_o[i]),
        .pop_in(pop_in[i]),
        .fifo_packet_out(fifo_packet_out[i]),
        .arb_req(arb_req[i])
      );
      
      assign master_in_data[i] = fifo_packet_out[i];//FIFO to Arbiter
      assign REQ[i] = arb_req[i]; //FIFO to Arbiter
      assign pop_in[i] = GNT[i];  //Arbiter to FIFO
    end
  endgenerate
   
   //Round Robin Arbiter
      round_robin_arbiter u_arbiter(
        .clk(clk),
        .reset(reset),
        .REQ(REQ),
        .GNT(GNT),
        .master_in_data(master_in_data),
        .master_out_data(master_data_out),
        .rdata(rdata),
        .rdata_ack(rdata_ack),
        .slave_rdata(slave_rdata),
        .slave_rdata_ack(slave_rdata_ack)
      );
  
  assign apb_mem_bus.PADDR   = master_data_out.addr;
  assign apb_mem_bus.PWDATA  = master_data_out.wdata;
  assign apb_mem_bus.PWRITE  = master_data_out.write;
  assign rdata     = apb_mem_bus.PRDATA;
  assign rdata_ack = apb_mem_bus.PREADY;
  
  //APB Master Interface at the memory boundary of the Interconnect
  apb_master_mem u_apb_master_mem(.mem_bus(apb_mem_bus)); 

  
  always_comb
    begin
      arb_rdata_ack = 0;
      arb_rdata     = '{default:32'b0};
      case(GNT)
            4'b0001:
              begin
                arb_rdata[0] = slave_rdata;
                arb_rdata_ack[0] = slave_rdata_ack;
              end
            4'b0010:
              begin
                arb_rdata[1] = slave_rdata;
                arb_rdata_ack[1] = slave_rdata_ack;
              end
            4'b0100:
              begin
                arb_rdata[2] = slave_rdata;
                arb_rdata_ack[2] = slave_rdata_ack;
              end
            4'b1000:
              begin
                arb_rdata[3] = slave_rdata;
                arb_rdata_ack[3] = slave_rdata_ack;
              end
          endcase
    end

endmodule
