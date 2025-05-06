// TRANSACTION
class fifo_transaction extends uvm_sequence_item;
  rand bit [31:0] wdata;
  rand bit [31:0] addr;
  rand bit write;
  
  packet_out fifo_packet_out;

  `uvm_object_utils(fifo_transaction)

  function new(string name = "fifo_transaction");
    super.new(name);
  endfunction

endclass
