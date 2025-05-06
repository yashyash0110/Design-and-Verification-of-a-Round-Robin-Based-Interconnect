//Driver Class
class driver extends uvm_driver#(packet);
  `uvm_component_utils(driver)
  
  packet pkt;
  virtual arb_intf arbif;
  
  function new(string name = "driver",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual arb_intf)::get(this,"","arbif",arbif))
      `uvm_error(get_type_name(),"Unable to access Interface")
    else
      `uvm_info(get_type_name(),"Successfully got access to Interface",UVM_MEDIUM)
      
      pkt = packet::type_id::create("pkt");
      
  endfunction
  
  virtual function void reset_dut();
    arbif.REQ = 4'b0000;
    for (int i=0; i<4 ; i++)
      begin
        arbif.master_in_data[i].wdata = 32'h0;
        arbif.master_in_data[i].addr = 32'h0;
        arbif.master_in_data[i].write = 1'b0;
      end
    arbif.rdata = 32'h0;
    arbif.rdata_ack = 1'b0;
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      reset_dut();
      seq_item_port.get_next_item(pkt);
      //Drive inputs via interface to the DUT
      arbif.REQ = pkt.REQ;
      arbif.master_in_data = pkt.master_in_data;
      arbif.rdata = pkt.rdata;
      arbif.rdata_ack = pkt.rdata_ack;
      
      `uvm_info(get_type_name(),$sformatf("REQ:%0b",pkt.REQ),UVM_MEDIUM)
      for (int i = 0; i < 4; i++) begin
        `uvm_info(get_type_name(),
            $sformatf("MASTER[%0d] -> WDATA: %0h, ADDR: %0h, WRITE: %0b",
                      i,
                      pkt.master_in_data[i].wdata,
                      pkt.master_in_data[i].addr,
                      pkt.master_in_data[i].write),
            UVM_MEDIUM)
      end
      `uvm_info(get_type_name(),$sformatf("rdata:%0h rdata_ack:%0b ",pkt.rdata,pkt.rdata_ack),UVM_MEDIUM)
      seq_item_port.item_done();
      #20;
    end
    
  endtask
endclass
