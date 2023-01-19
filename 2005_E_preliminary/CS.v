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
reg [7:0] Xappr;
integer i ;

always@(posedge clk)begin
   data[0] <= X;  // read data
   if(reset)begin
       sum <= X;
       for ( i = 1 ; i < 9 ; i = i + 1)
              data[i] <= 0;
   end
   else begin 
        sum  <=  sum - data[8] + X;                
        for ( i = 0 ; i < 8 ; i = i + 1)// shift
              data[i+1] <= data [i];                    
    end                  
end

always@(*)begin  // output logic  
   Xappr = 0;
   for ( i = 0 ; i < 9 ; i = i + 1)
      if( Xappr <= data[i] & data[i] <= (sum/9) )
           Xappr = data[i];  
end  

always@(negedge clk )begin  // output logic ( hold time  setup time)
   Y <= ((Xappr << 3) + Xappr  + sum) >> 3 ;  // Y =  (Xappr * 9 + sum ) / 8 
end
  
endmodule

// compile        time: 10   area: 13608.055834
// compile_ultra  time: 10   area: 11005.941606
