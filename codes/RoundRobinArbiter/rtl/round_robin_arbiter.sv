typedef struct packed{
  logic [31:0] wdata;
  logic [31:0] addr;
  logic        write;
} Packet;

module round_robin_arbiter(
  input  logic clk,
  input  logic reset,
  input  logic [3:0] REQ,
  output logic [3:0] GNT,

  input  Packet master_in_data [3:0],   // Input from Masters
  output Packet master_out_data,        // Output to Memory

  input  logic [31:0] rdata,            // Read Data from Memory
  input  logic        rdata_ack,        // Acknowledgment from Memory for Read

  output logic [31:0] slave_rdata,      // Read Data to Master
  output logic        slave_rdata_ack   // Ack to Master
);

// Pass through read data and ack from memory
assign slave_rdata     = rdata;
assign slave_rdata_ack = rdata_ack;

// Arbiter states
typedef enum logic [1:0] {
  STATE0 = 2'd0,
  STATE1 = 2'd1,
  STATE2 = 2'd2,
  STATE3 = 2'd3
} arb_state;

arb_state current_state, next_state;

// FSM: State Update
always_ff @(posedge clk or negedge reset) begin
  if (!reset)
    current_state <= STATE0;
  else
    current_state <= next_state;
end

// FSM: Next State Logic
always_comb begin
  next_state = current_state;
  case (current_state)
    STATE0: begin
      if (REQ[0]) begin
        if (!master_in_data[0].write && !rdata_ack)
          next_state = STATE0;  // Stay for read until ack
        else
          next_state = (REQ[1]) ? STATE1 :
                       (REQ[2]) ? STATE2 :
                       (REQ[3]) ? STATE3 :
                                 STATE0;
      end else begin
        next_state = (REQ[1]) ? STATE1 :
                     (REQ[2]) ? STATE2 :
                     (REQ[3]) ? STATE3 :
                               STATE0;
      end
    end

    STATE1: begin
      if (REQ[1]) begin
        if (!master_in_data[1].write && !rdata_ack)
          next_state = STATE1;
        else
          next_state = (REQ[2]) ? STATE2 :
                       (REQ[3]) ? STATE3 :
                       (REQ[0]) ? STATE0 :
                                 STATE1;
      end else begin
        next_state = (REQ[2]) ? STATE2 :
                     (REQ[3]) ? STATE3 :
                     (REQ[0]) ? STATE0 :
                               STATE1;
      end
    end

    STATE2: begin
      if (REQ[2]) begin
        if (!master_in_data[2].write && !rdata_ack)
          next_state = STATE2;
        else
          next_state = (REQ[3]) ? STATE3 :
                       (REQ[0]) ? STATE0 :
                       (REQ[1]) ? STATE1 :
                                 STATE2;
      end else begin
        next_state = (REQ[3]) ? STATE3 :
                     (REQ[0]) ? STATE0 :
                     (REQ[1]) ? STATE1 :
                               STATE2;
      end
    end

    STATE3: begin
      if (REQ[3]) begin
        if (!master_in_data[3].write && !rdata_ack)
          next_state = STATE3;
        else
          next_state = (REQ[0]) ? STATE0 :
                       (REQ[1]) ? STATE1 :
                       (REQ[2]) ? STATE2 :
                                 STATE3;
      end else begin
        next_state = (REQ[0]) ? STATE0 :
                     (REQ[1]) ? STATE1 :
                     (REQ[2]) ? STATE2 :
                               STATE3;
      end
    end
  endcase
end

// Grant logic
always_comb begin
  GNT = 4'b0000;
  case (current_state)
    STATE0: if (REQ[0]) GNT = 4'b0001;
    STATE1: if (REQ[1]) GNT = 4'b0010;
    STATE2: if (REQ[2]) GNT = 4'b0100;
    STATE3: if (REQ[3]) GNT = 4'b1000;
  endcase
end

// Output data to memory (only active master's data)
always_comb begin
  master_out_data = '{addr:32'h0, wdata:32'h0, write:1'b0}; // default

  if (GNT[0]) master_out_data = master_in_data[0];
  else if (GNT[1]) master_out_data = master_in_data[1];
  else if (GNT[2]) master_out_data = master_in_data[2];
  else if (GNT[3]) master_out_data = master_in_data[3];
end

endmodule
