module SetCodec(
	input i_clk,
	input i_rst,
	output o_sclk,
	inout o_sdat,
	output o_init_finish
);

logic [23:0] init_data[9:0];
assign init_data[0] = 24'b001101000000000010010111; //left line in
assign init_data[1] = 24'b001101000000001010010111; //right line in
assign init_data[2] = 24'b001101000000010001111001; //left headphone out
assign init_data[3] = 24'b001101000000011001111001; //right headphone out
assign init_data[4] = 24'b001101000000100000010101; //[3]->1,[2]->0 analog audio path control
assign init_data[5] = 24'b001101000000101000000000; //digital audio path control
assign init_data[6] = 24'b001101000000110000000000; //power down control
assign init_data[7] = 24'b001101000000111001000010; //digital audio interface format
assign init_data[8] = 24'b001101000001000000011001; //sampling control
assign init_data[9] = 24'b001101000001001000000001; //active control





localparam NUM_INIT_DATA = 10;//revised
localparam S_START_TRANS = 0;
localparam S_WAIT = 1;

logic state_r, state_w;
logic [3:0] cnt_r, cnt_w;//revised
logic start_r, start_w, finish;
assign o_init_finish = (cnt_r == NUM_INIT_DATA);

I2cSender #(.BYTE(3)) sender(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(start_r),
	.i_dat(init_data[cnt_r]),
	.o_finished(finish),
	.o_sclk(o_sclk),
	.o_sdat(o_sdat)
);
/*I2CSender Sender(
		.i_start(start_r),
		.i_dat(init_data[cnt_r]),
		.i_clk(i_clk),
		.i_rst(i_rst),
		.o_finished(finish),
		.o_sclk(o_sclk),
		.o_sdat(o_sdat)
	);*/
always_comb begin
	cnt_w = cnt_r;
	start_w = start_r;
	state_w = state_r;
	case(state_r)
		S_START_TRANS: begin
			if (cnt_r < NUM_INIT_DATA) begin
				start_w = 1;
				state_w = S_WAIT;
			end
		end
		S_WAIT: begin
			start_w = 0;
			if (finish) begin
				state_w = S_START_TRANS;
				cnt_w = cnt_r + 1;
			end
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst) begin
	if (!i_rst) begin
		state_r <= S_START_TRANS;
		cnt_r <= 0;
		start_r <= 0;
	end
	else begin
		state_r <= state_w;
		cnt_r <= cnt_w;
		start_r <= start_w;
	end
end
endmodule
