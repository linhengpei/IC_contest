module FFT_PE( clk, rst, a, b, power, ab_valid, fft_a, fft_b, fft_pe_valid);
input clk, rst; 		 
input signed [31:0] a, b;
input [2:0] power;
input ab_valid;		
output reg[31:0] fft_a, fft_b;
output reg fft_pe_valid;

wire [31:0]W_real[7:0] ;
wire [31:0]W_image[7:0] ;

assign W_real[0] = 32'h00010000;
assign W_real[1] = 32'h0000EC83;
assign W_real[2] = 32'h0000B504;
assign W_real[3] = 32'h000061F7;
assign W_real[4] = 32'h00000000;
assign W_real[5] = 32'hFFFF9E09;
assign W_real[6] = 32'hFFFF4AFC;
assign W_real[7] = 32'hFFFF137D;

assign W_image[0] = 32'h00000000;
assign W_image[1] = 32'hFFFF9E09;
assign W_image[2] = 32'hFFFF4AFC;
assign W_image[3] = 32'hFFFF137D;
assign W_image[4] = 32'hFFFF0000;
assign W_image[5] = 32'hFFFF137D;
assign W_image[6] = 32'hFFFF4AFC;
assign W_image[7] = 32'hFFFF9E09;
/*
a : a[31:16]
b : a[15:0]
c : b[31:16]
d : b[15:0] 
*/
wire [15:0] fft_a_real ,fft_a_image ;
assign fft_a_real  = ( a[31:16] + b[31:16] ) ;
assign fft_a_image = ( a[15: 0] + b[15: 0] ) ; 

wire  [47:0] fft_b_real , fft_b_image;
assign fft_b_real  = ( a[31:16] - b[31:16]) * ( W_real[power]) + (b[15:0] - a[15:0]) * (W_image[power]);
assign fft_b_image = ( a[31:16] - b[31:16]) * (W_image[power]) + (a[15:0] - b[15:0]) * ( W_real[power]);

always@( negedge clk )begin	
	fft_a <= {fft_a_real , fft_a_image};   // real part
    fft_b <= {fft_b_real[31:16] , fft_b_image[31:16]};   // image part
end

reg state ;
always@( negedge clk )begin	
	if(rst )begin
		state <= 0;
        fft_pe_valid <= 0;
	end
	else begin 
	   case(state)
			0: state <= 1;
			1:fft_pe_valid <= 1;
		endcase
    end
end

endmodule //  area : 48812.131702 


