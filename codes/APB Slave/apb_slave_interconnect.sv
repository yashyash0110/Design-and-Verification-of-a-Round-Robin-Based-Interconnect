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

  assign fifo_clk = PCLK;
  assign fifo_reset = PRESET;
  assign fifo_write = PWRITE;

  //The APB Master may change PWDATA and PADDR after PENABLE
  logic [31:0] latched_wdata,latched_addr;

  assign PRDATA = arb_rdata;
  
  typedef enum logic [1:0] {IDLE,SETUP,ACCESS,ACK} apb_state;
  
  apb_state current_state,next_state;
  
  //FSM: Sequential State Update
  always_ff@(posedge PCLK or negedge PRESET)
    begin
      if(!PRESET) begin
        current_state <= IDLE;
        next_state <= IDLE;
      end
      else
        current_state <= next_state;
    end
  
  always_comb
    begin
      case(current_state)
        IDLE: begin
          PREADY=0;
          PSLVERR=0;
          fifo_write = 0;
          push_in = 0;
          push_wdata_in = 32'b0;
          push_addr_in = 32'b0;
          if(PSEL)
            next_state = SETUP;
          else
            next_state = IDLE;
        end
        
        SETUP: begin
            PSLVERR=0;
            if(PSEL) begin
                if(PADDR > `DEPTH_ADDR-1)
                    begin
                        PSLVERR=1;  
                        next_state = IDLE;
                    end
                else begin
                    next_state = ACCESS;
                end
            end
        end

        ACCESS:
            begin
                if(PENABLE & PWRITE) //WRITE
                    begin
                        if(!full_o) begin
                        fifo_write=1;
                        push_in =1;
                        push_wdata_in = latched_wdata;
                        push_addr_in = latched_addr;
                        next_state = ACK;
                        end
                        else
                        begin
                            next_state = ACCESS;
                        end
                    end
                else if(!(PENABLE & PWRITE)) //READ
                    begin
                        fifo_write =0;
                        push_addr_in = latched_addr;
                        next_state = ACK;
                    end
                end
        ACK: //Waiting for the acknowledgements from the FIFO and ARBITER
            begin
                PREADY=0;
                //WRITE 
                if(fifo_data_in_ack)
                    PREADY=1;
                //READ
                else if(arb_rdata_ack)
                    PREADY=1;
                next_state = IDLE;
            end

        always_ff@(posedge PCLK or negedge PRESET)
            begin
                if (!PRESET) begin
                    latched_wdata <= 32'b0;
                    latched_addr <= 32'b0;
                end
                else if (current_state == SETUP & PADDR <= DEPTH_ADDR-1) begin
                    latched_wdata <= PWDATA;
                    latched_addr <= PADDR;
                end
            end  
endmodule
