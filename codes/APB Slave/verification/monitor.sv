
//Monitor Class
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  packet pkt;
  virtual apb_intf apbif;
  
  uvm_analysis_port #(packet) mon_port;
  
  function new(string name = "monitor",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this,"","apbif",apbif))
      `uvm_error(get_type_name(),"Unable to access Interface")
    else
      `uvm_info(get_type_name(),"Successfully got access to Interface",UVM_MEDIUM)
    
    mon_port = new("Monitor Port",this);
    pkt = packet::type_id::create("pkt",this);
  
  endfunction
    
  virtual task run_phase(uvm_phase phase);
    forever
      begin
        #20;
        if(!apbif.PRESET)
          begin
            pkt.op = RESET;
            `uvm_info(get_type_name(),"System Reset Detected",UVM_MEDIUM)
            mon_port.write(pkt);
          end
        else if (apbif.PRESET && apbif.PWRITE)
          begin
            @(negedge apbif.PREADY);
            pkt.op = WRITE;
            pkt.PWDATA = apbif.PWDATA;
            pkt.PADDR = apbif.PADDR;
            pkt.PSLVERR = apbif.PSLVERR;
            `uvm_info(get_type_name(),$sformatf("DATA WRITE addr:%0d data:%0d slverr:%0d",pkt.PADDR,pkt.PWDATA,pkt.PSLVERR),UVM_MEDIUM)
            mon_port.write(pkt);
          end
        else if(apbif.PRESET && !apbif.PWRITE)
          begin
            @(negedge apbif.PREADY);
            pkt.op = READ;
            pkt.PRDATA = apbif.PRDATA;
            pkt.PADDR = apbif.PADDR;
            pkt.PSLVERR = apbif.PSLVERR;
            `uvm_info(get_type_name(),$sformatf("DATA READ addr:%0d data:%0d slverr:%0d",pkt.PADDR,pkt.PWDATA,pkt.PSLVERR),UVM_MEDIUM)
            mon_port.write(pkt);
          end
      end
  endtask
  
endclass
