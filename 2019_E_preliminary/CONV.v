`timescale 1ns/10ps
module  CONV(clk,		reset,	busy,	ready,	 iaddr,	idata,	cwr, caddr_wr, cdata_wr, crd, caddr_rd ,cdata_rd ,csel);
input		clk;
input		reset;
output  reg	busy;	
input		ready;	
          
output  reg [11:0] iaddr;
input  signed [19:0] idata;  //signed

output  reg             cwr;
output  reg [11:0] caddr_wr;
output  reg [19:0] cdata_wr; //signed

output  reg 	        crd;
output  reg [11:0] caddr_rd;
input	    [19:0] cdata_rd; //signed

output  reg [2:0]      csel;

parameter k0 = 20'h0A89E,
          k1 = 20'h01004,
          k2 = 20'hFA6D7,
          k3 = 20'h092D5,
          k4 = 20'hF8F71,
          k5 = 20'hFC834,
          k6 = 20'h06D43,
          k7 = 20'hF6E54,
          k8 = 20'hFAC19,
          bias = 20'h01310;

reg signed[19:0] temp ;
reg signed[39:0]sum;
wire signed[39:0]mul ;
assign mul = temp * idata;

reg [4:0] state;

reg [5:0]x,y;
wire [11:0] position ;
assign position = {y,x};

/* 
  order 
  0 | 3 | 6
  1 | 4 | 7
  2 | 5 | 8
*/

always@(posedge clk)begin
     if(reset)begin
          x <= 0;
          y <= 0;
          sum <= 0;
          state <= 0;
        
          busy <= 0;
          iaddr <= 0;

          cwr <= 0;
          caddr_wr <= 0;
          cdata_wr <= 0;
          
          crd <= 0;
          csel <= 0;
     end
     else begin
          case(state)
               0:begin
                    busy <= 1;
                 end
               1:begin
	               sum[35:16] <= bias;	
                    iaddr <= position - 65;
                    temp <= k0;
                 end
               2:begin
                    iaddr <= iaddr + 64;
                    temp <= k1;
                    if(x != 0 && y != 0)
                         sum <= sum + mul ;
                 end
               3:begin
                    iaddr <= iaddr + 64;
                    temp <= k2;

                    if(x != 0 )
                         sum <= sum + mul ;
                 end  
               4:begin
                    iaddr <= iaddr -127;
                    temp <= k3;

                    if(x != 0 && y != 63)
                         sum <= sum + mul;
                 end 
               5:begin
                    iaddr <= iaddr + 64;
                    temp  <= k4;

                    if(y != 0 )
                         sum <= sum + mul;
                 end 
               6:begin
                    iaddr <= iaddr + 64;
                    temp <=  k5;

                    sum <= sum + mul;
                 end   
               7:begin
                    iaddr <= iaddr -127;
                    temp <=  k6;
                    
                    if(y != 63 )
                         sum <= sum + mul;
                 end   
               8:begin
                    iaddr <= iaddr + 64;
                    temp <= k7;

                    if(x != 63 && y != 0 )
                         sum <= sum + mul;
                 end   
               9:begin
                    iaddr <= iaddr + 64;
                    temp <= k8;

                    if(x != 63 )
                         sum <= sum + mul;
                 end     
               10:begin
                    if(x != 63 && y != 63 )
                         sum <= sum + mul;
                 end   
              11:begin   // Write level 0
                    cwr <= 1;
                    caddr_wr <= position;
                    csel <= 1;
                    
                    cdata_wr <= 0;
                    if( sum >= 0)begin
                         if(sum[15] == 1) //rounding 
                              cdata_wr <= sum[35:16] +1;
                         else
                              cdata_wr <= sum[35:16] ;
                    end                           
                    end 
             12:begin
                    cwr <= 0;
                    sum <= 0;

                    x <= x+1;
                    if(x==63)
                         y <= y+1;
                    end  
             13 : begin
                    csel <= 1;
                    crd <= 1;
                    caddr_rd <= position;
                    end
            14 : begin
                    caddr_rd <= caddr_rd + 64;
                    cdata_wr <= cdata_rd;
                    end
            15 : begin
                    caddr_rd <= caddr_rd - 63;
                    if(cdata_rd > cdata_wr)
                         cdata_wr <= cdata_rd;
                    end
           16 : begin
                    caddr_rd <= caddr_rd + 64;
                    if(cdata_rd > cdata_wr)
                         cdata_wr <= cdata_rd;
                    end
            17 : begin
                    crd <= 0;
                    if(cdata_rd > cdata_wr)
                         cdata_wr <= cdata_rd;
                    end   
            18 : begin // write level 1
                    csel <= 3;
                    cwr <= 1;
                    caddr_wr <= { y[5:1], x[5:1]};
                  end
            19: begin                             
                    cwr <= 0;
                    x <= x + 2;
                    if(x == 62)begin
                         if(y == 62)
                              busy <= 0;
                         else     
                              y <= y + 2;
                    end
                end
     endcase

          state <= state + 1 ; 
          case(state)
               12 : if(position != 4095) state <= 1; 
               19 : state <= 13;    
	     endcase
          end     
     end
endmodule

// cycle time : 80   area : 21950.776962

