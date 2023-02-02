module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;            // graph info
input   [3:0]   cmd;               // command mode
input           cmd_valid;         
output reg [7:0]   dataout;  
output reg         output_valid;
output reg         busy;

reg [7:0] data [107:0]; // save image
reg [6:0] index;
reg [3:0] command;  // save cmd

reg [1:0] state,next_state;
parameter Idle    = 2'd0,
          Process = 2'd1,
          Output  = 2'd2,
          Read    = 2'd3;

reg Mode ;
parameter Zoom_fit = 1'd0,
          Zoom_in  = 1'd1;

reg [1:0] Rotate;
parameter Left    = 2'd0,
          Origin  = 2'd1,
          Right   = 2'd2;

reg [3:0] L,W;

reg [6:0]position;

always@(*)begin
   if(Mode == Zoom_fit)begin
      case(Rotate)
            Origin :  position = 13 + index[3:2]*24 + index[1:0]* 3;
            Left   :  position = 22 - index[3:2]* 3 + index[1:0]*24;
            Right  :  position = 85 + index[3:2]* 3 - index[1:0]*24;         
      endcase
   end
   else begin  // Zoom_in
      case(Rotate)
            Origin :  position = W * 12 + L + index[3:2]* 12 + index[1:0]    - 26;
            Left   :  position = W * 12 + L - index[3:2]     + index[1:0]*12 - 23;
            Right  :  position = W * 12 + L + index[3:2]     - index[1:0]*12 + 10;
      endcase
   end
   dataout = data[position];
   output_valid = (state == 2 )& ( next_state == 2);
end

always@(posedge clk ) begin  // fsm
   if(reset)
      state <= Idle;
   else
      state <= next_state;
end

always@(*)begin  // next state logic
   next_state = state ;
    case(state)
        Idle    : next_state = Process;
        Process : if(index == 107 || command != 0) next_state = Output ;
        Output  : if(index == 16 ) next_state = Read ;
        Read    : next_state = Process;
    endcase
end


always@(posedge clk)begin
   case(state)
       Idle :begin
               index <= 0;
               Rotate <= Origin;
               busy <= 0;              
               command <= cmd;
             end
    Process :begin
               case(command)
                  0: begin  // load
                        busy <= 1;
                        Mode <= Zoom_fit;
                        Rotate <= Origin;
                        
                        data[index] <= datain;  
                        index <= index + 1;                
                        if(index == 107)
                           index <= 0;       
                     end
                  1: begin  // Rotate Left
                        if( Mode == Zoom_fit && Rotate > 0)
                           Rotate <= Rotate - 1;           
                     end
                  2: begin  // Rotate Right
                        if( Mode == Zoom_fit && Rotate < 2)
                           Rotate <= Rotate + 1;           
                     end
                  3: begin  // Zoom in
                        Mode <= Zoom_in;
                        L <= 6;
                        W <= 5;           
                     end
                  4: begin  // Zoom fit
                        Mode <= Zoom_fit;
                     end
                  5: begin  // Shift Right
                        case(Rotate)
                           Origin: if(L < 10) L <= L + 1;
                           Left  : if(W < 7 ) W <= W + 1; 
                           Right : if(W > 2 ) W <= W - 1; 
                        endcase
                        end           
                     end
                  6: begin  // Shift Left
                        case(Rotate)
                           Origin: if(L > 2)  L <= L - 1;
                           Left  : if(W > 2 ) W <= W - 1; 
                           Right : if(W < 7 ) W <= W + 1; 
                        endcase        
                     end
                  7: begin  // Shift Up
                        case(Rotate)
                              Origin: if(W > 2)  W <= W - 1;
                              Left  : if(L < 10) L <= L + 1; 
                              Right : if(L > 2 ) L <= L - 1; 
                        endcase           
                     end
                  8: begin  // Shift Down
                        case(Rotate)
                           Origin: if(W < 7 ) W <= W + 1; 
                           Left  : if(L > 2 ) L <= L - 1; 
                           Right : if(L < 10) L <= L + 1; 
                        endcase           
                     end
               endcase   
            end
     Output :begin
             if(index == 16)begin 
                  index <= 0; 
                  busy <= 0;
             end
             else begin
                  index <= index + 1;
             end
             end
      Read: begin
                  command <= cmd ;
                  busy <= 1;
             end
   endcase
end

endmodule //  44207.086447
 