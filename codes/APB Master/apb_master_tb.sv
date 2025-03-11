module apb_master_tb;
  logic ctl_fsm;
  logic PCLK, PRESET, PWRITE, PSEL, PENABLE;
  logic [31:0] PADDR, PWDATA;
  logic [31:0] PRDATA;
  logic PREADY, PSLVERR;
  
  // Clock generation
  initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK; // 10ns clock period
  end

  // Instantiate APB Master
  apb_master uut (
    .ctl_fsm(ctl_fsm),
    .PCLK(PCLK),
    .PRESET(PRESET),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
  );

  // Test sequence
  initial begin
    // Initialize signals
    PRESET = 0;
    ctl_fsm = 0;
    PREADY = 0;
    PSLVERR = 0;
    PRDATA = 32'hABCD_EF01;
    
    #20 PRESET = 1; // Release reset
    
    // Start transaction
    #10 ctl_fsm = 1;
    #10 ctl_fsm = 0;
    
    // Simulate PREADY high (transaction completes)
    #20 PREADY = 1;
    #10 PREADY = 0;

    // Simulate an error
    #20 PSLVERR = 1;
    #10 PSLVERR = 0;
    
    #10 ctl_fsm = 1;
    #10 ctl_fsm = 0;

    // Run for a while and finish
    #200 $finish;
  end

  // Monitor signals
  initial begin
    $monitor($time, " PADDR=%h PWDATA=%h PWRITE=%b PSEL=%b PENABLE=%b PREADY=%b PSLVERR=%b", PADDR, PWDATA, PWRITE, PSEL, PENABLE, PREADY, PSLVERR);
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule
