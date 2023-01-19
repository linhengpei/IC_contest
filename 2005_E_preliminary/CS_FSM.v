`timescale 1ns/10ps
/*
 * IC Contest Computational System (CS)
*/
module CS(Y, X, reset, clk);
input clk, reset; 
input [7:0] X;
output reg [9:0] Y;


reg [7:0] data [8:0];
reg [11:0] sum ;
reg [7:0] Xavg ;
reg [7:0] Xappr;

reg state , next_state;
parameter    Idle = 1'd0,
          Calculate = 1'd1;
integer i ;

always@(*)begin  // next state logic
   next_state = state ;
   case(state)
         Idle : begin   // Reset
                next_state = Calculate;
                end
   endcase
end

always@(posedge clk)begin   // FSM
   if(reset)
      state <= Idle;
   else
      state <= next_state;
end

always@(posedge clk)begin
   data[0] <= X;  // read data
   case(state)
            Idle : begin  // Reset
                      sum <= X; 
                      for ( i = 1 ; i < 9 ; i = i + 1)
                          data[i] <= 0;
                   end
       Calculate : begin     
                      sum <=  sum - data[8] + X;                
                      for ( i = 0 ; i < 8 ; i = i + 1)// shift
                          data[i+1] <= data [i];                    
                   end                 
   endcase
end

always@(*)begin  // output logic  
  Xavg = sum / 9 ;
  Xappr = 0;
     for ( i = 0 ; i < 9 ; i = i + 1)
        if(  Xappr <= data[i] & data[i] <= Xavg)
               Xappr = data[i];  
end  

always@(negedge clk )begin  // output logic ( hold time  set time)
   Y <= ((Xappr << 3) + Xappr  + sum) >> 3 ;  // Y =  (Xappr * 9 + sum ) / 8 
end

// compile time: 10 area: 14156.316032
  
endmodule
