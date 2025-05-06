// TEST
class fifo_test extends uvm_test;
  `uvm_component_utils(fifo_test)

  fifo_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    fifo_sequence seq;
    phase.raise_objection(this);
    $display("TEST STARTED.....\n");
    seq = fifo_sequence::type_id::create("seq");
    seq.start(env.agt.seqr);
    #20;
    phase.drop_objection(this);
  endtask
endclass
