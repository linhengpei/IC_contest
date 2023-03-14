module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg  valid;

reg [7:0]Str[33:0];
reg [7:0]pattern[7:0];

reg [5:0]s_len,s_index;
reg [3:0]p_len,p_index;
reg [2:0]state;
reg space_start;  // start with "^"
reg new_string;
parameter space = 7'd 32;

always@(posedge clk)begin
    if(reset)begin
        state <= 0;
        space_start <= 0;  
        new_string <= 0;

        s_len <= 1;
        s_index <= 0;
        
        p_len <= 0;
        p_index <= 0;

        match <= 0;
        valid <= 0;
    end
    else if(isstring)begin
        if(new_string == 1)begin
            valid <= 0;
            s_len <= 2;
            Str[1] <= chardata ;
            new_string <= 0;  
        end
        else begin
            Str[s_len] <= chardata ;
            s_len <= s_len + 1;
        end       
    end 
    else if(ispattern)begin
        valid <= 0;

        if(chardata ==  94 || chardata ==  36 )begin // replace ^ and $ with space
            pattern[p_len] <= space ;
            if(chardata == 94)                   
                space_start <= 1;  
        end    
        else   
            pattern[p_len] <= chardata ;

        p_len <= p_len + 1;
    end 
    else begin
        case(state)
            0:begin
                Str[0]     <= space ;
                Str[s_len] <= space ; // add a space to start and end of string
                state <= state + 1;
              end
            1:begin // compare
                if( (s_index == 0 && space_start == 1 )  || // start with "^"
                    (s_index != 0 && ( pattern[p_index] == Str[s_index] ||  pattern[p_index] == 46 )))begin  //  "."  isn't equal to all alphabet when  s_index == 0 ,
                    p_index <= p_index + 1 ;
                    s_index <= s_index + 1 ;

                    if(p_index == p_len - 1) // correct
                        state <= 2;
		        end
                else begin
                    s_index <= 1 + s_index - p_index;
                    p_index <=  0;

                    if(p_len > s_len - s_index + 2 ) //wrong
                        state <= 3;
                end
              end  
            2:begin // correct
                    if(space_start  ==  1) // start with ^ sign
                        match_index <= s_index - p_index  ;
                    else        
                        match_index <= s_index - p_index - 1;
                    
                    valid <= 1;
                    match <= 1;
                    state <= 0; 
                    space_start <= 0 ; 
                    s_index <= 0;
                    p_len <= 0;
                    p_index <= 0;   
                    new_string <= 1;       
              end
            3:begin // wrong
                    valid <= 1;
                    match <= 0;
                    state <= 0;
                    space_start <= 0 ; 
                    s_index <= 0;                    
                    p_len <= 0;
                    p_index <= 0;
                    new_string <= 1;
              end  
        endcase
    end// end else 
end
endmodule // cycle times : 30  NS 
          // Total : 51570 NS
          // area :  18090.889498 
