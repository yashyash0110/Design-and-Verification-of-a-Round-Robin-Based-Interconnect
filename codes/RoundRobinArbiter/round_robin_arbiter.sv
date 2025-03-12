module round_robin_arbiter(clk,reset,REQ,GNT);//Fixed time slices
  input logic clk;
  input logic reset;
  input logic [3:0] REQ;
  output logic [3:0] GNT;

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
  
  always_comb 
    begin
      case(current_state)
        IDEAL:
          begin
            if(REQ[0])
              next_state=STATE0;
            else if(REQ[1])
              next_state=STATE1;
            else if(REQ[2])
              next_state=STATE2;
            else if(REQ[3])
              next_state=STATE3;
            else
              next_state=IDEAL;
          end
        
        STATE0:
          begin
            if(REQ[1])
             next_state=STATE1;
           else if(REQ[2])
             next_state=STATE2;
           else if(REQ[3])
             next_state=STATE3;
           else if(REQ[0])
             next_state=STATE0;
           else
             next_state=IDEAL;
          end
        STATE1:
          begin
            if(REQ[2])
             next_state=STATE2;
            else if(REQ[3])
             next_state=STATE3;
            else if(REQ[0])
             next_state=STATE0;
            else if(REQ[1])
             next_state=STATE1;
           	else
             next_state=IDEAL;
          end
        STATE2:
          begin
            if(REQ[3])
             next_state=STATE3;
            else if(REQ[0])
             next_state=STATE0;
            else if(REQ[1])
             next_state=STATE1;
            else if(REQ[2])
             next_state=STATE2;
           	else
             next_state=IDEAL;
          end
        STATE3:
          begin
            if(REQ[0])
             next_state=STATE0;
            else if(REQ[1])
             next_state=STATE1;
            else if(REQ[2])
             next_state=STATE2;
            else if(REQ[3])
             next_state=STATE3;
           	else
             next_state=IDEAL;
          end
      endcase
  end
  
  always_comb
    begin
      case(current_state)
        STATE0: GNT=4'b0001;
        STATE1: GNT=4'b0010;
        STATE2: GNT=4'b0100;
        STATE3: GNT=4'b1000;
        default: GNT=4'b0000;
      endcase
    end
  
endmodule
