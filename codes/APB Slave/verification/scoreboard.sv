//Scoreboard Class
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp#(packet,scoreboard) recv;
  
  bit [31:0] arr[32] ='{default:0};
  bit [31:0] addr = 0;
  bit [31:0] data_rd = 0;
  
  
  function new(string name = "scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("Receiver Port",this);
  endfunction
  
  virtual function void write(packet pkt);
    if (pkt.op == RESET)
        `uvm_info(get_type_name(),"SYSTEM RESET DETECTED",UVM_MEDIUM)
    
    else if(pkt.op == WRITE)
        if(pkt.PSLVERR == 1'b1)
            `uvm_info(get_type_name(),"SLV ERROR during WRITE OP",UVM_MEDIUM)
        else 
            `uvm_info(get_type_name(),$sformatf("DATA WRITE OP addr:%0d wdata:%0d arr_wr:%0d",pkt.PADDR,pkt.PWDATA,arr[pkt.PADDR]),UVM_MEDIUM)

    else if(pkt.op == READ)
        if(pkt.PSLVERR == 1'b1)
            `uvm_info(get_type_name(),"SLV ERROR during READ OP",UVM_MEDIUM)
        else 
            data_rd = arr[pkt.PADDR];
            if (data_rd == pkt.PRDATA)
              `uvm_info(get_type_name(),$sformatf("DATA MATCHED: addr:%0d rdata:%0d",pkt.PADDR,pkt.PRDATA),UVM_MEDIUM)
              else
                `uvm_info(get_type_name(),$sformatf("TEST FAILED: addr:%0d rdata:%0d data_rd_arr:%0d",pkt.PADDR,pkt.PRDATA,data_rd),UVM_MEDIUM)
                $display("-----------------------------------------------------------------");
            
  endfunction
endclass
