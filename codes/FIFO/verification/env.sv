// ENVIRONMENT
class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  fifo_agent agt;
  fifo_scoreboard scb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    agt = fifo_agent::type_id::create("agt", this);
    scb = fifo_scoreboard::type_id::create("scb", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    agt.mon.mon_port.connect(scb.analysis_export);
  endfunction
endclass
