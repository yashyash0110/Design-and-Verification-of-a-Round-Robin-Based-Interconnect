class config_apb extends uvm_object;
  `uvm_object_utils(config_apb)

  uvm_active_passive_enum agent_type = UVM_ACTIVE;

  function new(string name = "config_apb");
    super.new(name);
  endfunction
endclass

//Agent Class
class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  sequencer seqr;
  driver drv;
  monitor mon;
  
  config_apb cfg;
  
  function new(string name = "agent",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    mon = monitor::type_id::create("mon",this);  
    
    cfg = config_apb::type_id::create("cfg",this);
    seqr = sequencer::type_id::create("seqr",this);
    
    if(!uvm_config_db#(config_apb)::get(this,"","cfg",cfg))
      `uvm_error(get_type_name(),"Failed to access config")
    
    if(cfg.agent_type == UVM_ACTIVE)
      begin
        drv = driver::type_id::create("drv",this);
        `uvm_info(get_type_name(),"Successfully got access to config",UVM_MEDIUM)
      end
    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
  
endclass
