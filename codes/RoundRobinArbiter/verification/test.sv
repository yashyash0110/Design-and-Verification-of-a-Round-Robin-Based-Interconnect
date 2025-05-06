//Test Class
class test extends uvm_test;
  `uvm_component_utils(test)
  
  env envmt;
  random sq1;
  
  function new(string name = "test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    envmt = env::type_id::create("envmt",this);
    sq1 = random::type_id::create("sq1",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    $display("TEST STARTED.....\n");
    sq1.start(envmt.agnt.seqr);
    phase.drop_objection(this);
  endtask
  
endclass
