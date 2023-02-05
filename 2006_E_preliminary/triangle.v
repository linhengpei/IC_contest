module triangle (clk, reset, nt, xi, yi, busy, po, xo, yo);
input clk, reset, nt;
input [2:0] xi, yi;
output reg busy;
output reg po;
output reg [2:0] xo, yo;

reg [2:0] x1 ,y1 ,x2 ,y2 ,x3 ,y3;

reg [1:0] state , next_state;
parameter Idle   = 2'd0,
          Read   = 2'd1,
          Output = 2'd2;

reg [2:0] i,j;

wire signed [6:0] line1,line2;
assign line1 = (i-x1)*(y2-y1) - (x2-x1)*(j-y1);
assign line2 = (i-x2)*(y3-y2) - (x3-x2)*(j-y2);

always@(posedge clk)begin  // FSM
    if(reset)
        state <= Idle;
    else
        state <= next_state;
end

always@(*)begin //next_state logic
    next_state = state;
    case(state)
        Idle : next_state = Read;
        Read : if(busy == 1) next_state = Output;
        Output :if(busy == 0) next_state = Idle ;
    endcase
end


always@(posedge clk)begin
    case(state)
        Idle : begin // reset
                   busy <=  0;
                   
                   x1 <= xi;                     
                   y1 <= yi;
                    
                   po <= 0;
                   i <= 0;
                   j <= 0; 
               end
        Read : begin 
                    if(busy == 0)begin
                        busy <= 1;
                        x2 <= xi;
                        y2 <= yi;
                     end
                     else begin
                        x3 <= xi;
                        y3 <= yi;
                     end                          
               end 
        Output : begin
                if( x1 < x2 )begin
                    if( line1 <= 0 && line2 <= 0 && i >= x1)begin
                        xo <= i;
                        yo <= j;  
                        po <= 1;
                    end 
                    else 
                        po <= 0;
                end
                else begin
                    if( line1 >= 0 && line2 >= 0 && i <= x1 )begin
                        xo <= i;cd
                        yo <= j;  
                        po <= 1;
                    end 
                    else 
                        po <= 0;                   
                end
                
                i <= i+1;
                if(i == 7 )
                    j <= j+1;
                            
                if(i == x3 && j == y3)
                    busy <= 0;
                end       
    endcase
end
endmodule // area : 4791.760283 time : 84000ns
