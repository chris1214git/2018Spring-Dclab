module collect_voice(
	input  clk, rst,
	input  [15:0] i_sram_data, 
//	output valid,
	output [15:0] o_sram_data_256
);

parameter SAMPLE_LEN = 11'd255;
parameter SAMPLE_FFT = 11'd255;
integer i;

wire [10:0] cont_w;
reg  [10:0] cont_r;
assign cont_w = (cont_r==SAMPLE_LEN)? 0: cont_r+1;

wire push_back = cont_r==SAMPLE_LEN;

wire [10:0] fft_cont_w;
reg  [10:0] fft_cont_r;
assign fft_cont_w = (fft_cont_r==SAMPLE_FFT)? 0: fft_cont_r+1;
wire [7:0]  fft_idx = fft_cont_r[7:0];

reg  [15:0] i_sram_data_w[255:0];
reg  [15:0] i_sram_data_r[255:0];

//assign valid = fft_idx == SAMPLE_FFT;
assign o_sram_data_256 = i_sram_data_r[fft_idx];

always@(*) begin
	if(~push_back) begin
		for(i=0;i<256;i=i+1)begin
			i_sram_data_w[i] = i_sram_data_r[i]; 
		end
	end
	else begin
		for(i=0;i<255;i=i+1)begin
			i_sram_data_w[i] = i_sram_data_r[i+1]; 
		end
			i_sram_data_w[255] = i_sram_data;
	end
end

always@(posedge clk) begin
	if (!rst) begin
		cont_r 		  <= 0;
		fft_cont_r    <= 0;
		for(i=0;i<256;i=i+1)
			i_sram_data_r[i] <= 0;
	end else begin
		cont_r 		  <= cont_w;
		fft_cont_r 	  <= fft_cont_w;
		for(i=0;i<256;i=i+1)
			i_sram_data_r[i] <= i_sram_data_w[i];
	end
end
	
endmodule