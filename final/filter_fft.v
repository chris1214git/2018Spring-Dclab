module filter_fft(
	input  clk, rst,
	input  [4:0] i_magn,
	input  [7:0] i_max_id, 
	output valid,
	output [7:0] i_max_id
);

parameter THRESHOLD = 8;
parameter L_TIME = 75000;
wire	loud_enough = i_magn>THRESHOLD;

reg  [19:0] cont_r, cont_w;

always@(*)begin
	if(cont_r==)
	cont_w = cont_r+1;

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