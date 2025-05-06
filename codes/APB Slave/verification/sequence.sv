//Sequences Class
class write_data extends uvm_sequence#(packet);
  `uvm_object_utils(write_data)
  
  packet pkt;
  
  function new(input string name = "write_data");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        pkt = packet::type_id::create("pkt");
        pkt.addr_c.constraint_mode(1);
        pkt.addr_c_err.constraint_mode(0);

        start_item(pkt);
        pkt.randomize();
        pkt.op = WRITE;
        finish_item(pkt);
      end
  endtask
  
endclass

///////////////////////////////////////////////////////////

class read_data extends uvm_sequence#(packet);
  `uvm_object_utils(read_data)
  
  packet pkt;
  
  function new(input string name = "read_data");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        pkt = packet::type_id::create("pkt");
        pkt.addr_c.constraint_mode(1);
        pkt.addr_c_err.constraint_mode(0);
        
        start_item(pkt);
        pkt.randomize();
        pkt.op = READ;
        finish_item(pkt);
      end
  endtask
  
endclass

///////////////////////////////////////////////////////////

class write_read extends uvm_sequence#(packet);
  `uvm_object_utils(write_read)
  
  packet pkt;
  
  function new(input string name = "write_read");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        pkt = packet::type_id::create("pkt");
        pkt.addr_c.constraint_mode(1);
        pkt.addr_c_err.constraint_mode(0);
        
        start_item(pkt);
        pkt.randomize();
        pkt.op = WRITE;
        finish_item(pkt);
        
        start_item(pkt);
        pkt.randomize();
        pkt.op = READ;
        finish_item(pkt);
      end
  endtask
  
endclass

///////////////////////////////////////////////////////////

class writeb_readdb extends uvm_sequence#(packet);
  `uvm_object_utils(writeb_readdb)
  
  packet pkt;
  
  function new(input string name = "writeb_readdb");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        pkt = packet::type_id::create("pkt");
        pkt.addr_c.constraint_mode(1);
        pkt.addr_c_err.constraint_mode(0);
        
        start_item(pkt);
        pkt.randomize();
        pkt.op = WRITE;
        finish_item(pkt);
      end
    repeat(15)
      begin
        pkt = packet::type_id::create("pkt");
        pkt.addr_c.constraint_mode(1);
        pkt.addr_c_err.constraint_mode(0);
        
        start_item(pkt);
        pkt.randomize();
        pkt.op = READ;
        finish_item(pkt);
      end
  endtask
endclass

///////////////////////////////////////////////////////////

class write_err extends uvm_sequence#(packet);
  `uvm_object_utils(write_err)
  
  packet pkt;
  
  function new(input string name = "write_err");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        pkt = packet::type_id::create("pkt");
        pkt.addr_c.constraint_mode(1);
        pkt.addr_c_err.constraint_mode(0);
        
        start_item(pkt);
        pkt.randomize();
        pkt.op = WRITE;
        finish_item(pkt);
      end
  endtask
endclass

///////////////////////////////////////////////////////////

class read_err extends uvm_sequence#(packet);
  `uvm_object_utils(read_err)
  
  packet pkt;
  
  function new(input string name = "read_err");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        pkt = packet::type_id::create("pkt");
        pkt.addr_c.constraint_mode(1);
        pkt.addr_c_err.constraint_mode(0);
        
        start_item(pkt);
        pkt.randomize();
        pkt.op = READ;
        finish_item(pkt);
      end
  endtask
endclass

///////////////////////////////////////////////////////////

class reset_dut extends uvm_sequence#(packet);
  `uvm_object_utils(reset_dut)
  
  packet pkt;
  
  function new(input string name = "reset_dut");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        pkt = packet::type_id::create("pkt");
        pkt.addr_c.constraint_mode(1);
        pkt.addr_c_err.constraint_mode(0);
        
        start_item(pkt);
        pkt.randomize();
        pkt.op = RESET;
        finish_item(pkt);
      end
  endtask
endclass
