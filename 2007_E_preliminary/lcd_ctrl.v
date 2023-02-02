module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;         
input   [2:0]   cmd;               
input           cmd_valid;         
output reg [7:0]   dataout;  
output reg         output_valid;
output reg         busy;


reg [2:0] command;  // save cmd
reg [2:0] X,Y;    // origin
reg magnification;

reg [7:0] data [63:0];
reg [5:0] index; // input output index
reg [5:0] position; 

always@(*)begin
   if( magnification )begin  // Zoom  in      
      position[2:0] = X + index[1:0]  ; 
      position[5:3] = Y + index[3:2]  ;  
   end
   else begin                 // Zoom  out
      position[2:0]  =  index[1:0] << 1  ;
      position[5:3]  =  index[3:2] << 1  ;     
   end
   dataout = data[position];   
end

reg [1:0] state , next_state; 

parameter Idle    = 3'd0,
          Process = 3'd1,
          Read    = 3'd2;
   
always@(posedge clk)begin  // fsm
   if(reset)
      state <= Idle;
   else
      state <= next_state;
end

always@(*)begin // next state logic
   next_state <= state;
   case( state )
      Idle : next_state <= Process; 
      Process : if(index == 15 && command == 0) next_state <= Read;   
      Read :  next_state <= Process;  
   endcase
end

always@(posedge clk)begin
   case(state)
      Idle:begin  // Reset
            output_valid <= 0;
            busy <= 0;
                        
            index <= 0;
            command <= cmd;
            end
      Process:begin            // image process
                  case(command)
                     0: begin // Reflash
                           if( output_valid == 0)begin // start
                           	busy <= 1;
                        	output_valid <= 1;
                           end
                           else if(index == 15)begin  // end
                              busy <= 0;
                              output_valid <= 0;
                              index <= 0;
                           end
                           else begin                               
                              index <= index + 1;      
                           end                               
                        end 
                     1: begin // load data
                           data[index] <= datain;
                           index <= index + 1;
                           
                           X <= 0;
                           Y <= 0;
                           magnification <= 0;
                           busy <= 1;
                           if(index == 63)
                                command <= 0;                          
                        end
                     2: begin // Zoom in
                           X <= 2;
                           Y <= 2;
                           magnification <= 1;
                        end
                     3: begin // Zoom out  
                           X <= 0;
                           Y <= 0;
                           magnification <= 0;
                        end   
                     4: begin // Shift Right
                           if( X < 4 )
                              X <= X + 1;
                        end  
                     5: begin // Shift Left
                           if(  X > 0)
                              X <= X - 1; 
                        end  
                     6: begin // Shift Up
                           if( Y > 0)
                              Y <= Y - 1;
                        end  
                     7: begin // Shift Down
                            if( Y < 4)
                              Y <= Y + 1; 
                        end       
                  endcase

                  if(command > 1)
                      command <= 0;   
               end
        Read : begin         // read cmd
                  command <= cmd;      
                  busy <= 1;                    
               end
   endcase
end
endmodule  // area : 26187.487509