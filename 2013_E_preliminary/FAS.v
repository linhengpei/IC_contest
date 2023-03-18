module FAS(clk, rst, data_valid, data, 
fft_d0,fft_d1,fft_d2,fft_d3,fft_d4,fft_d5,fft_d6,fft_d7,
fft_d8,fft_d9,fft_d10,fft_d11,fft_d12,fft_d13,fft_d14,fft_d15,
fft_valid, done, freq);
       
input	clk;
input	rst;
input	data_valid;
input signed [15:0] data;
output reg[31:0] fft_d0,fft_d1,fft_d2,fft_d3,fft_d4,fft_d5,fft_d6,fft_d7, 
              fft_d8,fft_d9,fft_d10,fft_d11,fft_d12,fft_d13,fft_d14,fft_d15;
output reg fft_valid;
output reg done;                      
output reg [3:0] freq;

reg [15:0]data_buffer[15:0];
reg [2:0]state;
reg [3:0]counter;

reg  [63:0] data_in[15:0]; 
wire [63:0] data_out[15:0];
/* 
    data[63:48]  real  interger 
    data[47:32]  real  float 
    data[31:16] image  interger 
    data[15: 0] image  float 
*/
reg  [2:0] W [7:0];

FFT_PE FFT1 (data_in[ 0] , data_in[ 1] , W[0], data_out[ 0] , data_out[ 1]);
FFT_PE FFT2 (data_in[ 2] , data_in[ 3] , W[1], data_out[ 2] , data_out[ 3]);
FFT_PE FFT3 (data_in[ 4] , data_in[ 5] , W[2], data_out[ 4] , data_out[ 5]);
FFT_PE FFT4 (data_in[ 6] , data_in[ 7] , W[3], data_out[ 6] , data_out[ 7]);
FFT_PE FFT5 (data_in[ 8] , data_in[ 9] , W[4], data_out[ 8] , data_out[ 9]);
FFT_PE FFT6 (data_in[10] , data_in[11] , W[5], data_out[10] , data_out[11]);
FFT_PE FFT7 (data_in[12] , data_in[13] , W[6], data_out[12] , data_out[13]);
FFT_PE FFT8 (data_in[14] , data_in[15] , W[7], data_out[14] , data_out[15]);

always@(posedge clk)begin
       if(rst)begin
              counter <= 0;
              state <= 0;
              fft_valid <= 0;
              done <= 0;
       end
       else begin
              data_buffer[counter] <= data;
              counter <= counter + 1;
              if(counter == 15)begin // data already 
                     data_in[0] <= { {8{data_buffer[0][15]}} , data_buffer[0] , 40'd 0};
                     data_in[1] <= { {8{data_buffer[8][15]}} , data_buffer[8] , 40'd 0};  // signed bit extend
                     W[0] <= 0;

                     data_in[2] <= { {8{data_buffer[1][15]}} , data_buffer[1] , 40'd 0};
                     data_in[3] <= { {8{data_buffer[9][15]}} , data_buffer[9] , 40'd 0};
                     W[1] <= 1;
                     
                     data_in[4] <= { {8{data_buffer[ 2][15]}} , data_buffer[ 2] , 40'd 0};
                     data_in[5] <= { {8{data_buffer[10][15]}} , data_buffer[10] , 40'd 0};
                     W[2] <= 2;

                     data_in[6] <= { {8{data_buffer[ 3][15]}} , data_buffer[ 3] , 40'd 0};
                     data_in[7] <= { {8{data_buffer[11][15]}} , data_buffer[11] , 40'd 0};
                     W[3] <= 3;

                     data_in[8] <= { {8{data_buffer[ 4][15]}} , data_buffer[ 4] , 40'd 0};
                     data_in[9] <= { {8{data_buffer[12][15]}} , data_buffer[12] , 40'd 0};
                     W[4] <= 4;

                     data_in[10] <= { {8{data_buffer[ 5][15]}} , data_buffer[ 5] , 40'd 0};
                     data_in[11] <= { {8{data_buffer[13][15]}} , data_buffer[13] , 40'd 0};
                     W[5] <= 5;

                     data_in[12] <= { {8{data_buffer[ 6][15]}} , data_buffer[ 6] , 40'd 0};
                     data_in[13] <= { {8{data_buffer[14][15]}} , data_buffer[14] , 40'd 0};
                     W[6] <= 6; 

                     data_in[14] <= { {8{data_buffer[ 7][15]}} , data_buffer[ 7] , 40'd 0};
                     data_in[15] <= { {           8{data[15]}} , data            , 40'd 0};
                     W[7] <= 7;

		       state <= 1 ; // start calculate
              end
              else begin
                     case(state)
                            0: state <= 0;
                            1:begin
                              data_in[0] <= data_out[0];
                              data_in[1] <= data_out[8];
                              W[0] <= 0;

                              data_in[2] <= data_out[2];
                              data_in[3] <= data_out[10];
                              W[1] <= 2;
                               
                              data_in[4] <= data_out[4];
                              data_in[5] <= data_out[12];
                              W[2] <= 4;

                              data_in[6] <= data_out[6];
                              data_in[7] <= data_out[14];
                              W[3] <= 6;

                              data_in[8] <= data_out[1];
                              data_in[9] <= data_out[9];
                              W[4] <= 0;

                              data_in[10] <= data_out[3];
                              data_in[11] <= data_out[11];
                              W[5] <= 2;

                              data_in[12] <= data_out[5];
                              data_in[13] <= data_out[13];
                              W[6] <= 4; 

                              data_in[14] <= data_out[7];
                              data_in[15] <= data_out[15];
                              W[7] <= 6;

                              state <= state + 1;     
                              end  
                          2:begin
                              data_in[0] <= data_out[0];
                              data_in[1] <= data_out[4];
                              W[0] <= 0;

                              data_in[2] <= data_out[2];
                              data_in[3] <= data_out[6];
                              W[1] <= 4;
                               
                              data_in[4] <= data_out[1];
                              data_in[5] <= data_out[5];
                              W[2] <= 0;

                              data_in[6] <= data_out[3];
                              data_in[7] <= data_out[7];
                              W[3] <= 4;

                              data_in[8] <= data_out[ 8];
                              data_in[9] <= data_out[12];
                              W[4] <= 0;

                              data_in[10] <= data_out[10];
                              data_in[11] <= data_out[14];
                              W[5] <= 4;

                              data_in[12] <= data_out[ 9];
                              data_in[13] <= data_out[13];
                              W[6] <= 0; 

                              data_in[14] <= data_out[11];
                              data_in[15] <= data_out[15];
                              W[7] <= 4;

                              state <= state + 1;
                             end
                         3:begin
                              data_in[0] <= data_out[0];
                              data_in[1] <= data_out[2];
                              W[0] <= 0;

                              data_in[2] <= data_out[1];
                              data_in[3] <= data_out[3];
                              W[1] <= 0;
                               
                              data_in[4] <= data_out[4];
                              data_in[5] <= data_out[6];
                              W[2] <= 0;

                              data_in[6] <= data_out[5];
                              data_in[7] <= data_out[7];
                              W[3] <= 0;

                              data_in[8] <= data_out[ 8];
                              data_in[9] <= data_out[10];
                              W[4] <= 0;

                              data_in[10] <= data_out[ 9];
                              data_in[11] <= data_out[11];
                              W[5] <= 0;

                              data_in[12] <= data_out[12];
                              data_in[13] <= data_out[14];
                              W[6] <= 0; 

                              data_in[14] <= data_out[13];
                              data_in[15] <= data_out[15]; 
                              W[7] <= 0;

                              state <= state + 1;
                            end 
                          4:begin   
                              fft_valid <= 1;

                              fft_d0  <= { data_out[ 0][55:40] , data_out[ 0][23:8] };
                              fft_d1  <= { data_out[ 8][55:40] , data_out[ 8][23:8] };   
                              fft_d2  <= { data_out[ 4][55:40] , data_out[ 4][23:8] };   
                              fft_d3  <= { data_out[12][55:40] , data_out[12][23:8] };
                              fft_d4  <= { data_out[ 2][55:40] , data_out[ 2][23:8] };
                              fft_d5  <= { data_out[10][55:40] , data_out[10][23:8] };
                              fft_d6  <= { data_out[ 6][55:40] , data_out[ 6][23:8] };
                              fft_d7  <= { data_out[14][55:40] , data_out[14][23:8] };
                              fft_d8  <= { data_out[ 1][55:40] , data_out[ 1][23:8] };
                              fft_d9  <= { data_out[ 9][55:40] , data_out[ 9][23:8] };
                              fft_d10 <= { data_out[ 5][55:40] , data_out[ 5][23:8] };
                              fft_d11 <= { data_out[13][55:40] , data_out[13][23:8] };
                              fft_d12 <= { data_out[ 3][55:40] , data_out[ 3][23:8] };
                              fft_d13 <= { data_out[11][55:40] , data_out[11][23:8] };
                              fft_d14 <= { data_out[ 7][55:40] , data_out[ 7][23:8] };
                              fft_d15 <= { data_out[15][55:40] , data_out[15][23:8] }; 
                              
                              done <= 1;
                              state <= state + 1;
                            end 
                          5:begin
                              fft_valid <= 0;   
                              done <= 0;
                              state <= 0;
                            end  
                     endcase
              end
       end
end


integer i;
reg [31:0]max;
reg [31:0]fre_square;
reg [3:0]index;
always@(*)begin
   max = 0;
   for (i = 0; i < 16 ; i = i+1) begin
       fre_square = $signed(data_out[i][55:40] ) * $signed(data_out[i][55:40]) +$signed(data_out[i][23:8]) * $signed(data_out[i][23:8]);
       if(fre_square >= max)begin
              max = fre_square;
              index = i ; 
       end
   end

   case(index)
        0: freq =  0;
        1: freq =  8;
        2: freq =  4;
        3: freq = 12;
        4: freq =  2;
        5: freq = 10;
        6: freq =  6;
        7: freq = 14;
        8: freq =  1;
        9: freq =  9;
       10: freq =  5;
       11: freq = 13;
       12: freq =  3;
       13: freq = 11;
       14: freq =  7;
       15: freq = 15;
   endcase
end

endmodule




module FFT_PE( a, b, power, fft_a, fft_b );
input signed[63:0] a, b;
input [2:0] power;		
output signed[63:0] fft_a, fft_b;

wire signed[31:0]W_real[7:0] ;
wire signed[31:0]W_image[7:0] ;
assign W_real[0] = 32'h00010000;
assign W_real[1] = 32'h0000EC83;
assign W_real[2] = 32'h0000B504;
assign	W_real[3] = 32'h000061F7;
assign	W_real[4] = 32'h00000000;
assign	W_real[5] = 32'hFFFF9E09;
assign	W_real[6] = 32'hFFFF4AFC;
assign	W_real[7] = 32'hFFFF137D;

assign	W_image[0] = 32'h00000000;
assign	W_image[1] = 32'hFFFF9E09;
assign	W_image[2] = 32'hFFFF4AFC;
assign	W_image[3] = 32'hFFFF137D;
assign	W_image[4] = 32'hFFFF0000;
assign	W_image[5] = 32'hFFFF137D;
assign	W_image[6] = 32'hFFFF4AFC;
assign	W_image[7] = 32'hFFFF9E09;
/*
a : a[63:32]
b : a[31:0]
c : b[63:32]
d : b[31:0] 
*/
wire signed[32:0] fft_a_real ,fft_a_image ;
assign fft_a_real  = ( a[63:32] + b[63:32]) ;
assign fft_a_image = ( a[31: 0] + b[31: 0]) ; 

wire  signed[63:0] fft_b_real , fft_b_image;
assign fft_b_real  = $signed( a[63:32] - b[63:32]) * ( W_real[power]) + $signed(b[31:0] - a[31:0]) * (W_image[power]);
assign fft_b_image = $signed( a[63:32] - b[63:32]) * (W_image[power]) + $signed(a[31:0] - b[31:0]) * ( W_real[power]);

assign fft_a[63:32] = fft_a_real  ;
assign fft_a[31: 0] = fft_a_image ;   // real part

assign fft_b[63:32] = fft_b_real [47:16];  
assign fft_b[31: 0] = fft_b_image[47:16];   // image part

endmodule
