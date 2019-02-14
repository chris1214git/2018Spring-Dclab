module I2CInitial(
	input i_clk,
	input i_rst,
	output o_sclk,
	inout o_sdat,
	output Init_finish
);

	logic [23:0] data[9:0];
	assign data[0] = 24'b0011_0100_000_0000_0_1001_0111;			//LeftLineIn
	assign data[1] = 24'b0011_0100_000_0001_0_1001_0111;		//RightLineIn
	assign data[2] = 24'b0011_0100_000_0010_0_0111_1001;	//LeftHeadphoneOut
	assign data[3] = 24'b0011_0100_000_0011_0_0111_1001;	//RightHeadphoneOut
	assign data[4] = 24'b0011_0100_000_0100_0_0001_0101;		//AnaAudPathCont
	assign data[5] = 24'b0011_0100_000_0101_0_0000_0000;		//DigAudPathCont
	assign data[6] = 24'b0011_0100_000_0110_0_0000_0000;		//PowDownCont
	assign data[7] = 24'b0011_0100_000_0111_0_0100_0010;	//DigAudInterForm
	assign data[8] = 24'b0011_0100_000_1000_0_0001_1001;		//SamplingCont
	assign data[9] = 24'b0011_0100_000_1001_0_0000_0001;			//ActiveCont
	
	localparam S_IDLE = 0;
	localparam S_WAIT = 1;
	logic state_w, state_r;
	logic [3:0] num_count_w, num_count_r;
	//logic [23:0] data_w, data_r;
	logic start_w, start_r;
	logic I2C_send_finish;
	
	I2CSender Sender(
		.i_start(start_r),
		.i_dat(data[num_count_r]),
		.i_clk(i_clk),
		.i_rst(i_rst),
		.o_finished(I2C_send_finish),
		.o_sclk(o_sclk),
		.o_sdat(o_sdat)
	);
	assign Init_finish = (num_count_r==10) ? 1 : 0;
	
	
	
	always_comb begin
		state_w = state_r;
		num_count_w = num_count_r;
		//data_w = data_r;
		start_w = start_r;
		/*case(num_count_r)
			0 : data_w = LeftLineIn;
			1 : data_w = RightLineIn;
			2 : data_w = LeftHeadphoneOut;
			3 : data_w = RightHeadphoneOut;
			4 : data_w = AnaAudPathCont;
			5 : data_w = DigAudPathCont;
			6 : data_w = PowDownCont;
			7 : data_w = DigAudInterForm;
			8 : data_w = SamplingCont;
			9 : data_w = ActiveCont;
			default : data_w = 0;
		endcase*/
		case(state_r)
			S_IDLE : begin
				if(num_count_r < 10) begin
					state_w = S_WAIT;
					start_w = 1;
					num_count_w = num_count_r;
					//data_w = data_r;
				end
				else begin
					state_w = state_r;
					num_count_w = num_count_r;
					//data_w = data_r;
					start_w = start_r;
				end
			end
			S_WAIT : begin
				start_w = 0;
				if(I2C_send_finish) begin
					state_w = S_IDLE;
					num_count_w = num_count_r + 1;
					//data_w = data_r;
					//start_w = start_r;
				end
				else begin
					state_w = state_r;
					num_count_w = num_count_r;
					//data_w = data_r;
					//start_w = start_r;
				end
			end
		endcase
	end
	
	always_ff @(posedge i_clk) begin
		if (!i_rst) begin
			state_r <= S_IDLE;
			num_count_r <= 0;
			//data_r <= 0;
			start_r <= 0;
		end
		else begin
			state_r <= state_w;
			num_count_r <= num_count_w;
			//data_r <= data_w;
			start_r <= start_w;
		end
	end
endmodule



