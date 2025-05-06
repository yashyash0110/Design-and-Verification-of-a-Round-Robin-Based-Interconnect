`define DEPTH_ADDR (1<<32)

module apb_slave_interconnect(
  input logic PCLK, PRESET, PWRITE, PSEL, PENABLE,
  input logic [31:0] PADDR, PWDATA,
  output logic [31:0] PRDATA,
  output logic PREADY, PSLVERR,

  // FIFO Interface
  output logic push_in,
  output logic [31:0] push_wdata_in,  
  output logic [31:0] push_addr_in,   
  output logic fifo_write,            
  input logic fifo_data_in_ack,       
  input logic full_o,

  // Arbiter Interface
  input logic arb_rdata_ack,
  input logic [31:0] arb_rdata 
);
  // PRDATA comes from arbiter
  assign PRDATA = arb_rdata;

  // APB state machine
  typedef enum logic [1:0] {IDLE, SETUP, ACCESS, ACK} apb_state;

  apb_state current_state, next_state;

  // Latched values for write data and address
  logic [31:0] latched_wdata, latched_addr;

  // FSM: Sequential State Update
  always_ff @(posedge PCLK or negedge PRESET) begin
    if (!PRESET) 
      current_state <= IDLE;
    else 
      current_state <= next_state;
  end

  // FSM: Next State Logic
  always_comb begin
    // Default values to avoid latches
    PREADY        = 0;
    PSLVERR       = 0;
    fifo_write    = 0;
    push_in       = 0;
    push_wdata_in = 32'b0;
    push_addr_in  = 32'b0;
    next_state    = current_state; // Default state remains unchanged

    case (current_state)
      IDLE: begin
        if (PSEL)
          next_state = SETUP;
      end

      SETUP: begin
        if (PSEL) begin
          if (PADDR > `DEPTH_ADDR - 1) begin
            PSLVERR   = 1;  
            next_state = IDLE;
          end else begin
            next_state = ACCESS;
          end
        end
      end

      ACCESS: begin
        if (PENABLE) begin
          if (PWRITE) begin // WRITE Operation
            if (!full_o) begin
              fifo_write    = 1;
              push_in       = 1;
              push_wdata_in = latched_wdata;
              push_addr_in  = latched_addr;
              next_state    = ACK;
            end
          end else begin // READ Operation
            push_addr_in = latched_addr;
            next_state   = ACK;
          end
        end
      end

      ACK: begin // Waiting for FIFO and Arbiter Acknowledgments
        if (fifo_data_in_ack || arb_rdata_ack) begin
          PREADY = 1;
          next_state = IDLE;
        end
      end
    endcase
  end

  // Capture address and write data in the SETUP state
  always_ff @(posedge PCLK or negedge PRESET) begin
    if (!PRESET) begin
      latched_wdata <= 32'b0;
      latched_addr  <= 32'b0;
    end else if (current_state == SETUP && PADDR <= `DEPTH_ADDR - 1) begin
      latched_wdata <= PWDATA;
      latched_addr  <= PADDR;
    end
  end

endmodule
