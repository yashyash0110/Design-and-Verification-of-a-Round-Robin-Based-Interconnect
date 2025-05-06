//Monitor Class
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  packet pkt;
  virtual arb_intf arbif;
  
  uvm_analysis_port #(packet) mon_port;
  
  function new(string name = "monitor",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual arb_intf)::get(this,"","arbif",arbif))
      `uvm_error(get_type_name(),"Unable to access Interface")
    else
      `uvm_info(get_type_name(),"Successfully got access to Interface",UVM_MEDIUM)
    
    mon_port = new("Monitor Port",this);
    pkt = packet::type_id::create("pkt");
  
  endfunction
    
  virtual task run_phase(uvm_phase phase);
    forever begin
      #20;
      pkt.REQ = arbif.REQ ;
      pkt.GNT = arbif.GNT;
      pkt.master_in_data = arbif.master_in_data;
      pkt.master_out_data = arbif.master_out_data;
      pkt.rdata = arbif.rdata;
      pkt.rdata_ack = arbif.rdata_ack;
      pkt.slave_rdata = arbif.slave_rdata;
      pkt.slave_rdata_ack = arbif.slave_rdata_ack;
      
      `uvm_info(get_type_name(),
                $sformatf("OUTPUT -> GNT:%0b WDATA: %0h, ADDR: %0h, WRITE: %0b slave_rdata:%0h slave_rdata_ack:%0b",
                      pkt.GNT,
                      pkt.master_out_data.wdata,
                      pkt.master_out_data.addr,
                      pkt.master_out_data.write,
                      pkt.slave_rdata,
                      pkt.slave_rdata_ack),
            UVM_MEDIUM)
      mon_port.write(pkt);
    end
  endtask
  
endclass
