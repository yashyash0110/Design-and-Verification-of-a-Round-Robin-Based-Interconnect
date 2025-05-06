module apb_slave_memory_tb;

  // Testbench signals
  logic presetn, pclk, psel, penable, pwrite;
  logic [31:0] paddr, pwdata, prdata;
  logic pready, pslverr;
  
  // DUT instantiation
  apb_slave_memory DUT (
    .presetn(presetn),
    .pclk(pclk),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready),
    .pslverr(pslverr)
  );

  // Clock Generation (10ns period, 100MHz)
  always #5 pclk = ~pclk;

  // APB Write Task
  task apb_write(input [31:0] addr, input [31:0] data);
    begin
      @(posedge pclk);
      psel = 1;
      pwrite = 1;
      paddr = addr;
      pwdata = data;
      penable = 0;
      
      @(posedge pclk);
      penable = 1;
      
      @(posedge pclk);
      if (!pslverr)
        $display("WRITE SUCCESS: Addr = %h, Data = %h", addr, data);
      else
        $display("WRITE ERROR: Addr = %h", addr);
      
      psel = 0;
      penable = 0;
    end
  endtask

  // APB Read Task
  task apb_read(input [31:0] addr);
    begin
      @(posedge pclk);
      psel = 1;
      pwrite = 0;
      paddr = addr;
      penable = 0;

      @(posedge pclk);
      penable = 1;

      @(posedge pclk);
      if (!pslverr)
        $display("READ SUCCESS: Addr = %h, Data = %h", addr, prdata);
      else
        $display("READ ERROR: Addr = %h", addr);
      
      psel = 0;
      penable = 0;
    end
  endtask

  // Test Sequence
  initial begin
    // Initialize Signals
    pclk = 0;
    presetn = 0;
    psel = 0;
    penable = 0;
    pwrite = 0;
    paddr = 0;
    pwdata = 0;

    // Apply Reset
    #20 presetn = 1;
    #10;

    // Perform Write Operations
    apb_write(5, 32'hA5A5A5A5);
    apb_write(10, 32'h12345678);
    apb_write(20, 32'hDEADBEEF);

    // Perform Read Operations
    apb_read(5);
    apb_read(10);
    apb_read(20);

    // Invalid Address Test
    apb_read(40); // Out of bounds

    // Finish Simulation
    #50;
    $finish;
  end

  // Monitor Signals
  initial begin
    $monitor("Time=%0t | paddr=%h | pwdata=%h | prdata=%h | pwrite=%b | psel=%b | penable=%b | pready=%b | pslverr=%b", 
              $time, paddr, pwdata, prdata, pwrite, psel, penable, pready, pslverr);
  end

  // Dump VCD for waveform analysis
  initial begin
    $dumpfile("apb_slave_memory_tb.vcd");
    $dumpvars(0, apb_slave_memory_tb);
  end

endmodule
