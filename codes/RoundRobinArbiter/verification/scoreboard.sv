//Scoreboard Class
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp#(packet,scoreboard) recv;
  
  function new(string name = "scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("Receiver Port",this);
  endfunction
  
  virtual function void write(packet pkt);
    `uvm_info(get_type_name(),$sformatf("Data is Received"),UVM_MEDIUM)
    
    $display("----------------------------------------------------------------------------");
  endfunction
endclass
