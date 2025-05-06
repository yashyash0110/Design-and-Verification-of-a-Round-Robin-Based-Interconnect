interface apb_intf;
  logic PCLK,PRESET,PWRITE,PSEL,PENABLE;
  logic  [31:0] PADDR,PWDATA;
  logic [31:0] PRDATA;
  logic PREADY,PSLVERR;
endinterface
