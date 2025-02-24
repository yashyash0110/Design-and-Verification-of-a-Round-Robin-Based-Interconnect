`define DEPTH_ADDR (1<<32)
module apb_slave_interconnect(PCLK,PRESET,PADDR,PWDATA,PWRITE,PSEL,PENABLE,PRDATA,PREADY,PSLVERR,
fifo_clk,fifo_reset,push_in,push_data_in,full_o,empty_o,arb_rdata_ack);

  input logic PCLK,PRESET,PWRITE,PSEL,PENABLE;
  input logic [31:0] PADDR,PWDATA;
  output logic [31:0] PRDATA;
  output logic PREADY,PSLVERR;

  /*PRDATA is given directly by the arbiter after 
  the data is fetch from the memory*/ 
  
  //Interaction with FIFO
  output logic fifo_clk;
  output logic fifo_reset;
  output logic push_in;
  output logic [31:0] push_wdata_in;
  output logic [31:0] push_addr_in;
  output logic fifo_write;
  /*pop_o,pop_data_o
  These should be taken care
  */
  input logic fifo_data_in_ack;
  input logic full_o;
  input logic empty_o;  

  //Interaction with arbiter
  input logic arb_rdata_ack;
  input logic [31:0] arb_rdata;

  assign PRDATA = arb_rdata;
  
  typedef enum logic [1:0] {IDLE,SETUP,ACCESS,ACK} apb_state;
  
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
  
  always_comb
    begin
      case(current_state)
        IDLE: begin
          next_state = SETUP;
        end
        
        SETUP: begin
            if(PSEL)
                next_state = ACCESS; 
        end

        ACCESS:
            begin
              if(PADDR>`DEPTH_ADDR-1)
                PSLVERR=1;  
              else 
                begin
                    if(PENABLE & PWRITE) //WRITE
                        begin
                          fifo_write=1;
                          if(!full_o) begin
                            push_in=1;
                            push_wdata_in = PWDATA;
                          end
                        end
                    else if(!(PENABLE & PWRITE)) //READ
                        begin
                            fifo_write=0;
                        end
                end
                push_addr_in = PADDR;
                PSLVERR=0;
                next_state = ACK;
            end
        ACK: //Waiting for the acknowledgements from the FIFO and ARBITER
            begin
                //WRITE 
                if(fifo_data_in_ack)
                    PREADY=1;
                //READ
                if(arb_rdata_ack)
                    PREADY=1;
                next_state = IDLE;
            end
        
endmodule
