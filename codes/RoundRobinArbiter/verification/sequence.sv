//Sequences Class
class random extends uvm_sequence#(packet);
  `uvm_object_utils(random)
  
  packet pkt;
  
  function new(input string name = "random");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(5)
      begin
        pkt = packet::type_id::create("pkt");
        start_item(pkt);
        pkt.randomize();
        finish_item(pkt);
        
      end
  endtask
  
endclass
