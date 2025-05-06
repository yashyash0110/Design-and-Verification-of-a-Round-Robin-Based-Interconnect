// MONITOR
class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)

  virtual fifo_intf fif;
  uvm_analysis_port#(fifo_transaction) mon_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_port = new("Monitor Port", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual fifo_intf)::get(this, "", "fif", fif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
    else
      `uvm_info(get_type_name(),"Successfully got access to Interface",UVM_MEDIUM)
  endfunction

  virtual task run_phase(uvm_phase phase);
    fifo_transaction tr;
    forever begin
      #20;
      tr = fifo_transaction::type_id::create("tr");
      tr.fifo_packet_out = fif.fifo_packet_out;
      `uvm_info(get_type_name(),$sformatf("wdata:%0d addr:%0d write:%0d",tr.fifo_packet_out.wdata,tr.fifo_packet_out.addr,tr.fifo_packet_out.write),UVM_MEDIUM)
      mon_port.write(tr);
    end
  endtask
endclass
