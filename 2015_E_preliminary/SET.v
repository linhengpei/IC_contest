module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output reg busy;
output reg valid;
output reg [7:0] candidate;


reg [1:0] state , next_state;
parameter Idle      = 2'd0,
          Read      = 2'd1,
          Calculate = 2'd2,
          Output    = 2'd3;

reg [3:0] X,Y;
reg   counter;

always@(posedge clk)begin  // FSM
    if(rst)
        state <= Idle;
    else
        state <= next_state; 
end    

always@(*)begin  // next state logic
    next_state = state; 
    case(state)
           Idle : next_state =   Read;
           Read : next_state = Calculate;
           Calculate : if(X == 8 && Y== 8 && counter == 1) next_state = Output;
           Output : next_state = Idle;
    endcase
end

wire signed [8:0] A;
assign A =  radius[11:8] * radius[11:8] - (X - central[23:20]) * (X - central[23:20]) - (Y - central[19:16]) * (Y - central[19:16]);

wire signed [8:0] B;
assign B =  radius[7:4] * radius[7:4]  - (X - central[15:12]) * (X - central[15:12]) - (Y - central[11: 8]) * (Y - central[11: 8]) ;

/*
wire [3:0]x1,x2,y1,y2,r1,r2;
assign x1 = central[23:20];
assign y1 = central[19:16];
assign x2 = central[15:12];
assign y2 = central[11: 8];
assign r1 = radius[11:8];
assign r2 = radius[7:4];
*/

always@(posedge clk)begin
    case(state)
        Idle : begin
                busy <= 0;
                valid <= 0;
                X <= 1;
                Y <= 1;
                counter <= 0;
                candidate <= 0;
               end
        Read : begin  // read data
                busy <= 1;
               end
        Calculate : begin
                    case (counter)
                        0: counter <= 1;  // use one cycle to wait A and B output correct                           
                        1:begin                          
                            case (mode)
                                0: begin 
                                    if( A >= 0  ) // inside A
                                        candidate <=  candidate + 1; 
                                    end  
                                1: begin 
                                    if( A >= 0 && B >= 0) // inside A and B
                                        candidate <=  candidate + 1;
                                    end 
                                2: begin 
                                    if((A >= 0 && B < 0) || (B >= 0 && A < 0))
                                        candidate <=  candidate + 1;
                                    end 
                            endcase
                                
                            if(X == 8)begin
                                X <= 1;
                                Y <= Y + 1;
                            end
                            else begin
                                X <= X + 1;
                            end

                            counter <= 0;
                        end   
                    endcase                        
                    end
           Output : begin
                    valid <= 1;
                    end
    endcase
end
endmodule  // area : 6394.105893
