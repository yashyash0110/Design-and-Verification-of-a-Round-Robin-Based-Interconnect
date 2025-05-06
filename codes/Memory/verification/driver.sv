//Driver Class
class driver extends uvm_driver#(packet);
  `uvm_component_utils(driver)
  
  packet pkt;
  virtual apb_intf apbif;
  
  function new(string name = "driver",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this,"","apbif",apbif))
      `uvm_error(get_type_name(),"Unable to access Interface")
    else
      `uvm_info(get_type_name(),"Successfully got access to Interface",UVM_MEDIUM)
    
    pkt = packet::type_id::create("pkt");
    
  endfunction
  
  task reset_dut();
    repeat(5)
      begin
        apbif.PRESET <= 1'b0;
        apbif.PADDR <= 'h0;
        apbif.PWDATA <= 'h0;
        apbif.PWRITE <= 'b0;
        apbif.PSEL <= 'b0;
        apbif.PENABLE <= 'b0;
        `uvm_info(get_type_name(),"System Reset : Start of Simulation",UVM_MEDIUM)@(posedge apbif.PCLK);
      end
  endtask
  
  task drive();
    reset_dut();
    forever begin
      seq_item_port.get_next_item(pkt);
      
      if (pkt.op == RESET)
        begin
          apbif.PRESET <= 1'b0;
          @(posedge apbif.PCLK);
        end
      
      else if (pkt.op == WRITE)
        begin
          apbif.PSEL <= 1'b1;
          apbif.PADDR <= pkt.PADDR;
          apbif.PWDATA <= pkt.PWDATA;
          apbif.PRESET <= 1'b1;
          apbif.PWRITE <= 1'b1;
          @(posedge apbif.PCLK);
          apbif.PENABLE <= 1'b1;
          `uvm_info(get_type_name(),$sformatf("Mode:%0s, addr:%0d, wdata:%0d, rdata:%0d, slverr:%0d",pkt.op.name(),pkt.PADDR,pkt.PWDATA,pkt.PRDATA,pkt.PSLVERR),UVM_MEDIUM)
          @(negedge apbif.PREADY);
          apbif.PENABLE <= 1'b0;
          apbif.PSLVERR <= pkt.PSLVERR;
        end
      else if (pkt.op == READ)
        begin
          apbif.PSEL <= 1'b1;
          apbif.PADDR <= pkt.PADDR;
          apbif.PRESET <= 1'b1;
          apbif.PWRITE <= 1'b1;
          @(posedge apbif.PCLK);
          apbif.PENABLE <= 1'b1;
          `uvm_info(get_type_name(),$sformatf("Mode:%0s, addr:%0d, wdata:%0d, rdata:%0d, slverr:%0d",pkt.op.name(),pkt.PADDR,pkt.PWDATA,pkt.PRDATA,pkt.PSLVERR),UVM_MEDIUM)
          @(negedge apbif.PREADY);
          apbif.PENABLE <= 1'b0;
          apbif.PRDATA = pkt.PRDATA;
          apbif.PSLVERR = pkt.PSLVERR;
        end
      seq_item_port.item_done();
    end
  endtask
  
  virtual task run_phase(uvm_phase phase);
    drive();
  endtask
  
endclass
