module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input cmd_valid;
input [3:0] cmd;
input [7:0]      IROM_Q;
output           IROM_rd;
output     [5:0] IROM_A;
output           IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output busy;
output done;

reg [7:0]data[63:0];
reg [5:0]position;

reg [2:0]state , next_state;

parameter   Idle    = 3'd0,
            Read    = 3'd1,
            Process = 3'd2,
            Write   = 3'd3,
            Finish  = 3'd4;

assign IROM_A = IRAM_A;    // save IROM_A reg 
assign IRAM_valid = (state == Write )? 1 : 0;
assign IROM_rd = (state == Idle || state == Read )? 1 : 0;
assign done    = (state == Finish)? 1 : 0 ;
assign busy    = (state == Process || state == Finish)? 0 : 1;

reg[7:0] tmp1 , tmp2 , tmp3 , tmp4 ;
reg[7:0] min ,max;
reg[9:0] avg;
reg[7:0] c_tmp1 , c_tmp2;

//  tmp1 || tmp2
//  tmp3 || tmp4

always@(*)begin
    tmp1 = data[position - 9];
    tmp2 = data[position - 8];
    tmp3 = data[position - 1];
    tmp4 = data[position    ];
    avg = ( tmp1 + tmp2 + tmp3 + tmp4 ) >> 2 ;

    if((tmp1 < tmp2) ^ (cmd == 5))
        c_tmp1 = tmp1;
    else
        c_tmp1 = tmp2;    

    if((tmp3 < tmp4) ^ (cmd == 5))
        c_tmp2 = tmp3;
    else
        c_tmp2 = tmp4;  

    if(c_tmp1 < c_tmp2)begin
        max = c_tmp2;
        min = c_tmp1;
    end
    else begin
        max = c_tmp1;
        min = c_tmp2;    
    end
end

always@(posedge clk)begin // FSM
    if(reset)
        state <= Idle;
    else
        state <= next_state;
end


always@(*)begin // next state logic
    next_state = state ;
    case(state)
        Idle :next_state = Read;
        Read : if(IROM_A == 63) next_state = Process;  
        Process : if(cmd == 0) next_state = Write;
        Write : if(IRAM_A == 63)  next_state = Finish;           
    endcase
end

always@(posedge clk)begin
    case(state)
        Idle :begin  // Reset
              IRAM_A <= 0;
              position <= {3'd4,3'd4};  //  Y , X
              end
        Read :begin       
              data[IRAM_A] <= IROM_Q;
              IRAM_A <= IRAM_A + 1 ;  // use IRAM_A to change IROM_A 
              end
     Process :begin
              case(cmd)
                    0:begin                        
                        IRAM_A <= 0
                        IRAM_D <= data[0];
                      end
                    1:begin // shift up 
                        if(position[5:3] > 1)  // Y - 1
                            position[5:3] <= position[5:3] - 1;
                      end
                    2:begin // shift down 
                        if(position[5:3] < 7)  // Y + 1
                            position[5:3] <= position[5:3] + 1;
                      end
                    3:begin // shift left 
                        if(position[2:0] > 1)  // X - 1
                            position[2:0] <= position[2:0] - 1;                       
                      end 
                    4:begin // shift right 
                        if(position[2:0] < 7)  // X + 1
                            position[2:0] <= position[2:0] + 1;                       
                      end
                    5:begin // max
                        data[position - 9] <= max ;
                        data[position - 8] <= max ;
                        data[position - 1] <= max ;
                        data[position    ] <= max ;
                      end
                    6:begin // min 
                        data[position - 9] <= min ;
                        data[position - 8] <= min ;
                        data[position - 1] <= min ;
                        data[position    ] <= min ;
                      end 
                    7:begin // average
                        data[position - 9] <= avg ;
                        data[position - 8] <= avg ;
                        data[position - 1] <= avg ;
                        data[position    ] <= avg ;
                      end
                    8:begin // Counterclockwise Rotation
                        data[position - 9] <= tmp2 ;
                        data[position - 8] <= tmp4 ;
                        data[position - 1] <= tmp1 ;
                        data[position    ] <= tmp3 ;
                      end
                    9:begin // Clockwise Rotation
                        data[position - 9] <= tmp3 ;
                        data[position - 8] <= tmp1 ;
                        data[position - 1] <= tmp4 ;
                        data[position    ] <= tmp2 ;
                      end 
                   10:begin // Mirror X
                        data[position - 9] <= tmp3 ;
                        data[position - 8] <= tmp4 ;
                        data[position - 1] <= tmp1 ;
                        data[position    ] <= tmp2 ;
                      end
                   11:begin // Mirror Y
                        data[position - 9] <= tmp2 ;
                        data[position - 8] <= tmp1 ;
                        data[position - 1] <= tmp4 ;
                        data[position    ] <= tmp3 ;
                      end 
              endcase
              end
       Write :begin
                 IRAM_D <= data[IRAM_A + 1];
            	 IRAM_A <= IRAM_A + 1;
              end
    endcase
end



endmodule

//compile  time : 30  area : 62513.544215