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
           Calculate : if(X == 8 && Y== 8 ) next_state = Output;
           Output : next_state = Idle;
    endcase
end

wire [7:0]r1_2 ,r2_2 ,x1_2 ,x2_2 ,y1_2 ,y2_2 ;
assign r1_2 =  radius[11:8] * radius[11:8];
assign r2_2 =  radius[7 :4] * radius[7 :4];
assign x1_2 =  (X - central[23:20]) * (X - central[23:20]) ; 
assign y1_2 =  (Y - central[19:16]) * (Y - central[19:16]) ; 
assign x2_2 =  (X - central[15:12]) * (X - central[15:12]) ; 
assign y2_2 =  (Y - central[11: 8]) * (Y - central[11: 8]) ;
 
wire inside_A , inside_B;
assign inside_A = ( r1_2 >= x1_2 + y1_2 )? 1 : 0;
assign inside_B = ( r2_2 >= x2_2 + y2_2 )? 1 : 0; 

always@(posedge clk)begin
    case(state)
        Idle : begin
                busy <= 0;
                valid <= 0;
                X <= 1;
                Y <= 1;
                candidate <= 0;
               end
        Read : begin  // read data
                busy <= 1;
               end
        Calculate : begin                             
                        case (mode)
                            0: begin 
                                if( inside_A ) // inside A
                                    candidate <=  candidate + 1; 
                                end  
                            1: begin 
                                if( inside_A && inside_B ) // inside A and B
                                    candidate <=  candidate + 1;
                                end 
                            2: begin 
                               if( inside_A ^ inside_B )
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
                    end
           Output : begin
                    valid <= 1;
                    end
    endcase
end
endmodule  // area : 5609.907068
