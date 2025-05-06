`include "interconnect.sv"
`include "apb_slave_memory.sv"  // This is your APB memory module

module top(input logic clk,
           input logic reset,
           apb_intf apb_bus[3:0] //For 4 Masters
          );

  // === APB Interface Declarations ===
  apb_intf.master apb_mem_bus();          // To memory

  // === DUT: Interconnect ===
  interconnect_ u_interconnect (
    .clk         (clk),
    .reset       (reset),
    .apb_bus     (apb_bus),
    .apb_mem_bus (apb_mem_bus)
  );

  // === APB Slave Memory ===
  apb_slave_memory u_apb_slave_memory (
    .PCLK    (apb_mem_bus.PCLK),
    .PRESET  (apb_mem_bus.PRESET),
    .PADDR   (apb_mem_bus.PADDR),
    .PWDATA  (apb_mem_bus.PWDATA),
    .PRDATA  (apb_mem_bus.PRDATA),
    .PWRITE  (apb_mem_bus.PWRITE),
    .PSEL    (apb_mem_bus.PSEL),
    .PENABLE (apb_mem_bus.PENABLE),
    .PREADY  (apb_mem_bus.PREADY),
    .PSLVERR (apb_mem_bus.PSLVERR)
  );

endmodule
