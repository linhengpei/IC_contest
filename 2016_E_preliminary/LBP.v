`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
input       	gray_ready;
input [7:0] 	gray_data;
output reg [13:0] gray_addr;
output reg        gray_req;
output reg        lbp_valid;
output reg [13:0] lbp_addr;
output     [7:0]  lbp_data;
output reg        finish;

reg [3:0]counter;
reg [7:0]data [8:0];

assign lbp_data[0] = (data[0] >= data[4])? 1 : 0 ;
assign lbp_data[3] = (data[1] >= data[4])? 1 : 0 ;
assign lbp_data[5] = (data[2] >= data[4])? 1 : 0 ;
assign lbp_data[1] = (data[3] >= data[4])? 1 : 0 ;
assign lbp_data[6] = (data[5] >= data[4])? 1 : 0 ;
assign lbp_data[2] = (data[6] >= data[4])? 1 : 0 ;
assign lbp_data[4] = (data[7] >= data[4])? 1 : 0 ;
assign lbp_data[7] = (data[8] >= data[4])? 1 : 0 ;

reg [1:0] state , next_state;
parameter Idle      = 2'd0,
          Read      = 2'd1,
          Shoft     = 2'd2;

always@(posedge clk )begin  // FSM
     if(reset)
          state <= Idle;
     else
          state <= next_state;
end

always@(*)begin        // next_state logic  
     next_state = state;
     case(state)
          Idle : if(gray_ready) next_state = Read;
          Read : if(counter == 8) next_state = Output;
          Shift : next_state = Read;
     endcase
end 

/*
   0 | 3 | 6
   1 | 4 | 7
   2 | 5 | 8
*/

always@(posedge clk)begin
     case(state) 
          Idle : begin
                    counter <= 0;
                    finish <= 0;
                    gray_req <= 1;
                    gray_addr <= 0;
 
                    lbp_valid <= 0;
                    lbp_addr <= 129; // Firsr position                    
                 end
          Read : begin              
                    case(counter)
                         
                         0 : begin
                                   gray_addr <=  gray_addr + 128; 
                                   data[0] <= gray_data;
                              end
                         1 : begin
                                   gray_addr <=  gray_addr + 128;  
                                   data[1] <= gray_data;
                              end
                         2 : begin
                                   gray_addr <=  gray_addr - 255;  
                                   data[2] <= gray_data;
                              end
                         3 : begin 
                                   gray_addr <=  gray_addr + 128;  
                                   data[3] <= gray_data;
                              end
                         4 : begin
                                   gray_addr <=  gray_addr + 128;  
                                   data[4] <= gray_data;
                              end
                         5 : begin
                                   gray_addr <=  gray_addr - 255;  
                                   data[5] <= gray_data;
                              end
                         6 : begin
                                   gray_addr <=  gray_addr + 128;  
                                   data[6] <= gray_data;
                              end
                         7 : begin
                                   gray_addr <=  gray_addr + 128;  
                                   data[7] <= gray_data;
                              end
                         8 : begin 
                                   data[8] <= gray_data;
                                   lbp_valid <= 1 ;
                              end
                    endcase                               
                    counter <= counter + 1;
                 end
          Shift :   begin
                         lbp_valid <= 0;
                         gray_addr <=  gray_addr - 255;                         
                         if ( lbp_addr[6:0] == 126)begin   
                              if( lbp_addr[13:7] == 126 )begin
                                  finish <= 1;
                              end   
                              else begin                     
 	                          lbp_addr[6:0] <= 1;
                                  lbp_addr[13:7] <= lbp_addr[13:7] + 1 ;
 	                          counter <= 0;
                              end
                         end
                         else begin
                              lbp_addr[6:0] <= lbp_addr[6:0]  + 1;
                              counter <= 6;
                              data[0] <= data[3];
                              data[1] <= data[4];
                              data[2] <= data[5];
                              data[3] <= data[6];
                              data[4] <= data[7];
                              data[5] <= data[8];                            
                         end
                     end
     endcase
end
endmodule // cycle 20ns  time : 1285320  area :  7314.096634


