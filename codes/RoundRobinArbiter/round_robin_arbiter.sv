// Code your design here
typedef struct
{
  logic [31:0] wdata;
  logic [31:0] addr;
  logic write;
} packet_in;


typedef struct
{
  logic [31:0] mem_addr;
  logic [31:0] mem_wdata;
  logic mem_write;

} packet_out;

module round_robin_arbiter(clk,reset,REQ,GNT,master_in_data,master_out_data,rdata,rdata_ack,slave_rdata,slave_rdata_ack);
  input logic clk;
  input logic reset;
  input logic [3:0] REQ;
  output logic [3:0] GNT;

  input packet_in master_in_data [4]; //Data packets from masters
  output packet_out master_out_data;  //Data that is sent to the memory
  
  input logic [31:0] rdata;  // Read data
  input logic rdata_ack;     // Read data acknowledgment
  
  output logic [31:0] slave_rdata; 
  output logic        slave_rdata_ack;
  
  //Output Assignments
  assign slave_rdata       = rdata;
  assign slave_rdata_ack = rdata_ack;


  typedef enum logic [3:0] {
    IDEAL = 4'b0000,
    STATE0 = 4'b0001,
    STATE1 = 4'b0010,
    STATE2 = 4'b0100,
    STATE3 = 4'b1000
  } arb_state;
  
  arb_state current_state,next_state;
  
  always_ff@(posedge clk or negedge reset)
    begin
      if(!reset)
        current_state <= IDEAL;
      else
        current_state <= next_state;
    end
  
  always_comb begin
   case (current_state)
      STATE0:
         if (REQ[1])
            next_state = STATE1;
         else if (REQ[2])
            next_state = STATE2;
         else if (REQ[3])
            next_state = STATE3;
         else if (REQ[0] && master_in_data[0].write)
            next_state = STATE0; // Move on for writes
     else if (REQ[0] && !master_in_data[0].write && rdata_ack)
            next_state = STATE0; // Wait for read ack before moving
         else
            next_state = IDEAL;

      STATE1:
         if (REQ[2])
            next_state = STATE2;
         else if (REQ[3])
            next_state = STATE3;
         else if (REQ[0])
            next_state = STATE0;
         else if (REQ[1] && master_in_data[1].write)
            next_state = STATE1;
         else if (REQ[1] && !master_in_data[1].write && rdata_ack)
            next_state = STATE1;
         else
            next_state = IDEAL;

      STATE2:
         if (REQ[3])
            next_state = STATE3;
         else if (REQ[0])
            next_state = STATE0;
         else if (REQ[1])
            next_state = STATE1;
         else if (REQ[2] && master_in_data[2].write)
            next_state = STATE2;
     else if (REQ[2] && !master_in_data[2].write && rdata_ack)
            next_state = STATE2;
         else
            next_state = IDEAL;

      STATE3:
         if (REQ[0])
            next_state = STATE0;
         else if (REQ[1])
            next_state = STATE1;
         else if (REQ[2])
            next_state = STATE2;
         else if (REQ[3] && master_in_data[3].write)
            next_state = STATE3;
     else if (REQ[3] && !master_in_data[3].write && rdata_ack)
            next_state = STATE3;
         else
            next_state = IDEAL;
   endcase
  end
  
  //Grant Access
  always_comb begin
    case(current_state)
      STATE0: GNT = 4'b0001;
      STATE1: GNT = 4'b0010;
      STATE2: GNT = 4'b0100;
      STATE3: GNT = 4'b1000;
      default: GNT = 4'b0000;
    endcase
  end

  always_comb begin
    master_out_data = '0; // Default assignment

    case(GNT)
      4'b0001: master_out_data = '{mem_addr: master_in_data[0].addr,
                                   mem_wdata: master_in_data[0].wdata,
                                   mem_write: master_in_data[0].write
                                   };

      4'b0010: master_out_data = '{mem_addr: master_in_data[1].addr,
                                   mem_wdata: master_in_data[1].wdata,
                                   mem_write: master_in_data[1].write
                                   };

      4'b0100: master_out_data = '{mem_addr: master_in_data[2].addr,
                                   mem_wdata: master_in_data[2].wdata,
                                   mem_write: master_in_data[2].write
                                  };

      4'b1000: master_out_data = '{mem_addr: master_in_data[3].addr,
                                   mem_wdata: master_in_data[3].wdata,
                                   mem_write: master_in_data[3].write
                                  };
    endcase
  end
  
endmodule
