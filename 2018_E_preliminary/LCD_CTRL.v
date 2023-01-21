module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input cmd_valid;
input [3:0] cmd;
input [7:0]      IROM_Q;
output reg       IROM_rd;
output reg [5:0] IROM_A;

output reg       IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output reg busy;
output reg done;

reg [7:0] data[63:0];
reg [5:0] position ;

reg [7:0]tmp1,tmp2,tmp3,tmp4; 
reg [9:0]avg;
reg [7:0]max,min;
reg [7:0]c_tmp1,c_tmp2;

always @(*)begin
   tmp1 = data[position-9];
   tmp2 = data[position-8];
   tmp3 = data[position-1];
   tmp4 = data[position  ];
   avg = (tmp1 + tmp2 + tmp3 +tmp4)>> 2 ;

   if( (tmp1 < tmp2) ^ (cmd == 5) )
      c_tmp1 = tmp1;
   else 
      c_tmp1 = tmp2; 
   
   if( (tmp3 < tmp4) ^ (cmd == 5) )
      c_tmp2 = tmp3;
   else 
      c_tmp2 = tmp4; 


   if(c_tmp1 < c_tmp2) begin 
      min = c_tmp1;
      max = c_tmp2;
   end
   else begin
      max = c_tmp1;
      min = c_tmp2;
   end
end


always@(posedge clk) begin
    if(reset) begin
       IROM_rd <= 1;
       IROM_A <= 0;
       IRAM_valid <= 0;
       IRAM_D <= 0;
       IRAM_A <= 0;
       busy <= 1;    // set 0 to get next instruction
       done <=0;     // set 1 to check out
       position <= {3'b100,3'b100};  // {Y,X}
    end
    else if(IROM_rd == 1) begin
         data[IROM_A] <= IROM_Q;
         IROM_A <= IROM_A + 1;
         if(IROM_A == 63)begin
            IROM_rd <= 0;          // end 
            busy <= 0;
         end
    end
    else begin
         case (cmd)
              4'd0:begin
                   if(busy == 0)begin
                     busy <= 1 ; 
                     IRAM_valid <= 1;
                     IRAM_A <=  0;
                     IRAM_D <= data[0]; 
                   end
                   else begin
                   IRAM_A <=  IRAM_A+1;
                   IRAM_D <= data[ IRAM_A + 1]; 
                   if(IRAM_A == 63) begin
                      busy <= 0;
                      IRAM_valid <= 0;
                      done<= 1;     //end write
                      end
                   end
                  end
             4'd1:begin     // shift up
                  if(position[5:3] > 1)   // Y-1
                     position[5:3] <= position[5:3] - 1;
                  end
             4'd2:begin     //shuft down
                  if(position[5:3] < 7)   // Y+1
                     position[5:3] <= position[5:3] + 1;
                  end
             4'd3:begin     //shift left
                  if(position[2:0] > 1)   // X-1
                     position[2:0] <=  position[2:0] - 1;
                  end
             4'd4:begin     // shift right
                  if( position[2:0] < 7)   // X+1
                      position[2:0] <=  position[2:0] + 1;
                  end 
             4'd5:begin     // max
                  data[position-9] <= max;
                  data[position-8] <= max;
                  data[position-1] <= max;
                  data[position  ] <= max;
                  end
             4'd6:begin     //min
                  data[position-9] <= min;
                  data[position-8] <= min;
                  data[position-1] <= min;
                  data[position  ] <= min;
                 end 
            4'd7:begin     //average
                  data[position-9] <= avg;
                  data[position-8] <= avg;
                  data[position-1] <= avg;
                  data[position  ] <= avg;
                 end
            4'd8:begin     //counterclockwise rotate
                 data[position-9] <= tmp2;
                 data[position-8] <= tmp4;
                 data[position-1] <= tmp1;
                 data[position  ] <= tmp3;
                 end  
            4'd9:begin     //clockwise rotate
                 data[position-9] <= tmp3;
                 data[position-8] <= tmp1;
                 data[position-1] <= tmp4;
                 data[position  ] <= tmp2;
                 end    
           4'd10:begin     //mirror x
                 data[position-9] <= tmp3;
                 data[position-8] <= tmp4;
                 data[position-1] <= tmp1;
                 data[position  ] <= tmp2;
                 end 
           4'd11:begin     //mirror y
                 data[position-9] <= tmp2;
                 data[position-8] <= tmp1;
                 data[position-1] <= tmp4;
                 data[position  ] <= tmp3;
                 end                    
          endcase
      end  // end else 
    end // end always
endmodule

//compile  time : 30  area : 62873.393053