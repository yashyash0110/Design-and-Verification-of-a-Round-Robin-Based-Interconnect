// SCOREBOARD
class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)

  uvm_analysis_imp#(fifo_transaction, fifo_scoreboard) analysis_export;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
  endfunction

  virtual function void write(fifo_transaction tr);
    if(tr.write == 1'b1)
      `uvm_info(get_type_name(),"WRITE REQ",UVM_MEDIUM)
    else
      `uvm_info(get_type_name(),"READ REQ",UVM_MEDIUM)
    $display("-------------------------------------\n");
    
  endfunction
endclass
