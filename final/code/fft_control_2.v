module fft_control_2(
	input clk,
	input rst_n,
	output [17:0] sink_real,
	output [17:0] sink_imag,
	output sink_startofpacket,
	output sink_endofpacket,
	output sink_valid,

	input  sink_ready,
	input [15:0] i_sram_data
);

parameter	FFT_LENGTH = 14'd256;
parameter   wait_cont  = 20'hfffff;

reg [19:0] wait_cont_r; //initial wait
wire[19:0] wait_cont_w;
assign 	   wait_cont_w = wait_cont_r==wait_cont ? wait_cont:wait_cont_r+20'd1;

wire 	   ready = wait_cont_r==wait_cont;
reg [13:0] length_cont_r;
wire[13:0] length_cont_w;


assign 	   sink_real = {2'b00,i_sram_data};
assign     sink_imag = 18'd0;
assign     sink_valid = 1'b1;
assign     sink_startofpacket = length_cont_r==14'd1;
assign     sink_endofpacket   = length_cont_r==FFT_LENGTH;
assign 	   length_cont_w = ( ~ready ||~sink_ready)    ? 0:
						   (length_cont_r==FFT_LENGTH)? 1: 
						   	length_cont_r+1;

always @(posedge clk) begin : proc_wait_cont_r
	if(~rst_n) begin
		length_cont_r <= 0;
		wait_cont_r   <= 0;
	end else begin
		length_cont_r <= length_cont_w;
		wait_cont_r   <= wait_cont_w;
	end
end

endmodule