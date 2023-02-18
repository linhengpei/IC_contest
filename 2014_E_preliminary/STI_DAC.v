module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	       so_data, so_valid,
	       pixel_finish, pixel_dataout, pixel_addr,
	       pixel_wr);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end; 
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;
output reg	so_data, so_valid;
output reg pixel_finish, pixel_wr;
output reg [7:0] pixel_addr;
output reg [7:0] pixel_dataout;

reg [4:0]STI_counter; 
reg [2:0]DAC_counter; 
reg [1:0]state;

reg [31:0]output_buffer ;
reg [15:0]reverse_data;
integer i;

always@(*)begin    // output_buffer logic
	for( i = 0; i <= 15 ; i = i + 1)
		reverse_data[15 - i] = pi_data[i];

	output_buffer = 0;
	case(pi_length)
		0 : begin  // 8 bite
			if(pi_low)begin 
				if(pi_msb  == 1)  output_buffer[31:24] = pi_data[15:8];
				else              output_buffer[31:24] = reverse_data[7:0];
			end
			else begin
				if(pi_msb  == 1)  output_buffer[31:24] = pi_data[7:0];
				else		      output_buffer[31:24] = reverse_data[15:8];
			end
			end
		1 : begin // 16 bits  
				if(pi_msb  == 1)  output_buffer[31:16] = pi_data;
				else              output_buffer[31:16] = reverse_data;	                                     
			end
		2 : begin  // 24  bits
			if(pi_fill)begin
				if(pi_msb  == 1)  output_buffer[31:8] = { pi_data , 8'd0 };
				else              output_buffer[31:8] ={ 8'd0  , reverse_data};
			end
			else begin
				if(pi_msb  == 1)  output_buffer[31:8] = { 8'd0 , pi_data };
				else              output_buffer[31:8] = { reverse_data , 8'd0};	
			end
			end
		3 : begin  // 32 bits
			if(pi_fill)begin
				if(pi_msb  == 1)  output_buffer = { pi_data , 16'd0 };
				else              output_buffer = {16'd0  , reverse_data };
			end
			else begin
				if(pi_msb  == 1)  output_buffer = { 16'd0 , pi_data };
				else              output_buffer = {reverse_data , 16'd0};
			end
			end
	endcase 
end

always@(*)begin  // so_data logic
	so_data = output_buffer[STI_counter]; 
end

always@(*)begin  // pixel_dataout logic
    pixel_dataout = 0;
	if(state == 1)begin
		case(DAC_counter)
			0: pixel_dataout = output_buffer[31:24];
			1: pixel_dataout = output_buffer[23:16];
			2: pixel_dataout = output_buffer[15: 8];														
			3: pixel_dataout = output_buffer[ 7: 0];				
		endcase
	end
end


always@(posedge clk)begin  // fsm
	if(reset)begin
        state <= 0;
		DAC_counter <= 0;
		so_valid <= 0;

		pixel_wr <= 0;
		pixel_addr <= 0;
		pixel_finish <= 0;
	end
	else begin
		case(state)
			0:begin
				if(load == 1) 
					state <= 1;
			  end
			1:begin  // output DAC				
				if(DAC_counter <= pi_length) begin
				    pixel_wr <= !pixel_wr;					
					if(pixel_wr == 1)begin
						pixel_addr <= pixel_addr + 1;
						DAC_counter <= DAC_counter + 1;						
					end
				end	
				else begin
					state <= 2;
					DAC_counter <= 0;
				end	
			  end
			2:begin  // output STI
			    STI_counter <= 31;
				if(so_valid == 0)begin
			    	so_valid <= 1;
				end
				else if(STI_counter == 24 - pi_length * 8)begin
					so_valid <= 0;
					if(pi_end)
						state <= 3;
					else
						state <= 0;	
				end
				else begin
					STI_counter <= STI_counter - 1;					
				end
			   end  
			3:begin  // output remain DAC
				pixel_wr <= !pixel_wr;
				if(pixel_wr == 1 )begin
					if(pixel_addr < 255) 	
						pixel_addr <= pixel_addr + 1;
					else	
						pixel_finish <= 1;
				end	
			   end  
		endcase
    end // endcase
end
endmodule // cycle : 20ns  area : 3016.279765
