//Transaction or Packet or sequence item Class
class packet extends uvm_sequence_item;
  `uvm_object_utils(packet)
 
  rand logic [3:0] REQ;
       logic [3:0] GNT; //Ouput of Grant
  
  rand Packet master_in_data [4];
       Packet master_out_data; //Output Signals of Arbiter - Sent to Memory
  
  rand logic [31:0] rdata;
  rand logic rdata_ack;
 
  //Output Signals of Arbiter - Sent to APB Slave
  logic [31:0] slave_rdata;
  logic slave_rdata_ack;
      
  
  function new(input string name = "packet");
    super.new(name);
  endfunction
  
endclass
