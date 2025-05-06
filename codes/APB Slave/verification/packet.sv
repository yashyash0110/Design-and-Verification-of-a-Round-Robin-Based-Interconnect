typedef enum bit [1:0] {READ=0,WRITE=1,RESET=2} oper_mode;

//Transaction or Packet or sequence item Class
class packet extends uvm_sequence_item;
  `uvm_object_utils(packet)
  
  rand oper_mode op;
  rand logic  PCLK,PRESET,PWRITE,PSEL,PENABLE;
  rand logic [31:0] PADDR,PWDATA;

  rand logic fifo_data_in_ack;     
  rand logic full_o;
  rand logic empty_o;

  rand logic arb_rdata_ack;
  rand logic [31:0] arb_rdata;
  
  //Output Signals of DUT for APB transaction
  logic PREADY;
  logic PSLVERR;
  logic [31:0] PRDATA;
  
  constraint addr_c {PADDR <= 31; }
  constraint addr_c_err {PADDR > 31; }
  
  function new(input string name = "packet");
    super.new(name);
  endfunction
  
endclass
