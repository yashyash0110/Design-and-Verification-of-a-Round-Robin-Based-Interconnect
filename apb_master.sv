module apb_master(ctl_fsm,PCLK,PRESET,PADDR,PWDATA,PWRITE,PSEL,PENABLE,PRDATA,PREADY,PSLVERR);
  input logic ctl_fsm;
  output logic PCLK,PRESET,PWRITE,PSEL,PENABLE;
  output logic [32:0] PADDR,PWDATA;
  input logic [32:0] PRDATA;
  input logic PREADY,PSLVERR;
  
  typedef enum logic [1:0] {IDLE,SETUP,ACCESS,ERROR} apb_state;
  
  apb_state current_state,next_state;
  
  //FSM: Sequential State Update
  always_ff@(posedge PCLK or negedge PRESET)
    begin
      if(!PRESET) begin
        current_state <= IDLE;
        next_state <= current_state;
      end
      else
        current_state <= next_state;
    end
  
  //FSM: Next State & Output logic
  always_comb begin
    PSEL=0;
    PENABLE=0;
    PWRITE=0;
    
    case(current_state)
      IDLE:begin
        if(ctl_fsm == 1)
          next_state = SETUP;
      end

      SETUP:
        begin
          PSEL=1;
          PENABLE=0;
          next_state = ACCESS;
        end
      ACCESS:
        begin
          PSEL=1;
          PENABLE=1;
          if(PREADY) //Transaction completes when PREADY=1
            next_state = IDLE;
          if(PSLVERR)
            next_state = ERROR;
        end
      ERROR:
        begin
          PSEL=0;
          PENABLE=0;
          next_state = SETUP; //Retry mechanism
        end
      
    end
  
  //Address and Data generation (Only in setup state)    
  always_ff @(posedge PCLK or posedge PRESET) begin
    if (!PRESET) begin
      PADDR  <= 32'h1000;
      PWDATA <= 32'h0000_0001;
    end 
    else if (current_state == SETUP) begin
      PADDR  <= PADDR + 4; // Increment address
      PWDATA <= PWDATA + 1; // Increment data
      PWRITE <= (PADDR[2] == 1'b0)? 1 : 0; //Alternate Read/Write 
    end
end
endmodule