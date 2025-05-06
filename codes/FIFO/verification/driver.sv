// DRIVER
class fifo_driver extends uvm_driver#(fifo_transaction);
  `uvm_component_utils(fifo_driver)

  virtual fifo_intf fif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fifo_intf)::get(this, "", "fif", fif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
    else
      `uvm_info(get_type_name(),"Successfully got access to Interface",UVM_MEDIUM)
  endfunction

  virtual task run_phase(uvm_phase phase);
    fifo_transaction tr;
    forever begin
      seq_item_port.get_next_item(tr);
      fif.push_in = 1;
      fif.push_wdata_in = tr.wdata;
      fif.push_addr_in = tr.addr;
      fif.write = tr.write;
      fif.pop_in = 0;
      `uvm_info(get_type_name(),$sformatf("wdata:%0d addr:%0d write:%0d",tr.wdata,tr.addr,tr.write),UVM_MEDIUM)
      #20;
      fif.pop_in = 1;
      `uvm_info(get_type_name(),$sformatf("wdata:%0d addr:%0d write:%0d",tr.wdata,tr.addr,tr.write),UVM_MEDIUM)
      seq_item_port.item_done();
      #20;
    end
  endtask
endclass

