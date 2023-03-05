module DT(
	input 			clk, 
	input			reset,
	output	reg		done ,
	output	reg		sti_rd ,
	output	reg 	[9:0]	sti_addr ,
	input		    [15:0]	sti_di,
	output	reg		res_wr ,
	output	reg		res_rd ,
	output	reg 	[13:0]	res_addr ,
	output	reg 	[7:0]	res_do,
	input		[7:0]	res_di
	);

reg [3:0]state ;
reg [3:0]counter ;
/*
	forward :        backward :
	1 || 2 || 3             || 0
	0 ||             3 || 2 || 1
*/

always@(posedge clk)begin
	if(reset == 0)begin
	    counter <= 14;
		state <= 0;

		sti_rd <= 0;			

		res_wr <= 0;
		res_rd <= 0;
		res_addr <= 0;
		res_do <= 0;
		done <= 0;
	end 
	else begin
		case(state)
			0:begin  // forward  start
				sti_rd <= 1;
				sti_addr <= 0;
				
				state <= state + 1;
			  end
			1:begin
			    
                if(sti_di[counter] == 0)begin  // black
					res_wr   <= 1;
					res_do   <= 0;
					res_addr <= res_addr + 1 ;					
				end		
				else begin                     // white
					res_rd <= 1;
					res_wr <= 0;

					state <= state + 1;
                end

				counter <= counter - 1;
				if(counter == 0)begin
                    if(sti_addr == 1023) begin
					 	state <= 6;
						counter <= 1;
					end	
					else	
					 	sti_addr <= sti_addr + 1;
				end
			  end  

			2:begin // read  4 data 
			    	res_do <= res_di ;
					res_addr <=  res_addr - 128;
					state <= state + 1;
			   end
			3:begin
					if( res_di < res_do)
			    		res_do <= res_di ;
					res_addr <=  res_addr + 1;
					state <= state + 1;
			   end
			4:begin
			    	if( res_di < res_do)
			    		res_do <= res_di ;

					res_addr <=  res_addr + 1;
					state <= state + 1;
			   end   
			5:begin //write data
			    	
					if( res_di < res_do)
			    		res_do <= res_di + 1  ;
					else	
					    res_do <= res_do + 1  ;	
                    res_wr   <= 1;
					res_addr <=  res_addr + 127;
					state <= 1;
			   end
            6:begin
					if(sti_di[counter] == 0)begin  // black
						res_wr   <= 1;
						res_do   <= 0;
						res_addr <= res_addr - 1 ;
					end		
					else begin                     // white
						res_rd <= 1;
						res_wr <= 0;
						state <= state + 1;
					end

					counter <= counter + 1;
					if(counter == 15)begin
						if(sti_addr == 0) begin
							done <= 1;
						end	
						else	
							sti_addr <= sti_addr - 1;
					end
				end
			7:begin //backward
					
					res_do <= res_di;
					res_addr <= res_addr + 128;

					state <= state + 1;
				end
			8:begin
					if(res_di < res_do)
						res_do <= res_di;     
					res_addr <= res_addr -1;	

					state <= state + 1; 
				end
			9:begin
					if(res_di < res_do)
						res_do <= res_di;   
					res_addr <= res_addr - 1;	

					state <= state + 1; 
				end   
			10:begin
					if(res_di < res_do)
						res_do <= res_di; 

					res_addr <= res_addr - 127;

					state <= state + 1; 
				end
			11:begin  
					res_wr <= 1; 
                    if(res_di < res_do +1 )
						res_do <= res_di ;
					else 
					   	res_do <= res_do +  1;
                    state <= 6;
				end   
		endcase
	end
end
endmodule // area : 6507.831560 time : 1907158.293 ns