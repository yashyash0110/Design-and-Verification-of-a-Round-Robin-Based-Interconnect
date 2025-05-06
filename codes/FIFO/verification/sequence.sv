// SEQUENCE
class fifo_sequence extends uvm_sequence#(fifo_transaction);
  `uvm_object_utils(fifo_sequence)

  function new(string name = "fifo_sequence");
    super.new(name);
  endfunction

  virtual task body();
    fifo_transaction tr;
    repeat (10) begin
      tr = fifo_transaction::type_id::create("tr");
      start_item(tr);
      tr.randomize();
      finish_item(tr);
    end
  endtask
endclass
